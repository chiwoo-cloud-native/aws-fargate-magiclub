resource "aws_security_group" "this" {
  name        = format("%s-alb-sg", local.name_prefix)
  description = ""
  vpc_id      = data.aws_vpc.this.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Owner       = "opsmaster@your.company.com"
    Environment = "PoC"
    Team        = "DevOps"
  }
}

resource "aws_security_group_rule" "ingress_http" {
  type        = "egress"
  description = "Public HTTP"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_https" {
  type        = "egress"
  description = "Public HTTPS"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks = ["0.0.0.0/0"]
}
