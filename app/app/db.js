const { SecretsManagerClient, GetSecretValueCommand } = require("@aws-sdk/client-secrets-manager");
const { Pool } = require("pg");

// Read variables populated by the EC2 user_data script
const SECRET_ARN = process.env.DB_SECRET_ARN;
const AWS_REGION = process.env.AWS_REGION || "eu-west-3"; // Adjust to your deployed region

// The client automatically inherits permissions from the App EC2 IAM Instance Profile
const secretsClient = new SecretsManagerClient({ region: AWS_REGION });
let pool;

async function initializeDatabase() {
    if (!SECRET_ARN) {
        throw new Error("DB_SECRET_ARN environment variable is missing. Check Terraform user_data injection.");
    }

    try {
        console.log("Fetching database credentials from AWS Secrets Manager...");
        
        // 1. Fetch the encrypted payload
        const command = new GetSecretValueCommand({ SecretId: SECRET_ARN });
        const response = await secretsClient.send(command);
        
        // 2. Parse the RDS-managed JSON schema
        const credentials = JSON.parse(response.SecretString);

        // 3. Initialize the PostgreSQL connection pool completely in memory
        pool = new Pool({
            host: process.env.DB_HOST,
            port: parseInt(process.env.DB_PORT, 10) || 5432,
            database: process.env.DB_NAME , 
            user: credentials.username,
            password: credentials.password,
            max: 20,
            idleTimeoutMillis: 30000,
            ssl: { rejectUnauthorized: false }, // RDS PostgreSQL encrypted transport
            connectionTimeoutMillis: 5000,
            idleTimeoutMillis: 30000
        });

        // Verify the connection actively works before allowing traffic
        const testClient = await pool.connect();
        console.log(`Successfully connected to RDS at ${credentials.host}`);
        testClient.release();

        return pool;
    } catch (error) {
        console.error("Fatal error during database initialization:", error);
        // Force the app to crash if it cannot reach the DB, ensuring it doesn't serve broken traffic
        process.exit(1); 
    }
}

module.exports = {
    initializeDatabase,
    query: (text, params) => pool.query(text, params)
};

/*
// ... existing initializeDatabase function ...
module.exports = {
    initializeDatabase,
    
    // Replace the simple query export with this self-healing wrapper
    query: async (text, params) => {
        try {
            // Attempt the query normally
            return await pool.query(text, params);
        } catch (error) {
            // Check if the error is due to an expired/rotated password
            if (error.code === '28P01') {
                console.warn("Database password rejected. Secret may have rotated. Rebuilding pool...");
                
                // 1. Drain the old pool to prevent memory leaks
                await pool.end().catch(e => console.error("Error draining old pool", e));
                
                // 2. Fetch the new secret and rebuild the pool
                await initializeDatabase();
                
                // 3. Retry the exact same query with the new credentials
                console.log("Pool rebuilt. Retrying query...");
                return await pool.query(text, params);
            }
            
            // If it's a standard SQL syntax error or missing table, throw it normally
            throw error;
        }
    }
};
*/