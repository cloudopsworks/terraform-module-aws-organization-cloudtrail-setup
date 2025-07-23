##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  cloudtrail_bucket_name = (
    try(var.settings.cloudtrail_bucket_name, "") != "" ? var.settings.cloudtrail_bucket_name :
    format("org-cloudtrail-%s-%s", local.system_name, random_string.cloudtrail[0].result)
  )
}

resource "random_string" "cloudtrail" {
  count   = try(var.settings.cloudtrail_bucket_name, "") == "" ? 1 : 0
  length  = 8
  special = false
  lower   = true
  upper   = false
  numeric = true
}

module "cloudtrail" {
  source                                = "terraform-aws-modules/s3-bucket/aws"
  version                               = "~> 4.1"
  create_bucket                         = var.is_hub
  bucket                                = local.cloudtrail_bucket_name
  acl                                   = "private"
  control_object_ownership              = true
  object_ownership                      = "BucketOwnerPreferred"
  attach_lb_log_delivery_policy         = false
  attach_elb_log_delivery_policy        = false
  attach_deny_insecure_transport_policy = true
  attach_public_policy                  = true
  block_public_acls                     = true
  block_public_policy                   = true
  ignore_public_acls                    = true
  restrict_public_buckets               = true
  attach_policy                         = true
  policy                                = var.is_hub ? data.aws_iam_policy_document.cloudtrail_s3[0].json : null
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = var.is_hub ? aws_kms_key.cloudtrail[0].arn : null
        sse_algorithm     = "aws:kms"
      }
    }
  }
  versioning = {
    enabled = false
    # status     = false
    # mfa        = false
    # mfa_delete = false
  }
  lifecycle_rule = [
    {
      id      = "purge-logs"
      enabled = true
      filter = {
        prefix = "${local.cloudtrail_s3_key_prefix}/AWSLogs"
      }
      expiration = {
        days = try(var.settings.cloudtrail_expiration_days, 365 * 5)
      }
    }
  ]
  tags = local.all_tags
}

data "aws_iam_policy_document" "cloudtrail_s3" {
  count   = var.is_hub ? 1 : 0
  version = "2012-10-17"

  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${local.cloudtrail_bucket_name}"]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
    actions = ["s3:PutObject"]
    resources = [
      "arn:aws:s3:::${local.cloudtrail_bucket_name}/${local.cloudtrail_s3_key_prefix}/AWSLogs/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid    = "AWSCloudTrailAclCheckFromTrail"
    effect = "Allow"
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${local.cloudtrail_bucket_name}"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${var.settings.cloudtrail_name}"
      ]
    }
  }

  statement {
    sid    = "AWSCloudTrailWriteFromTrail"
    effect = "Allow"
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
    actions = ["s3:PutObject"]
    resources = [
      "arn:aws:s3:::${local.cloudtrail_bucket_name}/${local.cloudtrail_s3_key_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${var.settings.cloudtrail_name}"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWriteOrganization"
    effect = "Allow"
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
    actions = ["s3:PutObject"]
    resources = [
      "arn:aws:s3:::${local.cloudtrail_bucket_name}/${local.cloudtrail_s3_key_prefix}/AWSLogs/${data.aws_organizations_organization.current.id}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${var.settings.cloudtrail_name}"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}
