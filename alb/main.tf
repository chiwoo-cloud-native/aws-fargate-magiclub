module "ctx" {
  source  = "../modules/context/"
  context = var.context
}

locals {
  name_prefix = module.ctx.name_prefix
  alb_name    = format("%s-pub-alb", local.name_prefix)
  tags        = module.ctx.tags
}

module "alb" {
  source  = "registry.terraform.io/terraform-aws-modules/alb/aws"
  version = "8.5.0"

  name               = local.alb_name
  load_balancer_type = "application"
  vpc_id             = data.aws_vpc.this.id
  security_groups    = [aws_security_group.this.id]
  subnets            = data.aws_subnets.pub.ids

  http_tcp_listeners = [
    {
      port           = 80
      protocol       = "HTTP"
      action_type    = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Fixed Static message"
        status_code  = "200"
      }
    }
  ]

  tags = merge(local.tags, {
    Name = local.alb_name
  })

}
