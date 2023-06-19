resource "aws_service_discovery_service" "this" {
  count = var.enable_discovery_service ? 1 : 0
  name  = var.container_name

  dns_config {
    namespace_id   = local.cloud_map_namespace_id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 60
      type = "A"
    }
  }

  tags = merge(var.tags, {
    Name = local.service_name
  })

}
