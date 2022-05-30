locals {
  sg_name = format("%s-%s-sg", var.name_prefix, var.container_name)
}

resource "aws_security_group" "container_sg" {
  name        = local.sg_name
  description = format("%s ECS Service", var.container_name)
  vpc_id      = data.aws_vpc.this.id

  /*
  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  */

  tags = merge(var.tags, {
    Name = local.sg_name
  })

}

# ECS SG-RULE ingress
resource "aws_security_group_rule" "ingress_8080" {
  type              = "ingress"
  description       = "HTTP"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = compact(concat([data.aws_vpc.this.cidr_block]))
  security_group_id = aws_security_group.container_sg.id
}

# ECS SG-RULE egress
resource "aws_security_group_rule" "egress_tls" {
  type              = "egress"
  description       = "Allowed TLS"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  # cidr_blocks       = compact(concat([data.aws_vpc.this.cidr_block]))
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.container_sg.id
}

resource "aws_security_group_rule" "egress_http" {
  type              = "egress"
  description       = "Allowed HTTP"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  # cidr_blocks       = compact(concat([data.aws_vpc.this.cidr_block]))
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.container_sg.id
}
