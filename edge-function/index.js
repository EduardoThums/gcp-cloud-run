const functions = require('@google-cloud/functions-framework');
const { Storage } = require('@google-cloud/storage');

// Initialize Cloud Storage client
const storage = new Storage();

// Configuration - these should be set as environment variables
const CONFIG = {
  bucketName: process.env.STORAGE_BUCKET_NAME || 'your-project-static-content',
  username: process.env.AUTH_USERNAME || 'admin',
  password: process.env.AUTH_PASSWORD || 'password123',
  defaultFile: 'index.html'
};

/**
 * Parse Basic Authentication header
 * @param {string} authHeader - The Authorization header value
 * @returns {object|null} - Object with username and password, or null if invalid
 */
function parseBasicAuth(authHeader) {
  if (!authHeader || !authHeader.startsWith('Basic ')) {
    return null;
  }

  try {
    const encoded = authHeader.substring(6); // Remove 'Basic ' prefix
    const decoded = Buffer.from(encoded, 'base64').toString('utf-8');
    const [username, password] = decoded.split(':');
    
    return { username, password };
  } catch (error) {
    console.error('Error parsing Basic Auth:', error);
    return null;
  }
}

/**
 * Validate credentials
 * @param {string} username 
 * @param {string} password 
 * @returns {boolean}
 */
function validateCredentials(username, password) {
  return username === CONFIG.username && password === CONFIG.password;
}

/**
 * Get file from Cloud Storage
 * @param {string} filePath - Path to the file in the bucket
 * @returns {Promise<object>} - Object with file content and metadata
 */
async function getFileFromStorage(filePath) {
  try {
    const bucket = storage.bucket(CONFIG.bucketName);
    
    // Handle root path
    if (filePath === '/' || filePath === '') {
      filePath = CONFIG.defaultFile;
    }
    
    // Remove leading slash if present
    if (filePath.startsWith('/')) {
      filePath = filePath.substring(1);
    }

    const file = bucket.file(filePath);
    
    // Check if file exists
    const [exists] = await file.exists();
    if (!exists) {
      throw new Error(`File not found: ${filePath}`);
    }

    // Get file content and metadata
    const [content] = await file.download();
    const [metadata] = await file.getMetadata();

    return {
      content,
      contentType: metadata.contentType || 'application/octet-stream',
      cacheControl: metadata.cacheControl || 'public, max-age=31536000, immutable',
      size: metadata.size,
      etag: metadata.etag,
      updated: metadata.updated
    };
  } catch (error) {
    console.error('Error accessing storage:', error);
    throw error;
  }
}

/**
 * Main Cloud Function entry point
 * @param {object} req - Express request object
 * @param {object} res - Express response object
 */
functions.http('storageAuth', async (req, res) => {
  try {
    // Set CORS headers
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Authorization, Content-Type');

    // Handle preflight requests
    // if (req.method === 'OPTIONS') {
    //   res.status(204).send('');
    //   return;
    // }

    // Only allow GET requests
    if (!['GET', 'HEAD'].includes(req.method)) {
      res.status(405).json({ error: 'Method not allowed' });
      return;
    }

    // Check for Authorization header
    const authHeader = req.get('Authorization');
    if (!authHeader) {
      res.set('WWW-Authenticate', 'Basic realm="Storage Access"');
      res.status(401).json({ error: 'Authorization required' });
      return;
    }

    // Parse and validate credentials
    const credentials = parseBasicAuth(authHeader);
    if (!credentials || !validateCredentials(credentials.username, credentials.password)) {
      res.status(403).json({ error: 'Invalid credentials' });
      return;
    }

    // Get the requested file path from the URL
    const requestedPath = req.path || '/';
    
    console.log(`Authenticated request for: ${requestedPath}`);

    // Get file from Cloud Storage
    const fileData = await getFileFromStorage(requestedPath);

    // Set appropriate headers
    res.set('Content-Type', fileData.contentType);
    res.set('Cache-Control', fileData.cacheControl);
    res.set('Content-Length', fileData.size.toString());
    res.set('ETag', fileData.etag);
    res.set('Last-Modified', new Date(fileData.updated).toUTCString());
    
    // Add security headers
    res.set('X-Content-Type-Options', 'nosniff');
    res.set('X-Frame-Options', 'DENY');
    res.set('X-XSS-Protection', '1; mode=block');
    res.set('Strict-Transport-Security', 'max-age=63072000; includeSubDomains; preload');
    res.set('Referrer-Policy', 'strict-origin-when-cross-origin');

    // Send the file content
    res.status(200).send(fileData.content);

  } catch (error) {
    console.error('Function error:', error);
    
    if (error.message.includes('File not found')) {
      res.status(404).json({ error: 'File not found' });
    } else if (error.message.includes('Access denied') || error.message.includes('Permission denied')) {
      res.status(403).json({ error: 'Access denied to storage' });
    } else {
      res.status(500).json({ error: 'Internal server error' });
    }
  }
});

module.exports = { storageAuth: functions.http };