#!/bin/bash

echo "terraform init"

terraform -chdir=vpc init && \
terraform -chdir=alb init && \
terraform -chdir=fargate init && \
terraform -chdir=services/lotto init

echo "terraform destroy"
terraform -chdir=services/lotto destroy -var-file=../../terraform.tfvars -var-file=./terraform.tfvars -auto-approve && \
terraform -chdir=fargate destroy -var-file=../terraform.tfvars -auto-approve && \
terraform -chdir=alb destroy -var-file=../terraform.tfvars -auto-approve && \
terraform -chdir=vpc destroy -var-file=../terraform.tfvars -auto-approve

