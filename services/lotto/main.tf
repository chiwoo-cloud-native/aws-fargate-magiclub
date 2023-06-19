module "ctx" {
  source  = "../../modules/context/"
  context = var.context
}

locals {
  container_name = "lotto-api"
  container_port = 8080
  project        = module.ctx.project
  name_prefix    = module.ctx.name_prefix
  # ecr_repository_url = format("%s", aws_ecr_repository.this.repository_url)
  # tags               = module.context.tags
}

module "lotto" {
  source  = "../../modules/ecss/"
  context = module.ctx.context

  container_image          = var.repository_url
  container_name           = local.container_name
  container_port           = local.container_port
  enable_discovery_service = var.enable_discovery_service
  enable_service_connect   = var.enable_service_connect
  cpu                      = 256
  memory                   = 512
  desired_count            = 1
  port_mappings            = [
    {
      protocol      = "tcp"
      containerPort = local.container_port
      name          = local.container_name
    },
  ]
  target_group_arn = aws_lb_target_group.tg8080.arn

  vpc_id             = data.aws_vpc.this.id
  cluster_id         = data.aws_ecs_cluster.this.id
  task_policy_json   = data.aws_iam_policy_document.custom.json
  execution_role_arn = data.aws_iam_role.task_execution.arn
  subnets            = data.aws_subnets.apps.ids

  depends_on = [
    aws_lb_target_group.tg8080
  ]
}
