resource "aws_service_discovery_service" "this" {
  count = var.cloud_map_namespace_id == null ? 0 : 1
  name = var.container_name

  dns_config {
    namespace_id   = var.cloud_map_namespace_id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 60
      type = "A"
    }
  }

  /*
  health_check_config {
    failure_threshold = 10
    resource_path     = "path"
    type              = "HTTP"
  }
  */

  tags = merge(var.tags, {
    Name = format("%s-namespace", local.service_name)
  })

}
