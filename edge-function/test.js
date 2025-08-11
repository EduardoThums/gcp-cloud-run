// Simple test script for the edge function
const http = require('http');

const testAuth = (username, password, path = '/') => {
  const credentials = Buffer.from(`${username}:${password}`).toString('base64');
  
  const options = {
    hostname: 'localhost',
    port: 8080,
    path: path,
    method: 'GET',
    headers: {
      'Authorization': `Basic ${credentials}`
    }
  };

  const req = http.request(options, (res) => {
    console.log(`\nTesting: ${username}:${password} -> ${path}`);
    console.log(`Status: ${res.statusCode}`);
    console.log('Headers:', res.headers);
    
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    
    res.on('end', () => {
      if (res.statusCode === 200) {
        console.log('Response length:', data.length);
        console.log('Content preview:', data.substring(0, 100) + '...');
      } else {
        console.log('Error response:', data);
      }
    });
  });

  req.on('error', (e) => {
    console.error(`Problem with request: ${e.message}`);
  });

  req.end();
};

// Test cases
console.log('Starting edge function tests...');
console.log('Make sure the function is running locally with: npm start');

setTimeout(() => {
  // Test valid credentials
  testAuth('admin', 'password123', '/');
  
  // Test invalid credentials
  setTimeout(() => testAuth('wrong', 'credentials', '/'), 1000);
  
  // Test specific file
  setTimeout(() => testAuth('admin', 'password123', '/index.html'), 2000);
  
}, 2000);