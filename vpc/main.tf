locals {
  name_prefix = "${var.project}-${var.region}${var.env}"
  tags        = {
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    Team        = var.team
  }
}

module "vpc" {
  source = "registry.terraform.io/terraform-aws-modules/vpc/aws"

  name = local.name_prefix
  cidr = "172.76.0.0/16"

  azs                  = ["apne2-az1", "apne2-az3"]
  public_subnets       = ["172.76.11.0/24", "172.76.12.0/24"]
  public_subnet_suffix = "pub"

  private_subnets       = ["172.76.21.0/24", "172.76.22.0/24"]
  private_subnet_suffix = "apps"

  enable_dns_hostnames = true

  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = local.tags

  vpc_tags         = { Name = format("%s-vpc", local.name_prefix) }
  igw_tags         = { Name = format("%s-igw", local.name_prefix) }
  nat_gateway_tags = { Name = format("%s-nat", local.name_prefix) }

}
