#!/bin/bash

set -e

# Amazon Linux 2023 repos are on S3, allowing dnf to pull nodejs via S3 Gateway
dnf install -y nodejs

mkdir -p /opt/app
cd /opt/app

# Pull release artifact internally from S3
aws s3 cp s3://${artifact_bucket}/release/app-v1.tar.gz ./
tar -xzf app-v1.tar.gz
rm -f app-v1.tar.gz
# Secure the environment file so only root and ec2-user can read it
chown 640 /opt/app
chown -R ec2-user:ec2-user /opt/app

# Write systemd service file
cat << 'EON' > /etc/systemd/system/node-app.service
[Unit]
Description=Node.js API Service
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/app
Environment=NODE_ENV=dev
Environment=PORT=3000
Environment=AWS_REGION=${aws_region}
Environment=DB_HOST=${db_host}
Environment=DB_USER=${db_user}
Environment=DB_PASSWORD=ako_ossu
Environment=DB_SECRET_ARN=${db_secret_arn}
Environment=DB_NAME=main-db
Environment=DB_PORT=5432
ExecStart=/usr/bin/node /opt/app/app.js
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EON

systemctl daemon-reload
systemctl enable node-app
systemctl start node-app
