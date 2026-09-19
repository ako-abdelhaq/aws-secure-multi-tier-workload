# Use this from local machine

# Verify that ClouTrail started logging
aws cloudtrail get-trail-status --name workload-audit-trail

# 1. Get your AWS Account ID dynamically
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>&1)

if [ -z "$ACCOUNT_ID" ]; then
    echo -e "Error: Could not retrieve AWS Account ID."
    exit 1
fi

# 2. Trigger a 'PutBucketTagging' API event
aws s3api put-bucket-tagging \
  --bucket sec-app-cloudtrail-logs-$ACCOUNT_ID \
  --tagging 'TagSet=[{Key=TestEvent,Value=Triggered}]'

# 3. Wait for CloudTrail delivery cycle (~5 minutes) and check CloudTrail for the triggered event

aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=PutBucketTagging \
  --max-items 3

# Expected output a log with eventName "PutBucketTagging" and the following tagging under requestParameters
#   "TagSet": {
#        "Tag": {
#            "Value": "Triggered",
#            "Key": "TestEvent"
#        }
#    }

# 4. Cryptographic validation 
# In this step we'll have to wait for about 1h for AWS t generate the digest files

# Get your current AWS Region
REGION=$(aws configure get region)

# Construct the exact Trail ARN
TRAIL_ARN="arn:aws:cloudtrail:${REGION}:${ACCOUNT_ID}:trail/workload-audit-trail"

# Set a start time for 2 hours ago (UTC format is required)
# Use this for Linux:
START_TIME=$(date -u -d '2 hours ago' +%Y-%m-%dT%H:%M:%SZ) 
# Use this for macOS:
# START_TIME=$(date -u -v-2H +%Y-%m-%dT%H:%M:%SZ)

# Run the integrity validation (After 1h)
aws cloudtrail validate-logs \
  --trail-arn $TRAIL_ARN \
  --start-time $START_TIME \
  --verbose