data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [format("%s-vpc", local.name_prefix)]
  }
}

data "aws_service_discovery_dns_namespace" "dns" {
  count = var.enable_discovery_service ? 1 : 0
  name  = "discovery.${local.pri_domain}"
  type  = "DNS_PRIVATE"
}

data "aws_service_discovery_http_namespace" "ans" {
  count = var.enable_service_connect ? 1 : 0
  name  = "ans.${local.pri_domain}"
}
