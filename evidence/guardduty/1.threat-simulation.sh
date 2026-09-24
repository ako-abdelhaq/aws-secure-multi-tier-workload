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

echo "Verifying detector parameters..."

aws guardduty get-detector --detector-id $DETECTOR_ID --output json
# You should see the detector with the options looking like this:
# "Features": [
#         {
#             "Name": "CLOUD_TRAIL",
#             "Status": "ENABLED",
#             "UpdatedAt": "2026-09-20T15:26:29+02:00"
#         },
#         {
#             "Name": "DNS_LOGS",
#             "Status": "ENABLED",
#             "UpdatedAt": "2026-09-20T15:26:29+02:00"
#         },
#         {
#             "Name": "FLOW_LOGS",
#             "Status": "ENABLED",
#             "UpdatedAt": "2026-09-20T15:26:29+02:00"
#         },
#         {
#             "Name": "S3_DATA_EVENTS",
#             "Status": "ENABLED",
#             "UpdatedAt": "2026-09-20T15:23:52+02:00"
#         },
#         {
#             "Name": "EKS_AUDIT_LOGS",
#             "Status": "DISABLED",
#             "UpdatedAt": "2026-09-20T15:16:27+02:00"
#         },
#         {
#             "Name": "EBS_MALWARE_PROTECTION",
#             "Status": "DISABLED",
#             "UpdatedAt": "2026-09-20T15:16:27+02:00"
#         },
#         {
#             "Name": "RDS_LOGIN_EVENTS",
#             "Status": "ENABLED",
#             "UpdatedAt": "2026-09-20T15:05:36+02:00",
#             "AdditionalConfiguration": []
#         },
#         {
#             "Name": "AI_PROTECTION",
#             "Status": "DISABLED",
#             "UpdatedAt": "2026-09-20T14:37:38+02:00"
#         },
#         {
#             "Name": "AI_ANALYST",
#             "Status": "DISABLED",
#             "UpdatedAt": "2026-09-20T14:37:38+02:00"
#         },
#         {
#             "Name": "EKS_RUNTIME_MONITORING",
#             "Status": "DISABLED",
#             "UpdatedAt": "2026-09-20T14:37:38+02:00",
#             "AdditionalConfiguration": [
#                 {
#                     "Name": "EKS_ADDON_MANAGEMENT",
#                     "Status": "DISABLED",
#                     "UpdatedAt": "2026-09-20T14:37:38+02:00"
#                 }
#             ]
#         },
#         {
#             "Name": "LAMBDA_NETWORK_LOGS",
#             "Status": "DISABLED",
#             "UpdatedAt": "2026-09-20T15:16:27+02:00"
#         },
#         {
#             "Name": "RUNTIME_MONITORING",
#             "Status": "DISABLED",
#             "UpdatedAt": "2026-09-20T14:37:38+02:00",
#             "AdditionalConfiguration": [
#                 {
#                     "Name": "EKS_ADDON_MANAGEMENT",
#                     "Status": "DISABLED",
#                     "UpdatedAt": "2026-09-20T14:37:38+02:00"
#                 },
#                 {
#                     "Name": "ECS_FARGATE_AGENT_MANAGEMENT",
#                     "Status": "DISABLED",
#                     "UpdatedAt": "2026-09-20T14:37:38+02:00"
#                 },
#                 {
#                     "Name": "EC2_AGENT_MANAGEMENT",
#                     "Status": "DISABLED",
#                     "UpdatedAt": "2026-09-20T14:37:38+02:00"
#                 }
#             ]
#         }
#     ]
# }

echo "Injecting simulated attacks..."

aws guardduty create-sample-findings \
  --detector-id "$DETECTOR_ID" \
  --finding-types \
    "CredentialAccess:RDS/AnomalousBehavior.SuccessfulLogin" \
    "CredentialAccess:RDS/MaliciousIPCaller.SuccessfulLogin" \
    "UnauthorizedAccess:IAMUser/InstanceCredentialExfiltration.OutsideAWS" \
    "Stealth:IAMUser/CloudTrailLoggingDisabled" \
    "Recon:EC2/PortProbeUnprotectedPort"

#Injecting simulated security events spanning critical phases of the cloud attack lifecycle:

#Reconnaissance: Recon:EC2/PortProbeUnprotectedPort simulates an external adversary scanning your network for open, vulnerable ports.

#Defense Evasion: Stealth:IAMUser/CloudTrailLoggingDisabled models an attacker attempting to cover their tracks by disabling your audit trails.

#Credential Theft & Exfiltration: UnauthorizedAccess:IAMUser/InstanceCredentialExfiltration.OutsideAWS simulates the severe risk of EC2 instance profile credentials 
#(from the Instance Metadata Service) being stolen and used from an external IP address outside AWS.

#Database Compromise: CredentialAccess:RDS/AnomalousBehavior.SuccessfulLogin and CredentialAccess:RDS/MaliciousIPCaller.SuccessfulLogin simulate credential stuffing and unauthorized database access from known malicious infrastructure.

#These injected findings mirror the sequential steps an attacker takes during a real cloud breach.

echo "Attack simulation complete!"


echo "Fetching the latest Finding IDs for verification..."

aws guardduty list-findings \
  --detector-id "$DETECTOR_ID" \
  --max-items 5 \
  --query 'FindingIds' \
  --output table

# You can now take any of those IDs from the table and paste them directly into 
# aws guardduty get-findings <FINDING_ID> 
# to see the raw JSON telemetry, or simply log into the console to view them visually!