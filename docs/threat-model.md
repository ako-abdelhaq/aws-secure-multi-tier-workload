
# Pragmatic Threat Model: Secure Multi-Tier AWS Architecture

## Objective
Identify realistic threat vectors against this specific multi-tier AWS architecture and map them to planned, cost-conscious security controls. The focus is on leveraging native AWS services (GuardDuty, Config, CloudTrail, WAF, SSM, Lambda, KMS) for detection and remediation without over-engineering.

## Threat Vector Mapping

| Layer | Threat Vector | Primary Detection | Containment / Remediation |
| :- | :--- | :--- | :--- |
| **Application** | SQL injection (SQLi), Cross-site scripting (XSS) | **AWS WAF** (Inline edge inspection). Logged via CloudWatch/CloudTrail. | **AWS WAF** (Managed rule groups block the request at the edge). |
| **Network** | Security group drift (e.g., unintended port 22 exposure) | **AWS Config** (Flags `restricted-ssh` as NON_COMPLIANT). | **SSM** (Automated Runbook triggered via EventBridge to remove rule). |
| **Network** | Unauthorized lateral movement (e.g., Web tier probing DB) | **GuardDuty** (Analyzes VPC Flow Logs for anomalous traffic). | **Lambda** (Triggered via EventBridge to isolate/quarantine EC2 instance). |
| **Identity** | Leaked database credentials | **GuardDuty** (RDS Protection detects anomalous login attempts). | **Lambda** (Forces immediate credential rotation via Secrets Manager & KMS). |
| **Identity** | Compromised access keys / privilege escalation | **GuardDuty** (Detects anomalous API calls) & **CloudTrail**. | **Lambda** (Disables compromised access key and revokes active STS sessions). |
| **Data** | Unencrypted data at rest (RDS, EBS, S3) | **AWS Config** (Flags missing encryption on new resources). | **SSM** (Auto-remediation runbook enforces KMS encryption). |
| **Data** | Public S3 bucket exposure | **AWS Config** (Flags `s3-bucket-public-read-prohibited`). | **SSM** (Applies "Block Public Access" settings directly to the bucket). |
| **Infrastructure** | Compromised EC2 instance (Crypto-mining, backdoors) | **GuardDuty** (Detects outbound connections to malicious IPs/domains). | **Lambda** (Quarantines instance) or **SSM** (Terminates malicious process). |
| **Infrastructure** | Unauthorized API operations | **CloudTrail** (Logs `AccessDenied`) & **GuardDuty** (Flags anomalous IAM). | **Lambda** (Revokes active IAM sessions for the offending role). |



## Core Scenarios Mapping

This threat model directly supports the following core security scenarios:

### Scenario 1: Network Isolation
* **Threat:** Unauthorized lateral movement & direct exposure (e.g., Internet bypassing Web tier to DB).
* **Preventative Control:** VPC Subnets and strict Security Group boundaries (Web -> App -> DB).
* **Mechanism:** **VPC** (Public/Private Subnets), **EC2** (Security Groups).

### Scenario 2: Configuration Drift
* **Threat:** Security group drift (unintended port 22 exposed to `0.0.0.0/0`).
* **Detection:** **AWS Config** (`restricted-ssh` managed rule).
* **Remediation:** **SSM** Automation runbook (`AWS-DisablePublicAccessForSecurityGroup`).
* **Mechanism:** **AWS Config** → **SSM Automation**.

### Scenario 3: Security Incident
* **Threat:** Compromised access keys / IAM role privilege escalation.
* **Detection:** **GuardDuty** (identifies anomalous API usage).
* **Aggregation:** **Security Hub** (ingests the GuardDuty finding).
* **Automated Response:** **EventBridge** → triggers **Lambda**.
* **Remediation:** **Lambda** (disables the compromised access key, applies explicit deny).
* **Evidence:** **CloudTrail** (logs the Lambda execution and IAM API calls).
* **Mechanism:** **GuardDuty** → **Security Hub** → **EventBridge** → **Lambda** (+ **CloudTrail**).

## Engineering Assumptions for Implementation
1. **Event Flow:** For automated remediation, the standard pipeline is: `Detection Source -> Security Hub -> EventBridge -> Target (Lambda/SSM)`.
2. **Safe Remediation:** Automated responses focus on *isolation* (removing bad rules, attaching quarantine groups, disabling keys) rather than destructive actions (terminating instances) to maintain a stable lab environment.
3. **Cost Control:** We rely on managed Config rules and native GuardDuty finding types. High-volume CloudTrail S3 data event logging is excluded unless specifically needed for a targeted test to minimize costs.
