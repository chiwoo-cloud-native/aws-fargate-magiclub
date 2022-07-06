locals {
  name_prefix = "${var.project}-${var.region}${var.env}"
  region             = data.aws_region.current.name
  ecr_repository_url = format("%s", aws_ecr_repository.this.repository_url)
  tags        = {
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    Team        = var.team
  }
}

module "lotto" {
  source = "../ecs-service/"

  project         = var.project
  region          = local.region
  name_prefix     = local.name_prefix
  container_name  = var.container_name
  container_port  = var.container_port
  container_image = local.ecr_repository_url
  cpu             = 512
  memory          = 1024
  desired_count   = 1
  port_mappings   = [
    {
      "protocol" : "tcp",
      "containerPort" : var.container_port
    },
  ]

  vpc_id                 = data.aws_vpc.this.id
  cluster_id             = data.aws_ecs_cluster.this.id
  task_role_arn          = data.aws_iam_role.ecs_task_ssm_role.arn
  execution_role_arn     = data.aws_iam_role.ecs_task_execution_role.arn
  subnets                = data.aws_subnets.apps.ids
  security_group_ids     = [aws_security_group.container_sg.id]
  target_group_arn       = aws_lb_target_group.tg8080.arn
  cloud_map_namespace_id = data.aws_service_discovery_dns_namespace.this.id

  depends_on = [aws_ecr_repository.this]
}

