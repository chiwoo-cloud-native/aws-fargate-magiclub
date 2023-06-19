terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.33.0, < 5.0.0"
    }
  }

}

provider "aws" {
  region  = var.context.region
}
