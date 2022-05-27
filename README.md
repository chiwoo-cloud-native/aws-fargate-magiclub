# aws-fargate-magiclub
aws-fargate 클러스터를 구성하고 애플리케이션을 배포 합니다.

## Build
```
terraform -chdir=vpc init && \
terraform -chdir=vpc plan && \
terraform -chdir=alb init && \ 
terraform -chdir=alb plan  
```
