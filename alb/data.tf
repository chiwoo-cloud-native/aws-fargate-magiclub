data "aws_acm_certificate" "this" {
  domain = "*.mystarcraft.ml"
}

data "aws_vpc" "this" {
  default = false
  tags = {
    # Name = "VPC-FIN-DEV-OPSNOW"
    Name = format("%s-vpc", local.name_prefix)
  }
}

data "aws_subnet_ids" "apps" {
  vpc_id = data.aws_vpc.this.id
  filter {
    name = "tag:Name"
    # values = [ "SN-FIN-DEV-PRIVATE--APP*" ]
    values = [ format("%s-apps*", local.name_prefix) ]
  }
}
