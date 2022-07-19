resource "docker_image" "this" {
  name = local.ecr_repository_url
  build {
    path       = "./docker"
    dockerfile = "Dockerfile"
    tag        = ["latest"]
    build_arg  = {
      key1 : "value1"
    }
    label = {
      author : "symplesims"
    }
  }
}

resource "null_resource" "push" {
  provisioner "local-exec" {
    command     = "${path.module}/docker/publish.sh ${local.ecr_repository_url} latest"
    interpreter = ["bash", "-c"]
  }
}
