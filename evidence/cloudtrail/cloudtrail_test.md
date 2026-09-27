## CloudTrail test

1. Run trigger_test_event.sh.

    ```bash
    source trigger_test_event.sh
    ```
<br>

2. Wait for the CloudTrail delivery cycle (approximately 5 minutes), then check CloudTrail for the triggered event.

    ```bash
    aws cloudtrail lookup-events \
    --lookup-attributes AttributeKey=EventName,AttributeValue=PutBucketTagging \
    --max-items 3
    ```
<br>

3. Expected output is a log with eventName "PutBucketTagging" and the following tagging under requestParameters:

    ```json
    "TagSet": {
        "Tag": {
            "Value": "Ako Triggered",
            "Key": "TestEvent"
        }
    }
    ```
<br>

4. Look for the file that contains the log record:

    ```bash
    year=$(date +%Y)
    ```
    ```bash
    month=$(date +%m)
    ```
    ```bash
    day=$(date +%d)
    ```
    ```bash
    aws s3 ls s3://$LOGGING_BUCKET_NAME/AWSLogs/$ACCOUNT_ID/CloudTrail/$AWS_REGION/$year/$month/$day/
    ```
<br>

5. Then look for the file with a time directly after the eventTime of the triggered event. Grab the log file containing the record (Follow the command but change `<LOG_FILENAME>` with the appropriate file name):

    ```bash
    aws s3 cp s3://$LOGGING_BUCKET_NAME/AWSLogs/$ACCOUNT_ID/CloudTrail/$AWS_REGION/$year/$month/$day/<LOG_FILENAME>.json.gz ./test_log.gz
    ```
    ```bash
    zcat ./test_log.gz | grep "PutBucketTagging"
    ```
<br>

6. Look at the output and search the log for eventName "PutBucketTagging" and the following tagging under requestParameters:

    ```json
    "TagSet": {
        "Tag": {
            "Value": "Ako Triggered",
            "Key": "TestEvent"
        }
    }
    ```
    Or look directly for "Ako Triggered":

    ```bash
    zcat ./test_log.gz | grep "Ako Triggered"
    ```
        