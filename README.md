# aws-fargate-magiclub
aws-fargate 클러스터를 구성하고 애플리케이션을 배포 합니다.

## Pre-requisite
- Terraform 설치
- AWS CLI 환경 구성
- Docker 설치

## Build

```
terraform -chdir=vpc init && terraform -chdir=vpc apply -auto-approve && \
terraform -chdir=alb init && terraform -chdir=alb apply -auto-approve && \
terraform -chdir=fargate init && terraform -chdir=fargate apply -auto-approve && \
terraform -chdir=services/lotto init && terraform -chdir=services/lotto apply -auto-approve
```

## Check

### cURL 서비스 Health 체크 
```
curl --location -X GET 'https://lotto.mystarcraft.ml/health'
```

### cURL 서비스 로또 번호 추천 
```
curl --location -X GET 'https://lotto.mystarcraft.ml/api/lotto/lucky' -H 'Content-Type: application/json'
```

### AWS CloudWatch 로그 그룹의 로그 확인 
```
aws logs tail /ecs/magiclub-an2p-ecs-lotto --since 1s --follow
```

## Destroy

```
terraform -chdir=services/lotto init && terraform -chdir=services/lotto destroy -auto-approve && \
terraform -chdir=fargate init && terraform -chdir=fargate destroy -auto-approve && \
terraform -chdir=alb init && terraform -chdir=alb destroy -auto-approve && \
terraform -chdir=vpc init && terraform -chdir=vpc destroy -auto-approve
```
