#!/bin/bash

echo "terraform init"

terraform -chdir=vpc init && \
terraform -chdir=alb init && \
terraform -chdir=ecs init && \
terraform -chdir=services/lotto init && \
terraform -chdir=services/hello init && \

echo "terraform destroy"
terraform -chdir=services/lotto destroy -var-file=../../terraform.tfvars -auto-approve && \
terraform -chdir=services/hello destroy -var-file=../../terraform.tfvars -auto-approve && \
terraform -chdir=ecs destroy -var-file=../terraform.tfvars -auto-approve && \
terraform -chdir=alb destroy -var-file=../terraform.tfvars -auto-approve && \
terraform -chdir=vpc destroy -var-file=../terraform.tfvars -auto-approve
