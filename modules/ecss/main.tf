locals {
  name_prefix            = var.context.name_prefix
  project                = var.context.project
  region                 = var.context.region
  pri_domain             = var.context.pri_domain
  tags                   = var.context.tags
  service_name           = var.container_name
  cwlog_grp_name         = format("/ecs/%s", local.service_name)
  enable_load_balancer   = var.enable_load_balancer && var.container_port > 0 ? true : false
  cloud_map_namespace_id = var.cloud_map_namespace_id != null ? var.cloud_map_namespace_id : try(data.aws_service_discovery_dns_namespace.dns[0].id, null)
}

resource "aws_ecs_service" "this" {
  name                    = local.service_name
  cluster                 = var.cluster_id
  task_definition         = format("%s:%s", aws_ecs_task_definition.this.family, aws_ecs_task_definition.this.revision)
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
    security_groups  = [aws_security_group.this.id]
  }

  propagate_tags = var.propagate_tags

  dynamic "service_registries" {
    for_each = var.enable_discovery_service ? [1] : []
    content {
      registry_arn = try(aws_service_discovery_service.this[0].arn, null)
    }
  }

  dynamic "service_connect_configuration" {
    for_each = var.enable_service_connect ? [1] : []
    content {
      enabled   = true
      namespace = try(data.aws_service_discovery_http_namespace.ans[0].arn, null)
      service {
        discovery_name = "service"
        port_name      = var.container_name
        client_alias {
          dns_name = try(data.aws_service_discovery_http_namespace.ans[0].name, null)
          port     = var.container_port
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [load_balancer]
  }

  tags = merge(var.tags, { Name = local.service_name })

  depends_on = [
    aws_security_group.this,
    aws_ecs_task_definition.this
  ]
}