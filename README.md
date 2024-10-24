# aws-fargate-magiclub

이 프로젝트는 Terraform 모듈을 사용하여 AWS ECS 서비스 및 여기에 관련된 AWS 리소스들과 샘플 애플리케이션 서비스를 한 번에 프로비저닝하는 데모 입니다.

AWS 클라우드를 활용하여 고객이 필요로 하는 애플리케이션 서비스를 DevOps 체계로 보다 빠르게 배포 하고 고객 피드백을 확인 할 수 있습니다.   

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

AWS ECS Fargate 서비스를 프로비저닝 하기 위해 다음의 Tool 들을 설치 해야 합니다.  
특히, Domain 서비스와 KMS 비대칭키를 사전에 구성 되어 있어야 하며, Docker 이미지를 빌드 할 수 있도록 Docker Daemon 이 구동되어 있어야 합니다.

### Bastion
Bastion 을 통해 EC2 인스턴스에 접속하여 작업을 수행 할 수 있습니다. 특히 SSM 에이전트가 구성되어 있다면 보다 안전하게 접속 할 수 있습니다.

```shell
aws ssm start-session --target INSTANCE_ID --profile symple
```


- [Terraform 설치](https://learn.hashicorp.com/tutorials/terraform/install-cli)

```
# root 사용자 전환 
sudo su - 

# tfswitch 설치
curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash

# ec2-user 로 전환
su - ec2-user

# tfswitch 를 통한 terraform v1.3.9 버전 설치
tfswitch

# terraform version 확인
terraform -version
```

- [SDKMAN 패키지 매니저 설치](https://sdkman.io/install)
```
curl -s "https://get.sdkman.io" | bash

# ec2-user 인 경우 
source "/home/ec2-user/.sdkman/bin/sdkman-init.sh"

# java 17 설치 
sdk install java 17.0.7-amzn

# version 확인
java -version

# maven 빌드툴 설치 
sdk install maven 3.9.0
```

 
- [AWS Profile 구성](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/cli-configure-files.html)

```
aws configure --profile symple

AWS Access Key ID [None]: ABCDEFGQQQQQQQ
AWS Secret Access Key [None]: ************
Default region name [None]: ap-northeast-2
Default output format [None]:

aws configure --profile symple --region ap-northeast-2
```

- [jq 설치](https://stedolan.github.io/jq/download/)
```
cd ~/bin
wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod +x ./jq
```

- [mfa.sh](./shell/mfa.sh) 쉘 파일을 통한 MFA 인증 
```shell
./mfa.sh symple
```

- [Docker 설치](https://docs.docker.com/desktop/mac/install/)
```
# docker 설치 
sudo yum install -y docker

# docker 데몬 확인 
sudo systemctl status docker

# docker 데몬 구동 
sudo systemctl start docker


sudo usermod -aG docker ec2-user
newgrp docker
```

- [AWS CLI 설치](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/getting-started-install.html)
- [AWS KMS 비대칭키 생성](https://docs.aws.amazon.com/ko_kr/kms/latest/developerguide/asymm-create-key.html)

### AWS CLI 를 통한 사전 구성 서비스 확인 
```
# domain 변수 값에 해당하는 public hosted-zone 이 구성되어 있는지 확인 합니다.  
aws route53 list-hosted-zones --profile symple

# domain 변수 값에 해당하는 ACM 인증서가 발급되어 있는지 확인 합니다.
aws acm list-certificates --profile symple

# kms 별칭에 해당하는 사용자 KMS 암호화 키가 구성되어 있는지 확인 합니다.
aws kms list-aliases --profile symple
```

### AWSServiceRoleForECS 서비스 연결 역할 
만약 최초로 ECS 클러스터를 구성 하는 것이라면, [Amazon ECS 용 서비스 연결 역할](https://docs.aws.amazon.com/ko_kr/AmazonECS/latest/developerguide/using-service-linked-roles.html) 을 생성해야 합니다.    
ECS 클러스터는 내부적으로 서비스 실행 및 리소스 관리를 위한 API 를 액세스 하기 위해서 ECS 서비스 연결 역할을 필요로 합니다.  

ECS 클러스터를 위한 IAM 서비스 연결 역할은 AWS CLI 를 통해 생성할 수 있습니다. 
```
aws iam create-service-linked-role --aws-service-name ecs.amazonaws.com --profile symple
```

### 도메인 서비스 가입 참고 
다음 블로그를 참고 하면 로컬 개발 환경 및 Domain 서비스 가입을 편리하게 할 수 있습니다.

- [Mac OS 개발자를 위한 로컬 개발 환경 구성](https://symplesims.github.io/development/setup/macos/2021/12/02/setup-development-environment-on-macos.html)
  가이드 참고
- [AWS Route53 도메인 서비스 관리](https://symplesims.github.io/devops/route53/acm/hosting/2022/04/09/aws-route53.html) 가이드 참고

## Git

`aws-fargate-magiclub` 프로젝트를 내려 받습니다. 
```
git clone https://github.com/chiwoo-cloud-native/aws-fargate-magiclub.git
```

## Build

`aws-fargate-magiclub` 프로젝트 경로에서 `sh deploy.sh` 명령을 통해 AWS 클라우드 리소스 및 ECS Service(애플리케이션)가 한번에 프로비저닝 됩니다.

```
export AWS_PROFILE=symple

cd aws-fargate-magiclub

chmod +x deploy.sh

sh deploy.sh
```

## Check Service

`curl` 명령을 통해 Frontend ALB 의 DNS 이름으로 ECS 애플리케이션 상태 및 요청을 확인할 수 있습니다.

### Check Hello 서비스

프로비저닝이 완료 되면 cURL 명령을 통해 hello 애플리케이션이 잘 동작하는지 확인 할 수 있습니다.

```
# check health health 
curl -i http://<ALB_DNS_NAME>/hello/health

# check api
curl -i http://<ALB_DNS_NAME>/hello/api/greetings
```


### Check Lotto 서비스

프로비저닝이 완료 되면 cURL 명령을 통해 lotto 애플리케이션이 잘 동작하는지 확인 할 수 있습니다.

```
# check health
curl -i -X GET --location 'http://<ALB_DNS_NAME>/health'

# check api
curl -H 'Content-Type: application/json' -X GET --location 'http://<ALB_DNS_NAME>/api/lotto/lucky' 

# 예시
curl -H 'Content-Type: application/json' -X GET http://magiclub-an2p-pub-alb-136632589.ap-northeast-2.elb.amazonaws.com/api/lotto/lucky
```

#### lotto 애플리케이션 확인 

[spring-lotto-router-handler](https://github.com/simplydemo/spring-lotto-router-handler) 샘플을 참고할 수 있습니다.

```
java -jar services/lotto/docker/lotto-service.jar
```


### AWS CloudWatch 로그 그룹의 로그 확인

```
aws logs tail /ecs/magiclub-an2p-lotto-api-ecss --since 1s --follow

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

애플리케이션 컨테이너 이미지 빌드를 위해 도커 이미지를 빌드 할 수
있는 [Docker Terraform 프로바이더](https://registry.terraform.io/providers/kreuzwerker/docker/latest) 를 추가 하였습니다.

- [providers.tf](./services/lotto/providers.tf)

```
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.33.0, < 5.0.0"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "= 2.25.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}
```

위의 설정 파일에서 docker host 는 사용자마다 다를 수 있습니다. 먼저 docker 데몬이 구동 되어 있어야 하며, docker context ls 를 통해 현재 docker 앤드포인트가 무엇인지
DOCKER ENDPOINT 값을 확인하세요.  
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

## Terraform

aws-fargate-magiclub 프로비저닝을 위한 Terraform 주요 정보를 참고 하세요.

### Requirements

| Name      | Version    |
|-----------|------------|
| terraform | >= 1.3.0   |
| aws       | >= 4.33.0  |
| docker    | >= 20.10.1 |

### Providers

| Name               | Version    |
|--------------------|------------|
| hashicorp/aws      | >= 4.33.0  |
| kreuzwerker/docker | = 2.25.0 |

### Modules

| Name                      | Version | Provider |
|---------------------------|:-------:|:--------:|
| terraform-aws-modules/vpc |  4.0.2  |   AWS    |
| terraform-aws-modules/alb |  8.5.0  |   AWS    |
| terraform-aws-modules/ecs |  3.5.0  |   AWS    |
| modules/context           |   N/A   |  Local   |
| modules/ecss              |   N/A   |  Local   |

### Inputs

| Name            | Description                                           |  Type  | 
|-----------------|:------------------------------------------------------|:------:|
| project         | 프로젝트 코드로 약어로 8자 이내로 입력하세요                     | string |
| region          | AWS Region 코드 입니다. ap-northeast-2 인 경우 an2 입니다.  | string |
| environment     | Production / Development 와 같은 운영 환경 입니다.          | string |
| env             | environment 값의 별칭으로 첫번째 알파벳의 소문자 입니다.         | string |
| domain          | AWS Certificate 인증서가 등록된 도메인 입니다.                | string |
| owner           | AWS 클라우드 서비스 및 리소스 관리 주체(Owner) 입니다.           | string |
| team            | AWS 클라우드 서비스 및 리소스 관리 팀(Team) 입니다.              | string |
| container_name  | ECS 컨테이너(애플리케이션) 이름 입니다.                         | string |
| container_port  | ECS 컨테이너(애플리케이션) 서비스 포트 입니다.                    | number |

 
### Outputs
N/A

