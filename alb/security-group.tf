locals {
  sg_name = format("%s-pub-alb-sg", local.name_prefix)
}

resource "aws_security_group" "this" {
  name        = local.sg_name
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.this.id

  tags = merge(local.tags, {
    Name = local.sg_name
  })
}

# egress
resource "aws_security_group_rule" "outAny" {
  type              = "egress"
  description       = "Public HTTP"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

# ingress
resource "aws_security_group_rule" "in80" {
  type              = "ingress"
  description       = "Public HTTP"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "in443" {
  type              = "ingress"
  description       = "Public HTTPS"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"]
}
