#!/bin/bash

SECONDS=0

cd ./terraform

terraform init

if [ $? -ne 0 ]; then
  echo "Terraform init failed with exit code $?"
  exit 1
fi
echo

terraform validate

if [ $? -ne 0 ]; then
  echo "Terraform validate failed with exit code $?"
  exit 1
fi

terraform apply -auto-approve

if [ $? -ne 0 ]; then
  echo "Terraform apply failed with exit code $?"
  exit 1
fi

export AWS_REGION=$(terraform output -raw aws_region)
export ALB_ARN=$(terraform output -raw alb_arn)
export ALB_DNS_NAME=$(terraform output -raw alb_dns_name)
export ARTIFACT_BUCKET_NAME=$(terraform output -raw artifact_bucket_name)
export DB_ENDPOINT=$(terraform output -raw db_endpoint)
export BD_USER=$(terraform output -raw db_master_username)
export DB_SECRET_ARN=$(terraform output -raw db_secret_arn)
export LOGGING_BUCKET_NAME=$(terraform output -raw logging_bucket_name)
export PROJECT_PREFIX=$(terraform output -raw project_prefix)
export PUBLIC_SUBNET_IDS=$(terraform output -json public_subnet_ids | tr -d '[]"\n ')
export VPC_ID=$(terraform output -raw vpc_id)
export WAF_ARN=$(terraform output -raw waf_arn)
export WAF_ID=$(terraform output -raw waf_id)
export WAF_NAME=$(terraform output -raw waf_name)

cd ..
source ./app/app/build.sh $ARTIFACT_BUCKET_NAME

minutes=$(( SECONDS / 60 ))
seconds=$(( SECONDS % 60 ))
printf "Script executed in: %02d:%02d.\n" $minutes $seconds