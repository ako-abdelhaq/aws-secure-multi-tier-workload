# In the local application directory
mkdir core-app && cd core-app
# Create app.js and package.json from the previous step here
npm install --omit=dev
tar -czf app-v1.tar.gz app.js package.json node_modules/ node-app.service

# Upload to the S3 bucket created in Step 1
BUCKET_NAME=$(terraform output -raw artifact_bucket_name)
aws s3 cp app-v1.tar.gz "s3://${BUCKET_NAME}/release/app-v1.tar.gz"
