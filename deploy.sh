#!/bin/bash

echo "terraform init"

terraform -chdir=vpc init && \
terraform -chdir=alb init && \
terraform -chdir=ecs init && \
terraform -chdir=services/lotto init && \
terraform -chdir=services/hello init

echo "terraform apply"
terraform -chdir=vpc apply -var-file=../terraform.tfvars -auto-approve && \
terraform -chdir=alb apply -var-file=../terraform.tfvars -auto-approve && \
terraform -chdir=ecs apply -var-file=../terraform.tfvars -auto-approve && \
terraform -chdir=services/lotto apply -var-file=../../terraform.tfvars -auto-approve && \
terraform -chdir=services/hello apply -var-file=../../terraform.tfvars -auto-approve
