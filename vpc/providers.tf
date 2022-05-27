terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 3.75.1"
    }
  }

}

provider "aws" {
  region  = "ap-northeast-2"
  profile = "active-stack"
}
