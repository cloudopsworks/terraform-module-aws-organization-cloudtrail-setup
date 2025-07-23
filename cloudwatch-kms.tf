##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

data "aws_iam_policy_document" "kms_policy" {
  count   = var.is_hub ? 1 : 0
  version = "2012-10-17"

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
      type = "AWS"
    }
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "cloudwatch_policy" {
  count   = var.is_hub ? 1 : 0
  version = "2012-10-17"

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
      type = "AWS"
    }
    principals {
      identifiers = concat(
        [
          "logs.${data.aws_region.current.name}.amazonaws.com",
          "logs.amazonaws.com"
        ],
        [
          for r in try(var.settings.cloudwatch_other_regions, []) : "logs.${r}.amazonaws.com"
        ]
      )
      type = "Service"
    }
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Allow access for Key Administrators"
    effect = "Allow"
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
      type = "AWS"
    }
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Allow use of the key"
    effect = "Allow"
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
      type = "AWS"
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Allow attachment of persistent resources"
    effect = "Allow"
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
      type = "AWS"
    }
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

resource "aws_kms_key" "cloudwatch" {
  count                   = var.is_hub ? 1 : 0
  description             = "Cloudwatch general encryption Key"
  deletion_window_in_days = 15
  enable_key_rotation     = true
  is_enabled              = true
  policy                  = data.aws_iam_policy_document.cloudwatch_policy[0].json
  tags                    = local.all_tags
}

resource "aws_kms_alias" "cloudwatch" {
  count         = var.is_hub ? 1 : 0
  target_key_id = aws_kms_key.cloudwatch[0].key_id
  name          = "alias/${local.system_name}-cloudwatch"
}
