# Threat Telemetry Analysis: Database vs. Identity Compromise

## Executive Context: The Dual-Plane Threat Model
These two findings demonstrate the fundamental difference between attacking a cloud workload (Data Plane) and attacking the cloud environment itself (Control Plane). 

* **The RDS Finding (Data Plane):** Represents an application-layer data breach. The attacker obtained valid database credentials (via leak or brute-force) and bypassed network perimeters to access the database directly. Their access is restricted to the permissions of that specific database user, but the data itself is highly vulnerable.
* **The IAM Finding (Control Plane):** Represents an infrastructure-layer breach. The attacker extracted temporary AWS API credentials from an EC2 instance and exported them outside the AWS network. This has a severe blast radius; the attacker is no longer attacking the application, but manipulating the AWS environment itself (potentially creating resources, deleting backups, or pivoting to other services).

---

## 1. Database Compromise Vector (Data Plane)
**Finding Type:** `CredentialAccess:RDS/AnomalousBehavior.SuccessfulLogin`

### Schema Dissection
* **`Resource.RdsDbInstanceDetails`**: Identifies the specific target database cluster, including the engine type (e.g., PostgreSQL in our case) and the specific database user account involved in the breach.
* **`Service.Action.RdsLoginAttemptAction`**: Captures the mechanics of the attack. It logs the anomalous caller IP, the client application utilized, the SSL/TLS context, and crucially confirms the status as `SUCCESS`, elevating the severity of the alert to critical.

### MITRE ATT&CK Mapping
* **T1078 (Valid Accounts):** The adversary bypassed external network defenses by utilizing a valid, compromised database credential.
* **T1078.004 (Cloud Accounts):** The target resides within the cloud application layer, accessed directly over the network via credential stuffing or leakage.

---

## 2. Identity Compromise Vector (Control Plane)
**Finding Type:** `UnauthorizedAccess:IAMUser/InstanceCredentialExfiltration.OutsideAWS`

### Schema Dissection
* **`Resource.AccessKeyDetails`**: Identifies the compromised control-plane identity. It surfaces the compromised IAM role, the `accessKeyId`, and indicates that temporary session credentials (STS) from an EC2 instance were leaked.
* **`Service.Action.AwsApiCallAction`**: Captures the infrastructure manipulation. Logs the external malicious IP, the User-Agent (e.g., `Boto3`, `Kali Linux`, `aws-cli`), and the exact API call executed (e.g., `GetSecretValue` or `DescribeInstances`).

### MITRE ATT&CK Mapping
* **T1552.005 (Cloud Instance Metadata API):** The adversary extracted temporary STS credentials from an EC2 instance's IMDS.
* **T1530 (Data from Cloud Storage Object/Secret):** The adversary utilized the stolen identity to access secrets or data objects directly through the AWS API.

---

### Conclusion
While both vectors involve stolen credentials, their forensic footprints and containment strategies differ drastically. The RDS vector targets the **Data Plane** (applications/databases) and is logged under `rdsLoginAttemptAction`. The IAM vector targets the **Control Plane** (infrastructure layer) and is logged under `awsApiCallAction`.
