data "aws_acm_certificate" "this" {
  domain = "*.${var.domain}"
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [format("%s-vpc", var.name_prefix)]
  }
}

data "aws_subnets" "pub" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Name"
    values = [ format("%s-pub*", var.name_prefix) ]
  }
}
