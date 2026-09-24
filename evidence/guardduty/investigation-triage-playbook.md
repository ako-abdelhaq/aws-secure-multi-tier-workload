# SOC Triage Playbook

## Playbook: Incident Response — Leaked Database Credential

**Trigger:** GuardDuty Alert `CredentialAccess:RDS/AnomalousBehavior.SuccessfulLogin` or `CredentialAccess:RDS/MaliciousIPCaller.SuccessfulLogin`
**Severity:** CRITICAL
**Objective:** Identify the blast radius, sever attacker access, and rotate compromised data-plane credentials without causing a complete application outage.

*Note: The playbook documents the L2/L3 manual triage and containment logic (what must happen and in what order). In the production environment, we mapped this exact sequence into an automated pipeline (eg EventBridge-to-Lambda).*

---

### Phase 1: Identification & Triage

**1. Identify Compromised DB User & Target**
* **Action:** Inspect the GuardDuty finding JSON schema.
* **Extraction:** Review the `Resource.RdsDbInstanceDetails` block.
* **Data to Capture:** 
  * Target Database Identifier (ARN)
  * Engine Type (e.g., PostgreSQL)
  * Compromised Database User (`dbUser`)
<br>
<br>

**2. Determine Ingress Path (Network vs. Pivot)**
* **Action:** Determine how the attacker reached the database.
* **Extraction:** Review `Service.Action.RdsLoginAttemptAction.RemoteIpDetails`.
* **Decision Tree:**
  * **Direct External IP:** Indicates a severe perimeter failure. The database Security Group is misconfigured (e.g., `0.0.0.0/0` exposed on port 5432).
  * **Internal IP (VPC):** Indicates an internal pivot. The attacker has likely compromised an EC2 App Instance or a bastion host inside the network, bypassed the network perimeter, and is attacking laterally.
<br>

---

### Phase 2: Investigation & Blast Radius

**3. Correlate with PostgreSQL Audit Logs**
* **Action:** Determine exactly what data the attacker accessed or altered.
* **Procedure:** 
  1. Navigate to AWS CloudWatch Logs for the affected RDS instance.
  2. Query the PostgreSQL audit logs using the compromised `dbUser` and the timestamp immediately following the GuardDuty alert.
  3. Look for data exfiltration (`SELECT * FROM users`), destructive actions (`DROP TABLE`), or privilege escalation attempts.

---

### Phase 3: Containment Protocol

*Warning: Execution sequence is critical. Do not terminate sessions before rotating the secret, or the attacker's automated scripts will immediately reconnect.*


**Step 1: Rotate Master Secret** 
* **Action:** Invalidate the compromised password to prevent new connections. **Command:** Trigger an immediate, out-of-band rotation via AWS Secrets Manager: `aws secretsmanager rotate-secret --secret-id <SECRET_ARN>` 

**Step 2: Revoke Active Sessions** 
* **Action:** Sever the attacker's current live connection to the database. 
  **Command:** Connect to the database using an uncompromised administrative account and aggressively terminate the compromised user's backend processes: `SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE usename = '<COMPROMISED_USER>';` 

**Step 3: Isolate Network Path** 
* **Action:** Close the network vulnerability that allowed the ingress. 
  **Command:** Verify the RDS Security Group rules. Strip any unauthorized ingress rules. Ensure port 5432 only accepts ingress traffic originating explicitly from the Application Tier Security Group ID.

### The Security Engineering Behind This Playbook: 
the order of operations in the Containment Phase. Notice how the playbook explicitly states to rotate the secret *before* killing the active database sessions. If you kill the session while the compromised password is still valid, the attacker's automated script will simply re-authenticate and reconnect 50 milliseconds later. By rotating the secret in AWS Secrets Manager first (Step 1), we change the locks on the door. Then, when we terminate the active backend processes in Postgres (Step 2), the attacker gets kicked out and is physically unable to log back in. Finally, locking down the Security Group (Step 3) ensures that even if they find another credential, their network path is blocked.

