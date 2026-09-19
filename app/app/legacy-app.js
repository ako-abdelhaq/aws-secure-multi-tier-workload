// App version that uses environment variables to access the database 
// (You have to include the db_username in the bootstrap script)
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