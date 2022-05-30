# aws-fargate-magiclub
aws-fargate 클러스터를 구성하고 애플리케이션을 배포 합니다.

## Architecture
![](aws-arch-ecs-fargate-01.png)

### 주요 리소스 개요
- Route 53: 인터넷 사용자가 도메인 이름을 통해 서비스에 접근 합니다.
- VPC: 컴퓨팅 리소스를 배치하는 공간으로 네트워크 구성 및 네트워크 연결 리소스로 서로 통합 되어 있습니다.
- ALB: Route 53 으로부터 유입되는 트래픽을 요청에 대응하는 애플리케이션 서비스로 라우팅 합니다.
- ECS Fargate: 클러스터, 작업 정의, 서비스로 생성된 컨테이너 기반 애플리케이션 서비스를 제공 하는 컨테이너 서비스 입니다.
- ECS Task Definition: lotto 애플리케이션을 위한 작업 정의 입니다.
- ECS Service: lotto 애플리케이션을 위한 ECS 서비스 입니다.
- ECR: 컨테이너 (도커) 이미지를 등록 관리하는 레지스트리 서비스로 작업 정의에서 설정 됩니다.
- CloudWatch: ECS 애플리케이션 서비스의 로그를 수집 관리하는 로거 드라이브로 작업 정의를 통해 구성 합니다.
- IAM Role: 태스크를 정의하는 Role과 ECS 서비스를 실행하는 Role 을 작업 정의에서 설정 됩니다.
- Cloud Map: 컨테이너 애플리케이션을 위한 디스커버리 서비스로 Route 53 의 호스팅 정보가 사전에 구성되어 있어야 합니다.

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
