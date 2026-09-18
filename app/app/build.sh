# In the local application directory
# Create app.js and package.json from the previous step here
cd app/app
npm install --omit=dev
tar -czf app-v1.tar.gz app.js package.json node_modules/ node-app.service

# Upload to the S3 bucket created in Step 1
BUCKET_NAME=$(aws s3 ls | grep 'artifacts' | awk '{print $3}' | head -n 1)

if [ -z "$BUCKET_NAME" ]; then
  echo "ERROR: Could not find artifacts S3 bucket."
  exit 1
fi

echo "Found target bucket: $BUCKET_NAME"

aws s3 cp app-v1.tar.gz "s3://${BUCKET_NAME}/release/app-v1.tar.gz"

if [ $? -eq 0 ]; then
    rm app-v1.tar.gz
    rm -r node_modules/
    rm package-lock.json
    echo "Uploading artifacts to S3 bucket completed!"
else
    echo "Uploading artifacts to S3 bucket failed!"
    exit 1
fi

