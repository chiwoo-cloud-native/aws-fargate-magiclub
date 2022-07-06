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
AWS ECS Fargate 서비스를 프로비저닝 하기 위해 다음의 Tool 들을 설치하고 Domain 서비스를 사전에 구성이 되어 있어야 합니다.
- [Terraform 설치](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [AWS CLI 설치](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/getting-started-install.html)
- [AWS Profile 구성](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/cli-configure-files.html)
- [Docker 설치](https://docs.docker.com/desktop/mac/install/)
- [Mac OS 개발자를 위한 로컬 개발 환경 구성](https://symplesims.github.io/development/setup/macos/2021/12/02/setup-development-environment-on-macos.html) 가이드를 참고하여 편리하게 구성할 수 있습니다. 
- [AWS Route53 도메인 서비스 관리](https://symplesims.github.io/devops/route53/acm/hosting/2022/04/09/aws-route53.html) 가이드를 참고하여 도메인 가입 및 Route53 을 구성 할 수 있습니다. 


## Build
아래 명령을 통해 ECS Fargate 관련 클라우드 리소스 뿐만 아니라 lotto 애플리케이션이 한번에 프로비저닝 됩니다.

```
sh deploy.sh
```

## Check

### cURL 서비스 Health 체크 
도메인을 `sympledemo.tk` 으로 설정 하였다면 `https://lotto.sympledemo.tk` 으로 서비스 앤드포인트로 액세스 할 수 있습니다.

```
curl --location -X GET 'https://lotto.sympledemo.tk/health'
```

### cURL 서비스 로또 번호 추천 
```
curl --location -X GET 'https://lotto.sympledemo.tk/api/lotto/lucky' -H 'Content-Type: application/json'
```

### AWS CloudWatch 로그 그룹의 로그 확인 
```
aws logs tail /ecs/magiclub-an2p-ecs-lotto --since 1s --follow

-------------
2022-07-06T08:49:07.117000+00:00 magiclub-an2p-ecs-lotto/magiclub-an2p-ecs-lotto/8da960d491c0453aa90c3b9f39504d2a 2022-07-06 08:49:07.116  INFO 8 --- [or-http-epoll-4] ttoRouterFunction$LottoHandler$Companion : result: [2, 5, 22, 25, 32, 38]
2022-07-06T08:49:08.562000+00:00 magiclub-an2p-ecs-lotto/magiclub-an2p-ecs-lotto/8da960d491c0453aa90c3b9f39504d2a 2022-07-06 08:49:08.560  INFO 8 --- [or-http-epoll-4] ttoRouterFunction$LottoHandler$Companion : result: [13, 21, 32, 33, 39, 45]
```

## Destroy
아래 명령을 통해 ECS Fargate 관련 클라우드 리소스 및 lotto 애플리케이션이 한번에 제거 합니다.

```
sh destroy.sh
```


## Appendix

### Docker 호스트 확인
애플리케이션 컨테이너 이미지 빌드를 위해 도커 이미지를 빌드 할 수 있는 [Docker Terraform 프로바이더](https://registry.terraform.io/providers/kreuzwerker/docker/latest) 를 추가 하였습니다.

- [providers.tf](./services/lotto/providers.tf)

```
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "= 2.16.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}
```

위의 설정 파일에서 docker host 는 사용자마다 다를 수 있습니다.
먼저 docker 데몬이 구동 되어 있어야 하며, docker context ls 를 통해 현재 docker 앤드포인트가 무엇인지 DOCKER ENDPOINT 값을 확인하세요.  
그리고 provider "docker" 리소스의 host 속성 값을, 현재 사용중인 ENDPOINT 로 설정 합니다. 

```
docker context ls

NAME        DESCRIPTION                               DOCKER ENDPOINT                        KUBERNETES ENDPOINT   ORCHESTRATOR
default *   Current DOCKER_HOST based configuration   unix:///var/run/docker.sock                                  swarm
```

DOCKER_HOST 환경 변수를 설정하면 docker CLI 로 액세스할 docker 컨텍스트를 지정 할 수 있습니다.
```
export DOCKER_HOST="unix:///var/run/docker.sock" 
```
