locals {
  name_prefix = "${var.project}-${var.region}${var.env}"
  tags        = {
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    Team        = var.team
  }
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
