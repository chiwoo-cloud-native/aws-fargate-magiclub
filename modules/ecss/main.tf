locals {
  name_prefix            = var.context.name_prefix
  project                = var.context.project
  region                 = var.context.region
  pri_domain             = var.context.pri_domain
  tags                   = var.context.tags
  task_definition_name   = format("%s-%s-td", local.name_prefix, var.container_name)
  ecs_service_name       = format("%s-%s-ecss", local.name_prefix, var.container_name)
  ecs_container_name     = format("%s-%s-ecsc", local.name_prefix, var.container_name)
  cwlog_grp_name         = format("/ecs/%s", local.ecs_service_name)
  enable_load_balancer   = var.enable_load_balancer && var.container_port > 0 ? true : false
  cloud_map_namespace_id = var.cloud_map_namespace_id != null ? var.cloud_map_namespace_id : try(data.aws_service_discovery_dns_namespace.dns[0].id, null)
}

resource "aws_ecs_service" "this" {
  name                    = local.ecs_service_name
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
      container_name   = local.ecs_container_name
      container_port   = var.container_port
      target_group_arn = var.target_group_arn
    }
  }

  network_configuration {
    assign_public_ip = var.assign_public_ip
    subnets          = toset(var.subnets)
    security_groups  = var.security_group_ids
  }

  propagate_tags = var.propagate_tags

  dynamic "service_registries" {
    for_each = var.enable_discovery_service ? [1] : []
    content {
      registry_arn = try(aws_service_discovery_service.this[0].arn, null)
    }
  }

  dynamic "service_connect_configuration" {
    for_each = var.enable_service_connect && length(var.service_connect_configuration) > 0 ? [
      var.service_connect_configuration
    ] : []

    content {
      enabled   = true
      namespace = try(data.aws_service_discovery_http_namespace.ans[0].arn, null)

      dynamic "service" {
        for_each = try([service_connect_configuration.value.service], [])

        content {
          dynamic "client_alias" {
            for_each = try([service.value.client_alias], [])
            content {
              dns_name = try(client_alias.value.dns_name, null)
              port     = client_alias.value.port
            }
          }
          port_name             = service.value.port_name
          discovery_name        = try(service.value.discovery_name, null)
          ingress_port_override = try(service.value.ingress_port_override, null)
        }
      }
    }
  }

  #  dynamic "service_connect_configuration" {
  #    for_each = var.enable_service_connect ? [1] : []
  #    content {
  #      enabled   = true
  #      namespace = try(data.aws_service_discovery_http_namespace.ans[0].arn, null)
  #      service {
  #        discovery_name = var.container_name
  #        port_name      = var.container_name
  #        client_alias {
  #          dns_name = try(data.aws_service_discovery_http_namespace.ans[0].name, null)
  #          port     = var.container_port
  #        }
  #      }
  #    }
  #  }

  lifecycle {
    ignore_changes = [load_balancer]
  }

  tags = merge(var.tags, { Name = local.ecs_service_name })

  depends_on = [
    aws_ecs_task_definition.this
  ]
}
