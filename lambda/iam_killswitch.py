import boto3
import logging
import json

# Initialize logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize IAM client
iam_client = boto3.client('iam')

def lambda_handler(event, context):
    logger.info(f"Received security event: {json.dumps(event)}")
    
    try:
        # 1. Parse the GuardDuty Finding Payload
        detail = event.get('detail', {})
        resource_info = detail.get('resource', {})
        resource_type = resource_info.get('resourceType')
        
        # Guard clause: Ensure we only act on IAM Access Key findings
        if resource_type != 'AccessKey':
            logger.warning(f"Ignored finding: Target is {resource_type}, not an AccessKey.")
            return
            
        access_key_details = resource_info.get('accessKeyDetails', {})
        user_name = access_key_details.get('userName')
        access_key_id = access_key_details.get('accessKeyId')
        
        if not user_name or not access_key_id:
            logger.error("Could not parse UserName or AccessKeyId from GuardDuty payload.")
            return

        logger.info(f"SECURITY ALERT: GuardDuty detected compromise of key {access_key_id} for user {user_name}. Initiating Kill Switch...")
        
        # 2. Execute Containment (The Kill Switch)
        iam_client.update_access_key(
            UserName=user_name,
            AccessKeyId=access_key_id,
            Status='Inactive'
        )
        
        logger.info(f"SUCCESS: Access key {access_key_id} successfully neutralized.")
        
        return {
            "statusCode": 200,
            "body": f"Neutralized key {access_key_id} for user {user_name}"
        }
        
    except Exception as e:
        logger.error(f"Failed to execute automated containment: {str(e)}")
        raise