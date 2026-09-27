# Secure Multi-Tier AWS Architecture

## Overview
Secure Multi-Tier AWS Workload with Automated Threat Detection, Compliance Auditing & Event-Driven Incident Response.

The architecture touches: network segmentation, Zero Trust, Least Privilege, Encryption, Automated Threat Detection, Compliance Auditing & Event-Driven Incident Response.

## Architecture
- **Web Tier:** NGINX
- **App Tier:** Node.js
- **Database Tier:** Amazon RDS for PostgreSQL

![Architecture](architecture/architecture.png)
*Note: The architecture diagram shows 2 DB instances in 2 private subnets, but 
for the seek of simplicity and for more control on the cost we used just one instance. 
Feel free to modify `terraform/database/main.tf` to add a second one (or just set
multi_az = true).*

## Data flow

![Diagram](architecture/data-flow.png)

## Security Controls
(Refer to `docs/security-controls.md` for more details)
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
(Refer to `docs/threat-model.md` for more details)
1. Network Isolation
2. Configuration Drift & Automated Remediation
3. Security Incident Response


## Tests and Operations


You'll find all tests, procedures, and outputs in `evidence/`.
Check the test you want to run depending on the module. All instructions are provided.

Check `app/` to modify the web app (`app/web`) or the backend (`app/app`).

Check `Lambda/incident-response` to test the logic of the Lambda function locally.

<br>

If you have any other inquiry, feel free to reach me out ;)

<br>

										           AKO 2026
