module "ctx" {
  source  = "../modules/context/"
  context = var.context
}

locals {
  name_prefix = module.ctx.name_prefix
  tags        = module.ctx.tags
}

module "vpc" {
  source  = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = local.name_prefix
  cidr = "172.25.0.0/16"

  azs                           = ["apne2-az1", "apne2-az3"]
  public_subnets                = ["172.25.11.0/24", "172.25.12.0/24"]
  public_subnet_suffix          = "pub"
  #
  private_subnets               = ["172.25.21.0/24", "172.25.22.0/24"]
  private_subnet_suffix         = "apps"
  #
  manage_default_route_table    = false
  manage_default_security_group = false
  enable_dns_hostnames          = true
  enable_nat_gateway            = true
  single_nat_gateway            = true
  #
  tags                          = local.tags
  vpc_tags                      = { Name = format("%s-vpc", local.name_prefix) }
  igw_tags                      = { Name = format("%s-igw", local.name_prefix) }
  nat_gateway_tags              = { Name = format("%s-nat", local.name_prefix) }

}
