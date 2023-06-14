locals {
  ecr_name = format("%s-%s-ecr", local.name_prefix, var.container_name)
}

resource "aws_ecr_repository" "this" {
  name                 = local.ecr_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  force_delete = true

  tags = merge(local.tags, {
    Name = local.ecr_name
  })
}
