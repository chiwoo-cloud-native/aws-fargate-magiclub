terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 3.75.1"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "= 2.16.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
  profile = "active-stack"
}

data "aws_ecr_authorization_token" "ecr" {}

provider "docker" {
  # host = "unix:///var/run/docker.sock"
  host = "unix:///${pathexpand("~/.lima/default/sock/docker.sock")}"

  registry_auth {
    address  = local.ecr_repository_url
    username = data.aws_ecr_authorization_token.ecr.user_name
    password = data.aws_ecr_authorization_token.ecr.password
  }

}
