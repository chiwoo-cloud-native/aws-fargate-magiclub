# https://docs.aws.amazon.com/ko_kr/AmazonECS/latest/userguide/ecs-exec.html

locals {
  iam_ecs_task_exec_role = format("%sECSTaskExecutionRole", local.project)
  task_command_policy_name = format("%sECSCommandExecutionPolicy", local.project)
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

resource "aws_iam_role" "this" {
  name               = local.iam_ecs_task_exec_role
  description        = "ECS Task Execution Role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
  tags               = merge(local.tags, { Name = local.iam_ecs_task_exec_role, })
}

# Default ECS Task Execution policy defined directly by AWS.
data "aws_iam_policy" "execution_role_policy" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "execution_role_policy" {
  role       = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy.execution_role_policy.arn
}

# ECSCommandExecutionPolicy

data "aws_iam_policy_document" "execute_command" {
  # SSM
  statement {
    sid     = "ECSCommandExecutionPolicy"
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
  name   = local.task_command_policy_name
  policy = data.aws_iam_policy_document.execute_command.json
}

resource "aws_iam_role_policy_attachment" "task_policy" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.task_policy.arn
}


#
#resource "aws_iam_role" "ecs_instance_role" {
#  name                = "ecsInstanceRole"
#  assume_role_policy  = data.aws_iam_policy_document.ecs_task_assume.json
#  tags               = merge(local.tags, { Name = local.iam_ecs_task_exec_role, })
#}
#
## Default ECS Task Instance policy defined directly by AWS.
#data "aws_iam_policy" "container_ec2_role" {
#  name = "AmazonEC2ContainerServiceforEC2Role"
#}
#
#resource "aws_iam_role_policy_attachment" "container_ec2_role" {
#  role       = aws_iam_role.ecs_instance_role.name
#  policy_arn = data.aws_iam_policy.container_ec2_role.arn
#}
#
