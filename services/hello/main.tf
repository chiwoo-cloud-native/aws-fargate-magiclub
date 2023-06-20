module "ctx" {
  source  = "../../modules/context/"
  context = var.context
}

locals {
  container_name = "hello-api"
  container_port = 8090
  project        = module.ctx.project
  name_prefix    = module.ctx.name_prefix
}

module "app" {
  source  = "../../modules/ecss/"
  context = module.ctx.context

  container_image          = local.container_image
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
      # appProtocol   = "http"
    }
  ]
  #
  service_connect_configuration = {
    service = {
      port_name      = local.container_name
      client_alias   = {
        port     = local.container_port
      }
    }
  }
  #
  vpc_id             = data.aws_vpc.this.id
  cluster_id         = data.aws_ecs_cluster.this.id
  task_policy_json   = data.aws_iam_policy_document.custom.json
  execution_role_arn = data.aws_iam_role.task_execution.arn
  subnets            = data.aws_subnets.apps.ids
  security_group_ids = [aws_security_group.this.id]
  target_group_arn   = aws_lb_target_group.this.arn
}
