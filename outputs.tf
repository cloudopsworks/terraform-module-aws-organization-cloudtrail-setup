##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

output "cloudtrail_bucket_name" {
  value = var.is_hub ? module.cloudtrail.s3_bucket_id : null
}

output "cloudtrail_kms_key_id" {
  value = var.is_hub ? aws_kms_key.cloudtrail[0].key_id : null
}

output "cloudtrail_kms_key_alias" {
  value = var.is_hub ? aws_kms_alias.cloudtrail[0].name : null
}

output "cloudwatch_kms_key_id" {
  value = var.is_hub ? aws_kms_key.cloudwatch[0].key_id : null
}

output "cloudwatch_kms_key_alias" {
  value = var.is_hub ? aws_kms_alias.cloudtrail[0].name : null
}

output "cloudwatch_log_group_name" {
  value = var.is_hub ? aws_cloudwatch_log_group.cloudtrail[0].name : null
}