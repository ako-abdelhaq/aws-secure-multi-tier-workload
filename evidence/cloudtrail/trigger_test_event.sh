#!/bin/bash

# Use this from local machine

# Verify that ClouTrail started logging
aws cloudtrail get-trail-status --name workload-audit-trail

# Get your AWS Account ID dynamically
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>&1)

if [ -z "$ACCOUNT_ID" ]; then
    echo -e "Error: Could not retrieve AWS Account ID."
    exit 1
fi

# Trigger a 'PutBucketTagging' API event
aws s3api put-bucket-tagging \
  --bucket $LOGGING_BUCKET_NAME \
  --tagging 'TagSet=[{Key=TestEvent,Value="Ako Triggered"}]'
