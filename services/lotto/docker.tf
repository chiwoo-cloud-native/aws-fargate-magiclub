resource "docker_image" "this" {
  name = "lotto"
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
    command     = <<EOF
sleep 3s
sh ${path.module}/docker/publish.sh ${local.ecr_repository_url} latest
EOF
    interpreter = ["bash", "-c"]
  }

  depends_on = [docker_image.this]
}
