locals {
  task_role_name   = format("%s%s", local.project, replace(title( format("%s-TaskRole", var.container_name) ), "-", "" ))
  task_policy_name = format("%s%s", local.project, replace(title( format("%s-TaskPolicy", var.container_name) ), "-", "" ))
}

# TaskExecutionRole for ECS Application service
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "exec_policy" {
  name = format( "%sECSCommandExecutionPolicy", local.project)
}

resource "aws_iam_role" "task" {
  name               = local.task_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = merge(local.tags, { Name = local.task_role_name })
}

resource "aws_iam_role_policy_attachment" "ecsCmdExecPolicy" {
  role       = aws_iam_role.task.name
  policy_arn = data.aws_iam_policy.exec_policy.arn
}

resource "aws_iam_policy" "task_policy" {
  count  = var.task_policy_json == null ? 0 : 1
  name   = local.task_policy_name
  policy = var.task_policy_json
  tags   = merge(local.tags, {
    Name = local.task_policy_name
  })
}

resource "aws_iam_role_policy_attachment" "custom" {
  count      = var.task_policy_json == null ? 0 : 1
  role       = aws_iam_role.task.name
  policy_arn = concat(aws_iam_policy.task_policy.*.arn, [""])[0]
}
