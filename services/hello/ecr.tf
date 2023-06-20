locals {
  ecr_name        = format("%s-%s-ecr", local.name_prefix, local.container_name)
  container_image = var.repository_url != null ? var.repository_url : try(aws_ecr_repository.this[0].repository_url, null)
}

resource "aws_ecr_repository" "this" {
  count                = var.repository_url != null ? 0 : 1
  name                 = local.ecr_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  force_delete = true

  tags = merge(module.ctx.tags, {
    Name = local.ecr_name
  })
}
