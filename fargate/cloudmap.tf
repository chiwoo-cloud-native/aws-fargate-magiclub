resource "aws_service_discovery_public_dns_namespace" "this" {
  name        = "map.${var.domain}"
  description = "${var.project}'s cloud-map public doamin"

  tags = merge(local.tags, {
    Name = format("%s-cloud-map", local.name_prefix)
  })
}
