locals {
  task_role_name   = format("%s%s", local.project, replace(title( format("%s-TaskRole", var.container_name) ), "-", "" ))
  custom_policy_name = format("%s%s", local.project, replace(title( format("%s-TaskPolicy", var.container_name) ), "-", "" ))
}

data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"] # "ec2.amazonaws.com" for EC2
    }
  }
}

resource "aws_iam_role" "task_role" {
  name               = local.task_role_name
  description        = "Use Amazon ECS Exec for debugging."
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
  tags               = merge(local.tags, { Name = local.task_role_name, })
}

task_command_policy_name = format("%s%s", local.project, replace(title( format("%s-TaskPolicy", var.container_name) ), "-", "" ))

data "aws_iam_policy_document" "execute_command" {
  # SSM
  statement {
    sid     = ""
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = [ "*" ]
  }

}

resource "aws_iam_policy" "task_policy" {
  name   = local.task_policy_name
  policy = data.aws_iam_policy_document.ssm.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_ssm" {
  role       = aws_iam_role.ecs_task_ssm.name
  policy_arn = aws_iam_policy.custom.arn
}

