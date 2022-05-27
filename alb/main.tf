locals {
  name_prefix = "magiclub-an2p"
}

module "alb" {
  source = "registry.terraform.io/terraform-aws-modules/alb/aws"

  name               = format("%s-alb", local.name_prefix)
  load_balancer_type = "application"
  vpc_id             = data.aws_vpc.this.id
  security_groups    = [aws_security_group.this.id]
  subnets            = data.aws_subnet_ids.apps.ids

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect    = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  https_listeners = [
    # HTTPS Listener Index = 0 for HTTPS 443
    {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = data.aws_acm_certificate.this.arn
      action_type     = "fixed-response"
      fixed_response  = {
        content_type = "text/plain"
        message_body = "Fixed Static message - for Root Context"
        status_code  = "200"
      }
    },
  ]

  tags = {
    Owner       = "opsmaster@your.company.com"
    Environment = "PoC"
    Team        = "DevOps"
  }

  lb_tags = {
    MyLoadBalancer = "foo"
  }

  http_tcp_listeners_tags = {
    MyLoadBalancerTCPListener = "bar"
  }

  https_listeners_tags = {
    MyLoadBalancerHTTPSListener = "bar"
  }


}
