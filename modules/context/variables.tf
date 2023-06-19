#variable "project" { type = string }
#variable "region" { type = string }
#variable "environment" { type = string }
#variable "owner" { type = string }
#variable "team" { type = string }
#variable "pri_domain" { type = string }
#variable "domain" {
#  type    = string
#  default = null
#}

variable "context" {
  type = object({
    project      = string # project name is usally account's project name or platform name
    region       = string # describe default region to create a resource from aws
    environment  = string # Runtime Environment such as develop, stage, production
    owner        = string # project owner
    team         = string # Team name of Devops Transformation
    pri_domain   = string # private domain name (ex, tools.customer.co.kr)
    domain       = optional(string) # public toolchain domain name (ex, tools.customer.co.kr)
  })
}
