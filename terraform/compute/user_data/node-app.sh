#!/bin/bash

# Install Node.js (this works because dnf fetches from Amazon Linux S3 mirrors natively)
dnf update -y
dnf install -y nodejs

# Create the application directory
mkdir -p /opt/app && cd /opt/app
chown -R ec2-user:ec2-user /opt/app

# Dynamically generate the Environment File with Terraform outputs
cat << 'EOF' > /etc/default/node-app
NODE_ENV=dev
PORT=3000
AWS_REGION=${aws_region}
DB_HOST=${db_host}
DB_NAME=${db_name}
DB_PORT=5432
DB_SECRET_ARN=${db_secret_arn}
EOF

# Secure the environment file so only root and ec2-user can read it
chmod 640 /etc/default/node-app
chown root:ec2-user /etc/default/node-app

# The Wait Loop: Wait for the developer to upload the artifact to S3
echo "Waiting for app artifact to appear in S3..."
echo "file_name: ${artifact_bucket}/release/app-v1.tar.gz"

# Trying to grab artifacts for 25 minutes 
timeout_seconds=1500
start_time=$SECONDS
while ! aws s3 cp s3://${artifact_bucket}/release/app-v1.tar.gz /opt/app; do
  elapsed=$(( SECONDS - start_time ))
  if [ $elapsed -ge $timeout_seconds ]; then
    echo "Timeout of $${timeout_seconds} s reached. Aborting."
    exit 1
  fi
  
  echo "Artifact not found. Retrying in 10 seconds..."
  sleep 10
done

# Extract and start the application
tar -xzf app-v1.tar.gz
chown -R ec2-user:ec2-user /opt/app
cp node-app.service /etc/systemd/system/

# Source the current environment variables to grab the DB_SECRET_ARN
source /etc/default/node-app

# Get the current AWS region dynamically from the EC2 metadata
AWS_REGION=${aws_region}

# Use this portion if node-app works with env variables
# You must include db_usename in the variables of compute module
# Fetch the secure JSON payload from AWS Secrets Manager
#SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id "$DB_SECRET_ARN" --region "$REGION" --query "SecretString" --output text)
#echo $SECRET_JSON >> final.txt

# Extract the password from the JSON string (using Node.js instead of installing jq)
#DB_PASSWORD=$(node -pe "JSON.parse(process.argv[1]).password" "$SECRET_JSON")
#echo $DB_PASSWORD >> final.txt

# Append the plaintext password to the systemd environment file
#echo "DB_PASSWORD=\"$DB_PASSWORD\"" >> /etc/default/node-app

systemctl daemon-reload
systemctl enable node-app
systemctl start node-app

su - ec2-user
