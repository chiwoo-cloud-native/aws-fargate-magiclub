resource "docker_image" "this" {
  name = "lotto"
  build {
    context    = "./docker"
    dockerfile = "Dockerfile"
    platform   = "linux/amd64"
    tag        = ["${local.container_image}:latest"]
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
sh ${path.module}/docker/publish.sh ${local.container_image} latest
EOF
    interpreter = ["bash", "-c"]
  }

  depends_on = [docker_image.this]
}
