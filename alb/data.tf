data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [format("%s-vpc", local.name_prefix)]
  }
}

data "aws_subnets" "pub" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Name"
    values = [ format("%s-pub*", local.name_prefix) ]
  }
}
