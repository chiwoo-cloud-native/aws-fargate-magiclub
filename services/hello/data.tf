data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [format("%s-vpc", local.name_prefix)]
  }
}

data "aws_subnets" "apps" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name   = "tag:Name"
    values = [ format("%s-apps*", local.name_prefix) ]
  }
}

data "aws_subnet" "apps" {
  for_each = toset(data.aws_subnets.apps.ids)
  id       = each.value
}

data "aws_iam_role" "task_execution" {
  name = format("%sECSTaskExecutionRole", local.project)
}

data "aws_ecs_cluster" "this" {
  cluster_name = format("%s-ecs", local.name_prefix)
}

data "aws_alb" "pub" {
  name = format("%s-pub-alb", local.name_prefix)
}

data "aws_alb_listener" "pub_http" {
  load_balancer_arn = data.aws_alb.pub.arn
  port              = 80
}

data "aws_service_discovery_http_namespace" "ans" {
  count = var.enable_service_connect ? 1 : 0
  name  = var.context.pri_domain
}

