# Secure Multi-Tier AWS Architecture

## Project Overview
A secure, multi-tier AWS architecture focusing on cloud security, network segmentation, least privilege, encryption, threat detection, and automated incident response. This project is intentionally lean, built as a realistic security engineering lab without over-engineering.

## Architecture
- **Web Tier:** Node.js frontend/proxy
- **App Tier:** Node.js backend
- **Database Tier:** Amazon RDS for PostgreSQL (Private)

![Architecture](architecture/architecture.png)

![Diagram](architecture/data-flow.png)

## Security Controls
- **AWS WAF:** Layer 7 application protection
- **GuardDuty & Security Hub:** Threat detection and posture management
- **AWS Config:** Configuration compliance monitoring
- **Secrets Manager & KMS:** Secrets protection and encryption at rest
- **EventBridge, SSM & Lambda:** Automated remediation and incident response
- **CloudTrail:** Comprehensive auditing

## Setup Instructions
*(Requirements: aws, terraform)*

1. Execute `source ./scripts/deploy.sh`  (from the main directory).
2. Use `curl` to reach the app from the terminal: 
	eg. `curl $ALB_DNS_NAME/products`
	![Smoke_Test](docs/smoke-test.png)
3.  To clean up: `bash ./scripts/destroy.sh`  (from the project directory).


## Scenarios Demonstrated
1. Network Isolation
2. Configuration Drift & Automated Remediation
3. Security Incident Response
