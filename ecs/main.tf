module "ctx" {
  source  = "../modules/context/"
  context = var.context
}

locals {
  project     = module.ctx.project
  name_prefix = module.ctx.name_prefix
  tags        = module.ctx.tags
}

module "ecs" {
  source  = "registry.terraform.io/terraform-aws-modules/ecs/aws"
  version = "3.5.0"

  name               = format("%s-ecs", local.name_prefix)
  container_insights = false
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  tags = merge(local.tags, {
    Name = format("%s-ecs", local.name_prefix)
  })

}
