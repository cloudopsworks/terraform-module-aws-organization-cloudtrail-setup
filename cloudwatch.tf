##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
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

