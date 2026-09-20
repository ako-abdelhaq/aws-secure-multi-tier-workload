# ASFF (AWS Security Finding Format) Anatomy Analysis

## Objective
To enable automated Security Orchestration, Automation, and Response (SOAR), a centralized SOC cannot parse dozens of different proprietary log formats (GuardDuty, Inspector, Macie, Firewall Manager, etc.). AWS Security Hub solves this by ingesting diverse security signals and normalizing them into a single, predictable JSON schema: the AWS Security Finding Format (ASFF).

Below is the technical breakdown of the critical ASFF normalization fields required for downstream SOC automation:

### 1. SchemaVersion & Id (The Universal Key)
* **`SchemaVersion`**: Enforces a strict, version-controlled JSON structure (e.g., `2018-10-08`). If AWS updates a security tool, your downstream Python/Lambda parsers won't break because the ASFF contract remains stable.
* **`Id`**: A globally unique Amazon Resource Name (ARN) for this specific finding across the entire AWS ecosystem. When your automated Lambda containment script finishes mitigating a threat, it uses this exact `Id` to call the Security Hub API and close the ticket.

### 2. ProductArn & GeneratorId (Attribution & Routing)
* **`ProductArn`**: Identifies exactly which security tool generated the alert (e.g., `arn:aws:securityhub:...:product/aws/guardduty`&rarr; GuardDuty).
* **`GeneratorId`**: Identifies the specific rule, detector, or engine that fired (e.g., the GuardDuty Threat Intel set or an Inspector CVE check).
* **SOC Value**: This allows EventBridge to route alerts to different teams. For example, `ProductArn = Macie` routes to the Data Privacy team, while `ProductArn = GuardDuty` routes to the L2 Incident Response team.

### 3. Severity.Normalized vs. Severity.Label (Unified Triage Logic)
* **The Problem**: GuardDuty scores threats from `0.1` to `10.0`. AWS Inspector uses CVSS scores. Macie uses custom text labels. 
* **The ASFF Solution**: 
  * `Severity.Normalized`: Maps every provider's unique scoring system into a universal `0 - 100` integer scale.
  * `Severity.Label`: Standardizes the text string into `INFORMATIONAL`, `LOW`, `MEDIUM`, `HIGH`, or `CRITICAL`.
* **SOC Value**: You only have to write your SOAR logic once. Example: `if Severity.Normalized > 70 { Page_OnCall_Engineer() }`. 

### 4. Resources Array (Standardized Blast Radius)
* **Structure**: An array containing `Type`, `Id`, `Partition`, `Region`, and `Tags`.
* **SOC Value**: Regardless of whether the compromised asset is an S3 bucket, an IAM user, or an RDS instance, your automation knows exactly where to look to find the affected asset. Furthermore, ASFF automatically pulls in the asset's AWS Tags. If your automation sees `"Tags": {"Environment": "Production"}`, it can instantly escalate the priority of the alert.

### 5. Workflow.Status & RecordState (State Management)
* **`Workflow.Status`**: Tracks human and automated operational states (`NEW`, `NOTIFIED`, `RESOLVED`, `SUPPRESSED`). This prevents multiple analysts from working on the same active incident.
* **`RecordState`**: Tracks the physical reality of the threat (`ACTIVE` or `ARCHIVED`). 
* **SOC Value**: If an analyst changes `Workflow.Status` to `RESOLVED`, but the attacker is still logged into the database, GuardDuty will see the ongoing threat and flip `RecordState` back to `ACTIVE`, automatically re-opening the investigation.
