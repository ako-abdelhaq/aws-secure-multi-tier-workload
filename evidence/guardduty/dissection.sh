#!/bin/bash

set -e
DETECTOR_ID=""

echo "Searching for GuardDuty Detector tagged 'sec-app-detector'..."
# Look up using ARN (in case you have multiple detectors)
DETECTOR_ID=$(aws resourcegroupstaggingapi get-resources \
  --tag-filters Key=Name,Values=sec-app-detector \
  --resource-type-filters guardduty:detector \
  --query 'ResourceTagMappingList[*].ResourceARN' \
  --output text | grep -o '[^/]*$')

if [ -z "$DETECTOR_ID" ] || [ "$DETECTOR_ID" == "None" ]; then
    echo "Error: Could not find a GuardDuty detector with that tag."
    echo "Please ensure your Terraform apply completed successfully."
    exit 1
fi
echo "Found Detector ID: $DETECTOR_ID"

# Query the DB account takeover finding ID
DB_FINDING_ID=$(aws guardduty list-findings --detector-id $DETECTOR_ID \
  --finding-criteria '{"Criterion": {"type": {"Eq": ["CredentialAccess:RDS/AnomalousBehavior.SuccessfulLogin"]}}}' \
  --query "FindingIds[0]" --output text)

# Extract and save the raw JSON telemetry
aws guardduty get-findings \
  --detector-id $DETECTOR_ID \
  --finding-ids "$DB_FINDING_ID" \
  --output json > leaked-db-credential-finding.json

echo "Identity finding JSON extracted to evidence/guardduty/leaked-db-credential-finding.json"


# Query the IAM exfiltration finding ID
IAM_FINDING_ID=$(aws guardduty list-findings \
  --detector-id $DETECTOR_ID \
  --finding-criteria '{"Criterion": {"type": {"Eq": ["UnauthorizedAccess:IAMUser/InstanceCredentialExfiltration.OutsideAWS"]}}}' \
  --query "FindingIds[0]" --output text)

# Extract and save the raw JSON telemetry
aws guardduty get-findings \
  --detector-id $DETECTOR_ID \
  --finding-ids "$IAM_FINDING_ID" \
  --output json > leaked-iam-credential-finding.json

echo "Identity finding JSON extracted to evidence/guardduty/leaked-iam-credential-finding.json"