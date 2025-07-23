##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  cloudwatch_log_name = var.is_hub ? "/cloudtrails/${var.settings.cloudtrail_name}" : null
}
resource "aws_cloudwatch_log_group" "cloudtrail" {
  count             = var.is_hub ? 1 : 0
  name              = local.cloudwatch_log_name
  retention_in_days = try(var.settings.cloudwatch_expiration_days, 90)
  kms_key_id        = aws_kms_key.cloudwatch[0].arn
  tags              = local.all_tags
}

