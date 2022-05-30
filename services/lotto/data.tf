data "aws_region" "current" {}

data "aws_route53_zone" "public" {
  name = var.domain
}

data "aws_acm_certificate" "this" {
  domain = "*.${var.domain}"
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [format("%s-vpc", var.name_prefix)]
  }
}

data "aws_subnets" "apps" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Name"
    values = [ format("%s-apps*", var.name_prefix) ]
  }
}


data "aws_iam_role" "ecs_task_execution_role" {
  name = format("%sECSTaskExecutionRole", var.project)
}

data "aws_service_discovery_dns_namespace" "this" {
  name = "map.${var.domain}"
  type = "DNS_PUBLIC"
}

data "aws_iam_role" "ecs_task_ssm_role" {
  name = format("%sECSCommandRole", var.project)
}

data "aws_ecs_cluster" "this" {
  cluster_name = format("%s-ecs", var.name_prefix)
}

data "aws_alb" "pub" {
  name = format("%s-pub-alb", var.name_prefix)
}

data "aws_alb_listener" "pub_https" {
  load_balancer_arn = data.aws_alb.pub.arn
  port              = 443
}


