data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "this" {
  default = false
  tags    = {
    Name = format("%s-vpc", var.name_prefix)
  }
}

data "aws_kms_key" "this" {
  key_id = "alias/KMS-COST-DEV-MAIN"
}
