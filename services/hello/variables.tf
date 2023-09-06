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

variable "repository_url" {
  type    = string
  default = null
}

variable "enable_discovery_service" {
  type    = bool
  default = false
}

variable "enable_service_connect" {
  type    = bool
  default = false
}
