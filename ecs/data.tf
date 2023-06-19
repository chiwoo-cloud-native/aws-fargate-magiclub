data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "this" {
  default = false
  tags    = {
    Name = format("%s-vpc", local.name_prefix)
  }
}
