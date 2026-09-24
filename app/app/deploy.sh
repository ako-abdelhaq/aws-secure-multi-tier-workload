#!/bin/bash

# Get the App EC2 Instance ID
APP_INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Tier,Values=App" "Name=instance-state-name,Values=running" --query "Reservations[0].Instances[0].InstanceId" --output text)

# Send the deployment execution command
aws ssm send-command \
    --instance-ids "$APP_INSTANCE_ID" \
    --document-name "AWS-RunShellScript" \
    --parameters 'commands=[
        "cd /opt/app",
        "aws s3 cp s3://'"$BUCKET_NAME"'/release/app-v1.tar.gz ./",
        "tar -xzf app-v1.tar.gz",
        "chown -R ec2-user:ec2-user /opt/app",
        "cp node-app.service /etc/systemd/system/",
        "systemctl daemon-reload",
        "systemctl enable node-app",
        "systemctl restart node-app"
    ]'
