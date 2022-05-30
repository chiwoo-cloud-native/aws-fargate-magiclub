resource "docker_image" "this" {
  name = "zoo"
  build {
    path       = "./docker"
    dockerfile = "Dockerfile"
    tag        = ["${local.ecr_repository_url}:latest"]
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
