locals {
  sg_name = format("%s-%s-sg", local.name_prefix, var.container_name)
}

resource "aws_security_group" "this" {
  name        = local.sg_name
  description = format("%s ECS Service", var.container_name)
  vpc_id      = data.aws_vpc.this.id

  tags = merge(local.tags, {
    Name = local.sg_name
  })
}

# egress
resource "aws_security_group_rule" "out80" {
  type              = "egress"
  description       = "Allowed HTTP"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "out443" {
  type              = "egress"
  description       = "Allowed TLS"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

# ingress
resource "aws_security_group_rule" "inApp" {
  type              = "ingress"
  description       = "ECS Service"
  from_port         = var.container_port
  to_port           = var.container_port
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = compact(concat([data.aws_vpc.this.cidr_block]))
}
