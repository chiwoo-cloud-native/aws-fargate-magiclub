#!/bin/bash

# for lambda
# aws lambda update-function-code --function-name ${lambda-function-arn} --image-uri ${image-uri} --region=${aws-region}

# for ecs service
# if you new container image push to ecr
# aws ecs update-service --cluster magiclub-an2p-ecs --service magiclub-an2p-lotto-api-ecss --force-new-deployment
# aws ecs update-service --cluster magiclub-an2p-ecs --service magiclub-an2p-hello-api-ecss --force-new-deployment


