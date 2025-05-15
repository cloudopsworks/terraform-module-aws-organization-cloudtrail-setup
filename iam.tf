##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_role" {
  count   = var.is_hub ? 1 : 0
  version = "2012-10-17"
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "cloudtrail_role" {
  count   = var.is_hub ? 1 : 0
  version = "2012-10-17"

  statement {
    sid     = "AWSCloudTrailCreateLogStream"
    effect  = "Allow"
    actions = ["logs:CreateLogStream"]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:cloudtrail-catch-all:log-stream:*",
    ]
  }

  statement {
    sid     = "AWSCloudTrailPutLogEvents"
    effect  = "Allow"
    actions = ["logs:PutLogEvents"]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:cloudtrail-catch-all:log-stream:*",
    ]
  }
}

resource "aws_iam_role" "cloudtrail" {
  count              = var.is_hub ? 1 : 0
  name               = "${local.system_name}-cloudtrail-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
}

resource "aws_iam_role_policy" "cloudtrail" {
  count  = var.is_hub ? 1 : 0
  name   = "cloudtrail-cloudwatch-logs-role-policy"
  role   = aws_iam_role.cloudtrail[0].id
  policy = data.aws_iam_policy_document.cloudtrail_role[0].json
}