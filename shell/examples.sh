# terraform -chdir=services/lotto init
# terraform -chdir=services/lotto plan  -var-file=../../terraform.tfvars
# terraform -chdir=services/lotto apply -var-file=../../terraform.tfvars

# update ecs service
# aws ecs update-service --cluster magiclub-an2p-ecs --service magiclub-an2p-lotto-api-ecss --force-new-deployment

# tail ecs service logs
# aws logs tail /ecs/magiclub-an2p-lotto-api-ecss --since 1s --follow
