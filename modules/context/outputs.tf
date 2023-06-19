
output "context" {
  value = {
    project      = var.context.project
    name_prefix  = local.name_prefix
    region       = var.context.region
    region_alias = local.region_alias
    environment  = var.context.environment
    env_alias    = local.env_alias
    owner        = var.context.owner
    team         = var.context.team
    domain       = var.context.domain
    pri_domain   = var.context.pri_domain
    tags         = local.tags
  }
}

output "name_prefix" {
  value = local.name_prefix
}

output "tags" {
  value = local.tags
}

output "region" {
  value = var.context.region
}

output "region_alias" {
  value = local.region_alias
}

output "project" {
  value = var.context.project
}

output "environment" {
  value = var.context.environment
}

output "env_alias" {
  value = local.env_alias
}

output "owner" {
  value = var.context.owner
}

output "team" {
  value = var.context.team
}

output "domain" {
  value = var.context.domain
}

output "pri_domain" {
  value = var.context.pri_domain
}
