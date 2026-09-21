  

# Security Control Matrix

  

## Objective

Establish the baseline traceability matrix that connects identified threats to implemented security controls, their AWS configurations, and the exact evidence artifacts required to validate them for the portfolio.

  

## Traceability Matrix

  

| Threat / Risk | Security Control Objective | AWS Service / Mechanism | Target Configuration / Rule | Evidence Artifact to Capture |
| :--- | :--- | :--- | :--- | :--- |
| **Unauthorized lateral movement & direct exposure** | Restrict traffic flow between tiers (least privilege network access). | VPC / Security Groups | Web → App → DB allowed.<br>Internet → App/DB blocked.<br>No `0.0.0.0/0` on backend. | 1. Terraform network definitions.<br>2. Reachability test logs (`curl`/`nc`) proving backend isolation. |
| **Application layer attacks (SQLi, XSS)** | Inspect and block malicious HTTP/S payloads before they reach the compute tier. | AWS WAF | AWS WAF Web ACL containing AWS Managed Core Rule Set (blocking SQLi/XSS). | CloudWatch logs / WAF metrics showing a blocked simulated SQLi request. |
| **Hardcoded or leaked database credentials** | Securely store, dynamically retrieve, monitor usage, and regularly rotate database credentials. | Secrets Manager + KMS + GuardDuty | Secret encrypted via Customer Managed KMS Key (CMK), IAM Role access only, auto-rotation configured. GuardDuty RDS Protection (`RDS_LOGIN_EVENTS`) actively monitoring for `CredentialAccess:RDS/AnomalousBehavior.SuccessfulLogin`. | 1. CloudTrail logs of KMS decryption.<br>2. Secret rotation execution logs.<br> 3.`evidence/guardduty/leaked-db-credential-finding.json` |
| **Unattributed infrastructure changes / unauthorized API calls** | Record all management events comprehensively and ensure logs cannot be tampered with. | CloudTrail + S3 | Multi-region trail enabled, capturing management events, S3 log file integrity validation enabled. | 1. S3 bucket structure showing logs.<br>2. CloudTrail log file validation digest file. <br> Take a look at `evidence/cloudtrail/` |
| **EC2 compromise, anomalous IAM activity, reconnaissance** | Continuously monitor environment for malicious activity and aggregate findings centrally. | GuardDuty | GuardDuty analyzing CloudTrail Management Events and VPC Flow Logs. Actively monitoring for `UnauthorizedAccess:IAMUser/InstanceCredentialExfiltration.OutsideAWS` and `Recon:EC2/PortProbeUnprotectedPort`. | 1. JSON export/screenshot of finding natively in Security Hub. <br> 2. `evidence/guardduty/leaked-iam-credential-finding.json` |
| **Configuration drift (e.g., exposed SSH, unencrypted data)** | Continuously evaluate EC2, SG, S3 configurations against organizational security baselines. | AWS Config + SSM Automation remediation | Active managed rules: `restricted-ssh`  ,  `s3-bucket-public-read-prohibited` , `ec2-imdsv2-check` . | AWS Config timeline showing a resource transitioning from COMPLIANT to NON_COMPLIANT.<br> SSM Automation remediation (eg. `evidence/config/restricted-ssh-remediation/`) |
| **Persistent storage (EBS,RDS) and Root Access Key misconfiguration** | Continuously evaluate EBS, RDS, Access Key configurations against organizational security baselines. | AWS Config | Active managed rules: `ebs-encrypted-volumes` , `rds-storage-encrypted` , `iam-root-access-key-check`. | We leave EBS, RDS, and Root Keys as "Alert Only" (Detective) controls. Cuz these are critical resources (any error may significantly harm the business). <br> Detect misconfiguration then proceed with  manual intervention and human change-management approval.|
| **Active compromise of IAM credentials or compute resources** | Automatically isolate compromised infrastructure or disable identities upon threat detection. | EventBridge + Lambda | EventBridge rule matching GuardDuty finding → triggers Lambda → Lambda applies `DenyAll` policy / disables key. | CloudTrail logs proving Lambda executed IAM revocation API calls (`UpdateAccessKey` / `PutUserPolicy`). |
| **Security Posture & Findings Aggregation** | Centralize threat detection, normalize finding formats, and continuously audit cloud posture against established baselines. | AWS Security Hub | Subscribed strictly to AWS Foundational Security Best Practices (FSBP) v1.0.0 to control costs and alert fatigue. All GuardDuty telemetry automatically routed and normalized into AWS Security Finding Format (ASFF). | 1. Security Hub Dashboard. <br> 2. `evidence/security-hub/sample-asff-finding.json` |
