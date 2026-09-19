/*
const express = require('express');
const { Pool } = require('pg');

// 1. Strict Configuration Verification (No silent fallbacks for credentials)
if (!process.env.DB_USER) {
  console.error('FATAL: DB_USER environment variable must be explicitly defined.');
  process.exit(1);
}

if (!process.env.DB_PASSWORD) {
  console.error('FATAL: DB_PASSWORD environment variable must be explicitly defined.');
  process.exit(1);
}

if (!process.env.DB_HOST) {
  console.error('FATAL: DB_HOST environment variable must be explicitly defined.');
  process.exit(1);
}

const app = express();
app.use(express.json());

// 2. Database Connection Pool
const pool = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'appdb',
  port: parseInt(process.env.DB_PORT, 10) || 5432,
  ssl: { rejectUnauthorized: false }, // RDS PostgreSQL encrypted transport
  connectionTimeoutMillis: 5000,
  idleTimeoutMillis: 30000
});

// 3. Schema Auto-Initialization
async function initSchema() {
  const ddl = `
    CREATE TABLE IF NOT EXISTS products (
      id SERIAL PRIMARY KEY,
      name VARCHAR(100) NOT NULL,
      price NUMERIC(10, 2) NOT NULL
    );
  `;
  try {
    const client = await pool.connect();
    await client.query(ddl);
    client.release();
    console.log('Database schema verified: products table ready.');
  } catch (err) {
    console.error('Failed to initialize database schema:', err.message);
  }
}
initSchema();

// 4. Endpoints Implementation

// GET /health
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'ok',
    message: "app is working properly!" 
  });
});

// GET /products
app.get('/products', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM products ORDER BY id ASC;');
    res.status(200).json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /products/:id
app.get('/products/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM products WHERE id = $1;', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }
    
    res.status(200).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /products
app.post('/products', async (req, res) => {
  try {
    const { name, price } = req.body;

    if (!name || price === undefined) {
      return res.status(400).json({ error: 'Both name and price are required' });
    }

    if (isNaN(parseFloat(price))) {
      return res.status(400).json({ error: 'Price must be a valid number' });
    }

    const result = await pool.query(
      'INSERT INTO products (name, price) VALUES ($1, $2) RETURNING id, name, price;',
      [name, price]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Application service listening on port ${PORT}`);
});
*/

const express = require('express');
const db = require('./db');
const app = express();

const PORT = process.env.PORT || 3000;

async function initDB() {
  console.log("Creating products table...");
  await db.query(`
      CREATE TABLE IF NOT EXISTS products (
          id SERIAL PRIMARY KEY,
          name VARCHAR(100) NOT NULL,
          price NUMERIC(10,2) NOT NULL,
          stock INT DEFAULT 0
      );
  `);

  console.log("Inserting sample data...");
  await db.query(`
      INSERT INTO products (name, price, stock) 
      VALUES 
          ('AKO Cloud Server', 49.99, 100),
          ('AKO Managed Database', 99.99, 50),
          ('AKO Load Balancer', 29.99, 200)
  `);

  console.log("Database successfully initialized!");
}

// Initialize the DB securely first
db.initializeDatabase().then(() => {

  initDB();
  
  // The health check endpoint Nginx targets (from our earlier /health-app rewrite)
  app.get('/health', (req, res) => {
      res.status(200).send('Database Connected & App is Healthy!');
  });    

  // GET /products
  app.get('/products', async (req, res) => {
    try {
      const result = await db.query('SELECT * FROM products ORDER BY id ASC;');
      res.status(200).json(result.rows);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // GET /products/:id
  app.get('/products/:id', async (req, res) => {
    try {
      const { id } = req.params;
      const result = await db.query('SELECT * FROM products WHERE id = $1;', [id]);
      
      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'Product not found' });
      }
      
      res.status(200).json(result.rows[0]);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // POST /products
  app.post('/products', async (req, res) => {
    try {
      const { name, price } = req.body;

      if (!name || price === undefined) {
        return res.status(400).json({ error: 'Both name and price are required' });
      }

      if (isNaN(parseFloat(price))) {
        return res.status(400).json({ error: 'Price must be a valid number' });
      }

      const result = await pool.query(
        'INSERT INTO products (name, price) VALUES ($1, $2) RETURNING id, name, price;',
        [name, price]
      );

      res.status(201).json(result.rows[0]);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // Start listening only after the DB is locked in
  app.listen(PORT, () => {
    console.log(`App listening on port ${PORT}`);
  });
});