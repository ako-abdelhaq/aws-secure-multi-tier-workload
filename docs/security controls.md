
# Security Control Matrix

## Objective
Establish the baseline traceability matrix that connects identified threats to implemented security controls, their AWS configurations, and the exact evidence artifacts required to validate them for the portfolio.

## Traceability Matrix

| Threat / Risk | Security Control Objective | AWS Service / Mechanism | Target Configuration / Rule | Evidence Artifact to Capture |
| :--- | :--- | :--- | :--- | :--- |
| **Unauthorized lateral movement & direct exposure** | Restrict traffic flow between tiers (least privilege network access). | VPC / Security Groups | Web → App → DB allowed.<br>Internet → App/DB blocked.<br>No `0.0.0.0/0` on backend. | 1. Terraform network definitions.<br>2. Reachability test logs (`curl`/`nc`) proving backend isolation. |
| **Application layer attacks (SQLi, XSS)** | Inspect and block malicious HTTP/S payloads before they reach the compute tier. | AWS WAF | AWS WAF Web ACL containing AWS Managed Core Rule Set (blocking SQLi/XSS). | CloudWatch logs / WAF metrics showing a blocked simulated SQLi request. |
| **Hardcoded or leaked database credentials** | Securely store, dynamically retrieve, and regularly rotate database credentials. | Secrets Manager + KMS | Secret encrypted via Customer Managed KMS Key (CMK), IAM Role access only, auto-rotation configured. | 1. Terraform secret/KMS definitions.<br>2. CloudTrail logs of KMS decryption.<br>3. Secret rotation execution logs. |
| **Unattributed infrastructure changes / unauthorized API calls** | Record all management events comprehensively and ensure logs cannot be tampered with. | CloudTrail + S3 | Multi-region trail enabled, capturing management events, S3 log file integrity validation enabled. | 1. S3 bucket structure showing logs.<br>2. CloudTrail log file validation digest file. |
| **EC2 compromise, anomalous IAM activity, reconnaissance** | Continuously monitor environment for malicious activity and aggregate findings centrally. | GuardDuty + Security Hub | GuardDuty active (VPC Flow Logs, CloudTrail analysis). Findings aggregated in Security Hub. | JSON export or console screenshot of a triggered sample GuardDuty finding natively in Security Hub. |
| **Configuration drift (e.g., exposed SSH, unencrypted data)** | Continuously evaluate resource configurations against organizational security baselines. | AWS Config | Active managed rules: `restricted-ssh`, `ec2-volume-inuse-check`, `s3-bucket-public-read-prohibited`. | AWS Config timeline showing a resource transitioning from COMPLIANT to NON_COMPLIANT. |
| **Persistent misconfigurations exposing infrastructure** | Automatically revert dangerous configuration drift without manual human intervention. | SSM Automation | EventBridge intercepts Config NON_COMPLIANT state → triggers SSM runbook (e.g., `AWS-DisablePublicAccessForSecurityGroup`). | SSM Automation Execution History showing successful removal of a non-compliant rule. |
| **Active compromise of IAM credentials or compute resources** | Automatically isolate compromised infrastructure or disable identities upon threat detection. | EventBridge + Lambda | EventBridge rule matching GuardDuty finding → triggers Lambda → Lambda applies `DenyAll` policy / disables key. | CloudTrail logs proving Lambda executed IAM revocation API calls (`UpdateAccessKey` / `PutUserPolicy`). |
