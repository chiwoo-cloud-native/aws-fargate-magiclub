#!/bin/bash

echo "terraform init"

terraform -chdir=vpc init && \
terraform -chdir=alb init && \
terraform -chdir=fargate init && \
terraform -chdir=services/lotto init

echo "terraform apply"
terraform -chdir=vpc apply -var-file=../terraform.tfvars -auto-approve && \
terraform -chdir=alb apply -var-file=../terraform.tfvars -auto-approve && \
terraform -chdir=fargate apply -var-file=../terraform.tfvars -auto-approve && \
terraform -chdir=services/lotto apply -var-file=../../terraform.tfvars -var-file=./terraform.tfvars -auto-approve
