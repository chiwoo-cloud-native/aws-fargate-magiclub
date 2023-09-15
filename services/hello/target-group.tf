resource "aws_lb_target_group" "this" {
  name        = format("%s-%s-tg", local.project, local.container_name)
  port        = local.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.this.id

  health_check {
    enabled             = true
    path                = "/hello/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200-302"
  }
}

resource "aws_lb_listener_rule" "rule" {
  listener_arn = data.aws_alb_listener.pub.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    path_pattern {
      values = [ "/hello/*" ]
    }
  }

}
