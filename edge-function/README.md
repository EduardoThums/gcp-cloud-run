# Storage Authentication Edge Function (2nd Generation)

A Google Cloud Function (2nd Generation) that provides authenticated access to Cloud Storage content using Basic Authentication. Built on Cloud Run for better performance, scalability, and features.

## Features

- Basic Authentication validation
- Secure access to Cloud Storage buckets
- Proper error handling and HTTP status codes
- Security headers for enhanced protection
- CORS support
- File type detection and appropriate content-type headers

## 2nd Generation Benefits

- **Better Performance**: Built on Cloud Run infrastructure for faster cold starts
- **Enhanced Scaling**: More granular scaling options (0-1000+ instances)
- **Improved Networking**: Better network performance and connectivity
- **Advanced Configuration**: More configuration options for CPU, memory, and concurrency
- **Cloud Run Integration**: Can be managed through Cloud Run console and APIs
- **Better Monitoring**: Enhanced observability with Cloud Run metrics and logs

## Setup

1. **Install dependencies:**
   ```bash
   cd edge-function
   npm install
   ```

2. **Configure environment variables:**
   Copy `env.example` to `.env` and update the values:
   ```bash
   cp env.example .env
   ```

   Update the following variables:
   - `STORAGE_BUCKET_NAME`: The name of your Cloud Storage bucket
   - `AUTH_USERNAME`: Username for basic authentication
   - `AUTH_PASSWORD`: Password for basic authentication
   - `GOOGLE_CLOUD_PROJECT`: Your Google Cloud Project ID

3. **Test locally:**
   ```bash
   npm start
   ```
   
   Test with curl:
   ```bash
   curl -u admin:password123 http://localhost:8080/
   ```

## Deployment

### Using the deployment script:
```bash
export GOOGLE_CLOUD_PROJECT="your-project-id"
export STORAGE_BUCKET_NAME="your-bucket-name"
export AUTH_USERNAME="your-username"
export AUTH_PASSWORD="your-secure-password"

./deploy.sh
```

### Manual deployment:
```bash
gcloud functions deploy storage-auth-edge \
  --gen2 \
  --runtime=nodejs20 \
  --trigger=http \
  --allow-unauthenticated \
  --entry-point=storageAuth \
  --source=. \
  --region=us-central1 \
  --memory=256MB \
  --timeout=60s \
  --set-env-vars="STORAGE_BUCKET_NAME=your-bucket,AUTH_USERNAME=admin,AUTH_PASSWORD=password123"
```

## Usage

Once deployed, you can access your Cloud Storage content through the function URL:

```bash
# Get the index.html file
curl -u username:password https://REGION-PROJECT.cloudfunctions.net/storage-auth-edge/

# Get a specific file
curl -u username:password https://REGION-PROJECT.cloudfunctions.net/storage-auth-edge/path/to/file.js
```

## Security Features

- **Basic Authentication**: Validates username/password before granting access
- **Private Storage Access**: Function accesses private Cloud Storage buckets
- **Security Headers**: Includes HSTS, XSS protection, content type options, etc.
- **CORS Support**: Configurable cross-origin resource sharing
- **Error Handling**: Proper HTTP status codes and error messages

## Function Behavior

1. **Authentication Check**: Validates the `Authorization` header with Basic auth
2. **Credential Validation**: Compares provided credentials with configured values
3. **Storage Access**: Retrieves the requested file from Cloud Storage
4. **Response**: Returns the file content with appropriate headers or error messages

## Error Responses

- `401 Unauthorized`: Missing Authorization header
- `403 Forbidden`: Invalid credentials or storage access denied
- `404 Not Found`: Requested file doesn't exist in the bucket
- `405 Method Not Allowed`: Non-GET requests
- `500 Internal Server Error`: Unexpected errors

## Integration with Load Balancer

To integrate with your existing load balancer configuration, you can:

1. Add a new backend service pointing to the Cloud Function
2. Update the URL map to route authenticated requests through the function
3. Keep static content serving through the function for security

This provides an additional layer of authentication while maintaining the performance benefits of Cloud Storage and CDN.