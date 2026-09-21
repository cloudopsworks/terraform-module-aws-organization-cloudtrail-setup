##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#
# Account root statement shared with the trail specific policy below. Dropping it orphans the key
data "aws_iam_policy_document" "kms_policy" {
  count   = local.create_cloudtrail_key ? 1 : 0
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

data "aws_iam_policy_document" "cloudtrail_base" {
  count   = local.create_cloudtrail_key ? 1 : 0
  version = "2012-10-17"

  statement {
    sid = "The key created by cloudtrail to encrypt event datastores"
    actions = [
      "kms:Encrypt",
      "kms:ReEncryptTo",
      "kms:GenerateDataKey*",
    ]
    effect = "Allow"
    principals {
      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
      type = "Service"
    }
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "Allow CloudTrail to encrypt logs"
    effect = "Allow"
    principals {
      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
      type = "Service"
    }
    actions = [
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:cloudtrail:${data.aws_region.current.region}:${data.aws_organizations_organization.current[0].master_account_id}:trail/${var.settings.cloudtrail_name}",
        "arn:aws:cloudtrail:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:trail/${var.settings.cloudtrail_name}"
      ]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values = [
        "arn:aws:cloudtrail:*:${data.aws_organizations_organization.current[0].master_account_id}:trail/*",
        "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
      ]
    }
  }

  statement {
    sid    = "Allow CloudTrail to describe key"
    effect = "Allow"
    principals {
      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
      type = "Service"
    }
    actions = [
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Allow principals in the account to decrypt log files"
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values = [
        "arn:aws:cloudtrail:*:${data.aws_organizations_organization.current[0].master_account_id}:trail/*",
        "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
      ]
    }
  }

  statement {
    sid    = "Allow alias creation during setup"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:CreateAlias"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${data.aws_region.current.region}.amazonaws.com"]
    }
  }

  statement {
    sid    = "Enable cross account log decryption"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values = [
        data.aws_caller_identity.current.account_id,
        data.aws_organizations_organization.current[0].master_account_id
      ]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values = [
        "arn:aws:cloudtrail:*:${data.aws_organizations_organization.current[0].master_account_id}:trail/*",
        "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
      ]
    }
  }
}

data "aws_iam_policy_document" "cloudtrail_combined" {
  count = local.create_cloudtrail_key ? 1 : 0
  source_policy_documents = [
    data.aws_iam_policy_document.kms_policy[0].json,
    data.aws_iam_policy_document.cloudtrail_base[0].json,
  ]
}

resource "aws_kms_key" "cloudtrail" {
  count                   = local.create_cloudtrail_key ? 1 : 0
  description             = "Cloudtrail encryption Key"
  deletion_window_in_days = local.kms_deletion_window
  enable_key_rotation     = local.kms_rotation_enabled
  rotation_period_in_days = local.kms_rotation_enabled ? local.kms_rotation_period : null
  multi_region            = local.kms_multi_region
  is_enabled              = true
  policy                  = data.aws_iam_policy_document.cloudtrail_combined[0].json
  tags                    = local.all_tags
}

resource "aws_kms_alias" "cloudtrail" {
  count         = local.create_cloudtrail_key ? 1 : 0
  target_key_id = aws_kms_key.cloudtrail[0].key_id
  name          = "alias/${local.system_name}-cloudtrail"
}
