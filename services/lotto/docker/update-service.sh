#!/bin/bash

# for lambda
# aws lambda update-function-code --function-name ${lambda-function-arn} --image-uri ${image-uri} --region=${aws-region}

# for ecs service
# if you new container image push to ecr
aws ecs update-service --cluster demobtc-an2t-ecs --service lotto --force-new-deployment
