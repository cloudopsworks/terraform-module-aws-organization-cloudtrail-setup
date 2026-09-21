##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  # Trail and bucket encryption. The module manages its own key unless an existing key id, ARN or
  # alias is configured, and creates no key at all when encryption is disabled. The raw alias is
  # kept alongside the normalised one so an unset alias stays distinguishable from a normalised
  # empty one, which would otherwise read as "alias/".
  encryption_enabled       = try(var.settings.encryption.enabled, true)
  encryption_key_id        = try(var.settings.encryption.kms_key_id, "")
  encryption_key_alias_raw = try(var.settings.encryption.kms_key_alias, "")
  encryption_key_alias     = startswith(local.encryption_key_alias_raw, "alias/") ? local.encryption_key_alias_raw : format("alias/%s", local.encryption_key_alias_raw)
  create_cloudtrail_key    = var.is_hub && local.encryption_enabled && local.encryption_key_id == "" && local.encryption_key_alias_raw == ""

  # CloudWatch log group encryption. Falls back to a module managed key only: the trail key policy
  # carries no CloudWatch Logs grant, so it is never reused for the log group.
  cw_encryption_key_id        = try(var.settings.cloudwatch.kms_key_id, "")
  cw_encryption_key_alias_raw = try(var.settings.cloudwatch.kms_key_alias, "")
  cw_encryption_key_alias     = startswith(local.cw_encryption_key_alias_raw, "alias/") ? local.cw_encryption_key_alias_raw : format("alias/%s", local.cw_encryption_key_alias_raw)
  create_cloudwatch_key       = var.is_hub && local.encryption_enabled && local.cw_encryption_key_id == "" && local.cw_encryption_key_alias_raw == ""

  # Module managed key parameters, shared by the trail and the log group keys
  kms_deletion_window  = try(var.settings.encryption.deletion_window, 15)
  kms_rotation_enabled = try(var.settings.encryption.rotation_enabled, true)
  kms_rotation_period  = try(var.settings.encryption.rotation_period, 90)
  kms_multi_region     = try(var.settings.encryption.multi_region, false)

  # Resolved keys handed to the trail, the bucket and the log group. coalesce is required here:
  # one() yields null on an empty list rather than raising, so a try() chain would always return
  # its first argument and the fallbacks would never be reached.
  cloudtrail_kms_key_arn = local.encryption_enabled ? try(coalesce(
    one(aws_kms_key.cloudtrail[*].arn),
    one(data.aws_kms_key.cloudtrail[*].arn),
    one(data.aws_kms_alias.cloudtrail[*].target_key_arn),
  ), null) : null
  cloudtrail_kms_key_id = local.encryption_enabled ? try(coalesce(
    one(aws_kms_key.cloudtrail[*].key_id),
    one(data.aws_kms_key.cloudtrail[*].id),
    one(data.aws_kms_alias.cloudtrail[*].target_key_id),
  ), null) : null
  cloudtrail_kms_key_alias = local.encryption_enabled ? try(coalesce(
    one(aws_kms_alias.cloudtrail[*].name),
    local.encryption_key_alias_raw != "" ? local.encryption_key_alias : null,
  ), null) : null

  cloudwatch_kms_key_arn = local.encryption_enabled ? try(coalesce(
    one(aws_kms_key.cloudwatch[*].arn),
    one(data.aws_kms_key.cloudwatch[*].arn),
    one(data.aws_kms_alias.cloudwatch[*].target_key_arn),
  ), null) : null
  cloudwatch_kms_key_id = local.encryption_enabled ? try(coalesce(
    one(aws_kms_key.cloudwatch[*].key_id),
    one(data.aws_kms_key.cloudwatch[*].id),
    one(data.aws_kms_alias.cloudwatch[*].target_key_id),
  ), null) : null
  cloudwatch_kms_key_alias = local.encryption_enabled ? try(coalesce(
    one(aws_kms_alias.cloudwatch[*].name),
    local.cw_encryption_key_alias_raw != "" ? local.cw_encryption_key_alias : null,
  ), null) : null
}

data "aws_kms_key" "cloudtrail" {
  count  = var.is_hub && local.encryption_enabled && local.encryption_key_id != "" ? 1 : 0
  key_id = local.encryption_key_id
}

data "aws_kms_alias" "cloudtrail" {
  count = (var.is_hub && local.encryption_enabled &&
    local.encryption_key_id == "" &&
    local.encryption_key_alias_raw != "" ? 1 : 0
  )
  name = local.encryption_key_alias
}

data "aws_kms_key" "cloudwatch" {
  count  = var.is_hub && local.encryption_enabled && local.cw_encryption_key_id != "" ? 1 : 0
  key_id = local.cw_encryption_key_id
}

data "aws_kms_alias" "cloudwatch" {
  count = (var.is_hub && local.encryption_enabled &&
    local.cw_encryption_key_id == "" &&
    local.cw_encryption_key_alias_raw != "" ? 1 : 0
  )
  name = local.cw_encryption_key_alias
}
