import boto3
import json
from datetime import datetime, timezone

iam_client = boto3.client('iam')

def lambda_handler(event, context):
    # Parse incoming EventBridge Payload
    detail = event.get('detail', {})
    
    # Extract Threat Details
    # GuardDuty includes the finding ID inside the detail block
    finding_id = detail.get('id', event.get('id', 'unknown-id'))
    finding_type = detail.get('type', 'unknown-type')
    severity = detail.get('severity', 0.0)
    
    # Extract Target Identity
    resource_info = detail.get('resource', {})
    access_key_details = resource_info.get('accessKeyDetails', {})
    
    user_name = access_key_details.get('userName')
    access_key_id = access_key_details.get('accessKeyId')
    
    # Initialize the structured log payload
    log_entry = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "findingId": finding_id,
        "findingType": finding_type,
        "severity": severity,
        "targetPrincipal": user_name,
        "targetAccessKey": access_key_id,
        "containmentAction": "DeactivateAccessKey",
        "executionStatus": "PENDING"
    }

    # Guard Clause: Exit gracefully if identity data is missing
    if not user_name or not access_key_id:
        log_entry["executionStatus"] = "SKIPPED_MISSING_TARGET_DATA"
        print(json.dumps(log_entry)) # Emit structured log before exiting
        return {"statusCode": 400, "body": "Missing UserName or AccessKeyId in finding payload."}

    try:
        # Execute Automated Containment (The Kill Switch)
        # Deactivate the compromised access key
        iam_client.update_access_key(
            UserName=user_name,
            AccessKeyId=access_key_id,
            Status='Inactive'
        )
        
        # (Optional) If you wanted to attach a quarantine policy to kill active console sessions:
        # iam_client.attach_user_policy(
        #     UserName=user_name,
        #     PolicyArn='arn:aws:iam::aws:policy/AWSDenyAll' 
        # )
        
        # Update status to SUCCESS
        log_entry["executionStatus"] = "SUCCESS"
        
        # Emit the single-line structured JSON log to stdout
        print(json.dumps(log_entry))
        
        return {"statusCode": 200, "body": "Containment successful"}
        
    except Exception as e:
        # Catch errors, log the failure as structured JSON, then re-raise to fail the Lambda
        log_entry["executionStatus"] = "FAILED"
        log_entry["error_message"] = str(e)
        print(json.dumps(log_entry))
        raise
