locals {
  ecr_name = format("%s-%s-ecr", var.name_prefix, var.container_name)
}

resource "aws_ecr_repository" "this" {
  name                 = local.ecr_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = merge(var.tags, {
    Name = local.ecr_name
  })
}
