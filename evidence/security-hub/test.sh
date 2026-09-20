aws securityhub get-findings \
  --filters '{"ProductName":[{"Value": "GuardDuty","Comparison":"EQUALS"}]}' \
  --max-items 5 \
  --output json > evidence/security-hub/sample-asff-finding.json