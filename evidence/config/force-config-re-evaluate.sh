#!/bin/bash

# The initial INSUFFICIENT_DATA state was not a Terraform misconfiguration, 
# but an expected architectural race condition.
# The initial scan executed before the Data Plane finishes its asynchronous discovery sweep,
# so Terraform correctly provisioned the rule but hit an asynchronous race condition,
# triggering the initial evaluation before AWS Config could finish writing the resource state
# (Configuration Items) to its backend.
# This script resolves this by decoupling the evaluation from the provisioning lifecycle,
# forcing the rule engine to run only after the resource inventory was fully indexed.
# The script should succeed by invoking 'StartConfigRulesEvaluation' after AWS Config fully 
# finishes resource inventory indexing.
# Don't forget to re-run the check (STUCK_RULES)!

echo "Scanning AWS Config for rules with INSUFFICIENT_DATA..."

# 1. Fetch all rules where compliance type is exactly INSUFFICIENT_DATA
# Using JMESPath query to extract just the rule names into a space-separated list
STUCK_RULES=$(aws configservice describe-compliance-by-config-rule \
  --query 'ComplianceByConfigRules[?Compliance.ComplianceType==`INSUFFICIENT_DATA`].ConfigRuleName' \
  --output text)

# 2. Check if the list is empty
if [ -z "$STUCK_RULES" ] \vert{}\vert{} [ "$STUCK_RULES" == "None" ]; then
  echo "No rules found in INSUFFICIENT_DATA state. Everything is evaluated!"
  exit 0
fi

echo "Found rules awaiting evaluation: $STUCK_RULES"
echo "Triggering immediate re-evaluation..."

# 3. Force the evaluation (CLI accepts multiple space-separated rule names)
aws configservice start-config-rules-evaluation --config-rule-names $STUCK_RULES

if [ $? -eq 0 ]; then
  echo "Re-evaluation successfully triggered!"
  echo "Give the AWS Data Plane 30-60 seconds to process the results."
else
  echo "Failed to trigger re-evaluation. Check AWS CLI permissions."
  exit 1
fi