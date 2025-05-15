##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  cloudtrail_s3_key_prefix = try(var.settings.cloudtrail_s3_key_prefix, "cloudtrail-catch-all")
}

resource "aws_organizations_delegated_administrator" "this" {
  count             = try(var.settings.organization.delegated, false) && (!var.is_hub) ? 1 : 0
  account_id        = var.settings.organization.account_id
  service_principal = "cloudtrail.amazonaws.com"
}

resource "aws_cloudtrail" "this" {
  count                         = var.is_hub ? 1 : 0
  name                          = var.settings.cloudtrail_name
  s3_bucket_name                = module.cloudtrail.s3_bucket_id
  s3_key_prefix                 = local.cloudtrail_s3_key_prefix
  is_multi_region_trail         = try(var.settings.multi_region, true)
  is_organization_trail         = try(var.settings.organization_trail, true)
  enable_log_file_validation    = try(var.settings.log_file_validation, true)
  enable_logging                = try(var.settings.enable_logging, true)
  kms_key_id                    = aws_kms_key.cloudtrail[0].arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail[0].arn
  include_global_service_events = try(var.settings.include_global_events, true)

  dynamic "insight_selector" {
    for_each = try(var.settings.trail_insight_type, "") != "" ? [1] : []
    content {
      insight_type = var.settings.trail_insight_type
    }
  }

  dynamic "event_selector" {
    for_each = try(var.settings.trail_event_selectors, [])
    content {
      exclude_management_event_sources = try(event_selector.value.exclude_management_event_sources, [])
      include_management_events        = try(event_selector.value.include_management_events, false)
      read_write_type                  = try(event_selector.value.read_write_type, "ReadOnly")

      dynamic "data_resource" {
        for_each = length(try(event_selector.value.data_resource, {})) > 0 ? [1] : []
        content {
          type   = try(event_selector.value.data_resource.type, "AWS::S3::Object")
          values = try(event_selector.value.data_resource.values, ["arn:aws:s3:::*/*"])
        }
      }
    }
  }

  dynamic "advanced_event_selector" {
    for_each = try(var.settings.trail_advanced_event_selectors, [])
    content {
      name = try(advanced_event_selector.value.name, null)

      dynamic "field_selector" {
        for_each = try(advanced_event_selector.value.field_selectors, [])
        content {
          field           = field_selector.value.field
          ends_with       = try(field_selector.value.ends_with, null)
          equals          = try(field_selector.value.equals, null)
          not_ends_with   = try(field_selector.value.not_ends_with, null)
          not_equals      = try(field_selector.value.not_equals, null)
          not_starts_with = try(field_selector.value.not_starts_with, null)
          starts_with     = try(field_selector.value.starts_with, null)
        }
      }
    }
  }
  tags = local.all_tags
}