terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "= 3.0.2"
    }
  }
}

provider "aws" {
  region  = var.context.region
}

data "aws_ecr_authorization_token" "ecr" {}

provider "docker" {
  host = "unix:///var/run/docker.sock"

  registry_auth {
    address  = local.container_image
    username = data.aws_ecr_authorization_token.ecr.user_name
    password = data.aws_ecr_authorization_token.ecr.password
  }

}
