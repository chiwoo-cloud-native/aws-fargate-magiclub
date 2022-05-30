# aws-fargate-magiclub
aws-fargate 클러스터를 구성하고 애플리케이션을 배포 합니다.

## Build
```
terraform -chdir=vpc init && terraform -chdir=vpc apply -auto-approve && \
terraform -chdir=alb init && terraform -chdir=alb apply -auto-approve && \
terraform -chdir=fargate init && terraform -chdir=fargate apply -auto-approve && \
terraform -chdir=services/lotto init && terraform -chdir=services/lotto apply -auto-approve && \
```
