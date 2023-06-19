locals {
  port_mappings = var.port_mappings != null ? var.port_mappings : [
    {
      protocol      = "tcp"
      containerPort = var.container_port
      name          = var.container_name
    },
  ]

  logConfiguration = var.enable_cloudwatch_log_group ? length(keys(var.logConfiguration.options)) > 0 ? var.logConfiguration : {
    logDriver = "awslogs"
    options   = {
      awslogs-group         = local.cwlog_grp_name
      awslogs-region        = local.region
      awslogs-stream-prefix = local.service_name
    }
  } : {
    logDriver = null
    options   = {}
  }

  container_definition = {
    name         = local.service_name
    image        = var.container_image
    essential    = var.essential
    memory       = var.memory
    cpu          = var.cpu
    command      = toset(var.command)
    portMappings = toset(local.port_mappings)
    environment  = toset(var.environments)
    secrets      = toset(var.secrets)
    ulimits      = toset(var.ulimits)

    logConfiguration = local.logConfiguration

    linuxParameters = {
      initProcessEnabled = var.initProcessEnabled
    }

  }

}

resource "aws_ecs_task_definition" "this" {
  family                   = format("%s-td", local.service_name)
  requires_compatibilities = var.requires_compatibilities
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.task.arn
  execution_role_arn       = var.execution_role_arn
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions    = "[${jsonencode(local.container_definition)}]"

  tags = merge(var.tags, { Name = local.service_name })

}
