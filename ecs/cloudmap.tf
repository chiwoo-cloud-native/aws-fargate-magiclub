resource "aws_service_discovery_private_dns_namespace" "dns" {
  count       = var.enable_discovery_service ? 1 : 0
  name        = format("discovery.%s", var.context.pri_domain)
  description = "Private CloudMap namespace for ecs services."
  vpc         = data.aws_vpc.this.id
}

resource "aws_service_discovery_http_namespace" "ans" {
  count       = var.enable_service_connect ? 1 : 0
  name        = var.context.pri_domain
  description = "Private CloudMap http namespace for ${var.context.pri_domain}"
  tags        = local.tags
}
