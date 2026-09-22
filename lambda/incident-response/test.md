1. Create a disposable IAM user and generate an access key. Copy the AccessKeyId from the output

aws iam create-user --user-name test-compromised-user
aws iam create-access-key --user-name test-compromised-user

2. You also must add mock.guardduty as a Source in GuardDuty-IAM-Credential-Compromise :
either from AWS console (in Amazon EventBridge Rules) or directly from Terraform, then apply
(resource "aws_cloudwatch_event_rule" "guardduty_iam_compromise").
Don't forget to remove it when the test finishes!!!!

3. Push the event directly to the default EventBridge bus. This simulates GuardDuty detecting credential exfiltration in real-time and immediately trips the EventBridge rule we built in Terraform. Replace YOUR_ACCESS_KEY_ID with the real key generated in Step 1. 
aws events put-events --entries '[{"EventBusName": "default", "Source": "mock.guardduty", "DetailType": "GuardDuty Finding", "Detail": "{\"type\":\"UnauthorizedAccess:IAMUser/InstanceCredentialExfiltration.OutsideAWS\",\"severity\":8.0,\"resource\":{\"resourceType\":\"AccessKey\",\"accessKeyDetails\":{\"userName\":\"test-compromised-user\",\"accessKeyId\":\"YOUR_NEW_ACCESS_KEY_ID\"}}}"}]'

4. Check the live status of the IAM user's access keys.
aws iam list-access-keys --user-name test-compromised-user
Look for "Status": "Inactive". The threat is contained.

5. Verify that the function successfully emitted the structured JSON log to CloudWatch. (This may take 5-10 seconds for the log stream to become available).
aws logs tail /aws/lambda/Security-Auto-Containment-IAM --since 1h

6. Delete the test user and its access key
aws iam delete-access-key --user-name test-compromised-user --access-key-id YOUR_ACCESS_KEY_ID
aws iam delete-user --user-name test-compromised-user

7. Don't forget to remove mock.guardduty from a Source in GuardDuty-IAM-Credential-Compromise !!!!
Take a look at step 2
