// Simple test script to verify backend services are running
const axios = require('axios');

const EC2_IP = '51.20.164.143';

const services = [
  { name: 'API Gateway', url: `http://${EC2_IP}:3001/health` },
  { name: 'FHIR Backend', url: `http://${EC2_IP}:8080/health` },
  { name: 'Auth Service', url: `http://${EC2_IP}:3002/health` },
  { name: 'Visits Service', url: `http://${EC2_IP}:3008/health` },
  { name: 'S3 Service', url: `http://${EC2_IP}:3009/health` },
];

async function testServices() {
  console.log('Testing backend services...\n');
  
  for (const service of services) {
    try {
      const response = await axios.get(service.url, { timeout: 5000 });
      console.log(`✅ ${service.name}: OK (${response.status})`);
    } catch (error) {
      console.log(`❌ ${service.name}: FAILED (${error.message})`);
    }
  }
  
  console.log('\nTesting S3 service endpoints...');
  
  // Test S3 service specific endpoints
  try {
    const response = await axios.get(`http://${EC2_IP}:3009/api/uploads/health`, { timeout: 5000 });
    console.log(`✅ S3 Upload Endpoint: OK (${response.status})`);
  } catch (error) {
    console.log(`❌ S3 Upload Endpoint: FAILED (${error.message})`);
  }
}

testServices().catch(console.error);