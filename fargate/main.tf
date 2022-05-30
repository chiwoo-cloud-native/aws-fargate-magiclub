module "ecs" {
  source  = "registry.terraform.io/terraform-aws-modules/ecs/aws"
  version = "3.5.0"

  name               = format("%s-ecs", var.name_prefix)
  container_insights = false
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  tags = merge(var.tags, {
    Name = format("%s-ecs", var.name_prefix)
  })

}
