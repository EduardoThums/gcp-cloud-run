#!/bin/bash

# Edge Function Deployment Script
set -e

# Configuration
FUNCTION_NAME="storage-auth-edge"
REGION="us-central1"
RUNTIME="nodejs20"
MEMORY="256MB"
TIMEOUT="60s"

# Get project ID from environment or prompt
if [ -z "$GOOGLE_CLOUD_PROJECT" ]; then
  echo "Please set GOOGLE_CLOUD_PROJECT environment variable or run: gcloud config set project YOUR_PROJECT_ID"
  exit 1
fi

echo "Deploying Edge Function: $FUNCTION_NAME"
echo "Project: $GOOGLE_CLOUD_PROJECT"
echo "Region: $REGION"

# Deploy the 2nd generation function
gcloud functions deploy $FUNCTION_NAME \
  --gen2 \
  --runtime=$RUNTIME \
  --trigger=http \
  --allow-unauthenticated \
  --entry-point=storageAuth \
  --source=. \
  --region=$REGION \
  --memory=$MEMORY \
  --timeout=$TIMEOUT \
  --set-env-vars="STORAGE_BUCKET_NAME=${STORAGE_BUCKET_NAME:-your-project-static-content},AUTH_USERNAME=${AUTH_USERNAME:-admin},AUTH_PASSWORD=${AUTH_PASSWORD:-password123}" \
  --max-instances=10 \
  --min-instances=0

echo "Deployment completed!"
echo "Function URL: https://$REGION-$GOOGLE_CLOUD_PROJECT.cloudfunctions.net/$FUNCTION_NAME"
echo ""
echo "Test the function with:"
echo "curl -u admin:password123 https://$REGION-$GOOGLE_CLOUD_PROJECT.cloudfunctions.net/$FUNCTION_NAME/"