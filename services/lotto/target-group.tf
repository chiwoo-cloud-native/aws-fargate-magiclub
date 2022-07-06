locals {
  hostname =  format("%s.%s", var.container_name, var.domain)
}

resource "aws_lb_target_group" "tg8080" {
  name        = format("%s-%s-tg8080", var.project, var.container_name)
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.this.id

  health_check {
    enabled             = true
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200-302"
  }
}

resource "aws_lb_listener_rule" "host_based_weighted_routing" {
  listener_arn = data.aws_alb_listener.pub_https.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg8080.arn
  }

  condition {
    host_header {
      values = [ local.hostname ]
    }
  }

}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = local.hostname
  type    = "CNAME"
  ttl     = "300"
  records = [ data.aws_alb.pub.dns_name ]
  allow_overwrite = true
}
