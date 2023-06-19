module "ctx" {
  source  = "../../modules/context/"
  context = var.context
}

locals {
  container_name        = "lotto-api"
  container_port        = 8080
  project               = module.ctx.project
  name_prefix           = module.ctx.name_prefix
}

module "lotto" {
  source  = "../../modules/ecss/"
  context = module.ctx.context

  container_image               = local.container_image
  container_name                = local.container_name
  container_port                = local.container_port
  enable_discovery_service      = var.enable_discovery_service
  enable_service_connect        = var.enable_service_connect
  cpu                           = 256
  memory                        = 512
  desired_count                 = 1
  target_group_arn              = aws_lb_target_group.tg8080.arn
  #
  service_connect_configuration = {
    service = {
      client_alias = {
        port     = local.container_port
        dns_name = local.container_name
      }
      port_name      = local.container_name
      discovery_name = local.container_name
    }
  }
  #
  vpc_id             = data.aws_vpc.this.id
  cluster_id         = data.aws_ecs_cluster.this.id
  task_policy_json   = data.aws_iam_policy_document.custom.json
  execution_role_arn = data.aws_iam_role.task_execution.arn
  subnets            = data.aws_subnets.apps.ids

  depends_on = [
    aws_lb_target_group.tg8080
  ]
}
