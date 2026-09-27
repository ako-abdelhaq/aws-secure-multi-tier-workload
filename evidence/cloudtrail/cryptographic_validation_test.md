## Cryptographic validation. 

In this step we'll have to wait for about 1h for AWS to generate the digest files.

*Required: Execute the instructions in `test_cloudtrail.md` first.*

<br>

1. Construct the exact Trail ARN:
    ```bash
    TRAIL_ARN="arn:aws:cloudtrail:${AWS_REGION}:${ACCOUNT_ID}:trail/workload-audit-trail"
    ```

2. Set a start time for 2 hours ago (UTC format is required). Use this for Linux:

    ```bash
    START_TIME=$(date -u -d '2 hours ago' +%Y-%m-%dT%H:%M:%SZ) 
    ```


3. Run the integrity validation (After 1h):

    ```bash
    aws cloudtrail validate-logs \
    --trail-arn $TRAIL_ARN \
    --start-time $START_TIME \
    --verbose
    ```