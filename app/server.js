// Minimal Node.js Hello World app for containerization
// Responds to / with a greeting and /healthz for K8s probes

const express = require('express');
const app = express();
const client = require('prom-client'); // Import prom-client

// Enable default metrics collection
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics({ prefix: 'node_' });

const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello, world!');
});

app.get('/healthz', (req, res) => {
  res.status(200).json({ status: 'ok', uptime: process.uptime() });
});

// Add /metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
