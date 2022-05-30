locals {
  sg_name = format("%s-pub-alb-sg", var.name_prefix)
}
resource "aws_security_group" "this" {
  name        = local.sg_name
  description =  "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.this.id

  egress {
    description      = "all for internet-facing"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, {
    Name = local.sg_name
  })
}

resource "aws_security_group_rule" "ingress_http" {
  type              = "ingress"
  description       = "Public HTTP"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_https" {
  type              = "ingress"
  description       = "Public HTTPS"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"]
}
