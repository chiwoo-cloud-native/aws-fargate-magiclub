# https://docs.aws.amazon.com/ko_kr/AmazonECS/latest/userguide/ecs-exec.html

locals {
  iam_ecs_task_ssm_role  = format("%sECSCommandRole", var.project)
  iam_ecs_task_exec_role = format("%sECSTaskExecutionRole", var.project)
}

# ECS SSM Command Role


data "aws_iam_policy_document" "ssm" {

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

resource "aws_iam_policy" "execute_command" {
  name   = format("%sECSCommandExecutionPolicy", var.project)
  policy = data.aws_iam_policy_document.ssm.json
}

data "aws_iam_policy_document" "ecs_task_exec_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_ssm" {
  name               = local.iam_ecs_task_ssm_role
  description        = "Use Amazon ECS Exec for debugging."
  assume_role_policy = data.aws_iam_policy_document.ecs_task_exec_assume.json
  tags               = merge(local.tags, { Name = local.iam_ecs_task_ssm_role, })
}

resource "aws_iam_role_policy_attachment" "ecs_task_ssm" {
  role       = aws_iam_role.ecs_task_ssm.name
  policy_arn = aws_iam_policy.execute_command.arn
}

# ECS Execution Role
data "aws_iam_policy" "ecs_task_exec" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_exec" {
  name               = local.iam_ecs_task_exec_role
  description        = "ECS Task Execution Role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_exec_assume.json
  tags               = merge(local.tags, { Name = local.iam_ecs_task_exec_role, })
}

resource "aws_iam_role_policy_attachment" "ecs_exec_default" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = data.aws_iam_policy.ecs_task_exec.arn
}

data "aws_iam_policy_document" "ecs_task_exec" {
  statement {
    effect  = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.project}/*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [data.aws_kms_key.this.arn]
  }
}

resource "aws_iam_policy" "ecs_task_exec" {
  name   = format("%sECSTaskExecutionPolicy", var.project)
  policy = data.aws_iam_policy_document.ecs_task_exec.json

  tags = merge(local.tags, { Name = format("%sECSTaskExecutionPolicy", var.project) })
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = aws_iam_policy.ecs_task_exec.arn
}
