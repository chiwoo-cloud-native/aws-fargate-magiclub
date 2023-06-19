##### you can add custom task execute policy for ecs app service
data "aws_iam_policy_document" "custom" {
  statement {
    effect  = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::cf-templates-an2p-s3",
      "arn:aws:s3:::cf-templates-an2p-s3/*"
    ]
  }
}
