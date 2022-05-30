resource "aws_service_discovery_service" "this" {
  name = "map"

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
