#!/bin/bash
# Install Node.js (this works because dnf fetches from Amazon Linux S3 mirrors natively)
dnf update -y
dnf install -y nodejs

# Create the application directory
mkdir -p /opt/app
chown -R ec2-user:ec2-user /opt/app

# Dynamically generate the Environment File with Terraform outputs
cat << 'EOF' > /etc/default/node-app
NODE_ENV=production
PORT=3000
AWS_REGION=${aws_region}
DB_HOST=${db_host}
DB_USER=${db_user}
DB_NAME=appdb
DB_PORT=5432
DB_SECRET_ARN=${db_secret_arn}
EOF

# Secure the environment file so only root and ec2-user can read it
chmod 640 /etc/default/node-app
chown root:ec2-user /etc/default/node-app

# The Wait Loop: Wait for the developer to upload the artifact to S3
echo "Waiting for app artifact to appear in S3..."
while ! aws s3 cp s3://${artifact_bucket}/release/app-v1.tar.gz ./; do
  echo "Artifact not found. Retrying in 10 seconds..."
  sleep 10
done

# Extract and start the application
tar -xzf app-v1.0.0.tar.gz
chown -R ec2-user:ec2-user /opt/app
cp node-app.service /etc/systemd/system/

systemctl daemon-reload
systemctl enable node-app
systemctl start node-app
