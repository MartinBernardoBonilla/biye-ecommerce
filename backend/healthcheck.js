const http = require('http');

const options = {
  hostname: 'localhost',
  port: 5000,
  path: '/health',
  timeout: 2000,
};

const req = http.request(options, (res) => {
  console.log(`HEALTH CHECK: Status ${res.statusCode}`);
  process.exit(res.statusCode === 200 ? 0 : 1);
});

req.on('error', (err) => {
  console.error('HEALTH CHECK ERROR:', err.message);
  process.exit(1);
});

req.end();
