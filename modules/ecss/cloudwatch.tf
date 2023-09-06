resource "aws_cloudwatch_log_group" "this" {
  count             = var.enable_cloudwatch_log_group ? 1 : 0
  name              = local.cwlog_grp_name
  retention_in_days = var.retention_in_days
}
