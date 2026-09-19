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