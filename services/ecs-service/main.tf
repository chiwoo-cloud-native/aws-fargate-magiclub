locals {
  service_name         = var.container_name
  cwlog_grp_name       = format("/ecs/%s", local.service_name)
  enable_load_balancer = var.enable_load_balancer && var.target_group_arn != null && var.container_port > 0 ? true : false

  logConfiguration = var.enable_cloudwatch_log_group ? length(keys(var.logConfiguration.options)) > 0 ? var.logConfiguration : {
    logDriver = "awslogs"
    options   = {
      awslogs-group         = local.cwlog_grp_name
      awslogs-region        = var.region
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
    portMappings = toset(var.port_mappings)
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

  task_role_arn      = var.task_role_arn
  execution_role_arn = var.execution_role_arn

  cpu                   = var.cpu
  memory                = var.memory
  container_definitions = "[${jsonencode(local.container_definition)}]"

  tags = merge(var.tags, { Name = local.service_name })
}

resource "aws_ecs_service" "this" {
  name                    = local.service_name
  cluster                 = var.cluster_id
  task_definition         = format("%s:%s", aws_ecs_task_definition.this.family, aws_ecs_task_definition.this.revision)
  # task_definition         = aws_ecs_task_definition.this.id
  desired_count           = var.desired_count
  launch_type             = var.launch_type
  scheduling_strategy     = var.scheduling_strategy
  enable_ecs_managed_tags = var.enable_ecs_managed_tags
  enable_execute_command  = var.enable_execute_command

  deployment_controller {
    type = var.deployment_controller
  }

  dynamic "load_balancer" {
    for_each = local.enable_load_balancer == true ? [1] : []
    content {
      container_name   = local.service_name
      container_port   = var.container_port
      target_group_arn = var.target_group_arn
    }
  }

  network_configuration {
    assign_public_ip = var.assign_public_ip
    subnets          = toset(var.subnets)
    security_groups  = toset(var.security_group_ids)
  }

  propagate_tags = var.propagate_tags

  service_registries {
    registry_arn = aws_service_discovery_service.this.arn
  }

  lifecycle {
    ignore_changes = [load_balancer]
  }

  tags = merge(var.tags, { Name = local.service_name })

  depends_on = [aws_ecs_task_definition.this]
}
