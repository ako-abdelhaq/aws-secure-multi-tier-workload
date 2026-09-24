cd ./terraform
terraform init
terraform validate
terraform apply -auto-approve

export AWS_REGION=$(terraform outout -ram aws_region)
export ALB_ARN=$(terraform output -raw alb_arn)
export ALB_DNS_NAME=$(terraform output -raw alb_dns_name)
export ARTIFACT_BUCKET_NAME=$(terraform output -raw artifact_bucket_name)
export DB_ENDPOINT=$(terraform output -raw db_endpoint)
export DB_SECRET_ARN=$(terraform output -raw db_secret_arn)
export LOGGING_BUCKET_NAME=$(terraform output -raw logging_bucket_name)
export PROJECT_PREFIX=$(terraform output -raw project_prefix)
export PUBLIC_SUBNET_IDS=$(terraform output -json public_subnet_ids | tr -d '[]"\n ')
export VPC_ID=$(terraform output -raw vpc_id)
export WAF_ARN=$(terraform output -raw waf_arn)
export WAF_ID=$(terraform output -raw waf_id)
export WAF_NAME=$(terraform output -raw waf_name)

if [ $? -ne 0 ]; then
  echo "Terraform failed with exit code $?"
  exit 1
fi

cd ..
source ./app/app/build.sh $ARTIFACT_BUCKET_NAME
