variable "project" {
  type = string
}

variable "domain" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "container_name" {
  type = string
}

variable "container_port" {
  type = number
}
