##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

output "cloudtrail_bucket_name" {
  description = "Name of the S3 bucket receiving the CloudTrail logs, null on spoke accounts"
  value       = var.is_hub ? module.cloudtrail.s3_bucket_id : null
}

output "cloudtrail_kms_key_id" {
  description = "ID of the KMS key encrypting the trail and its bucket, module managed or resolved from settings.encryption, null when encryption is disabled or on spoke accounts"
  value       = var.is_hub ? local.cloudtrail_kms_key_id : null
}

output "cloudtrail_kms_key_arn" {
  description = "ARN of the KMS key encrypting the trail and its bucket, null when encryption is disabled or on spoke accounts"
  value       = var.is_hub ? local.cloudtrail_kms_key_arn : null
}

output "cloudtrail_kms_key_alias" {
  description = "Alias of the KMS key encrypting the trail and its bucket, null when the key was given by id or ARN, when encryption is disabled or on spoke accounts"
  value       = var.is_hub ? local.cloudtrail_kms_key_alias : null
}

output "cloudwatch_kms_key_id" {
  description = "ID of the KMS key encrypting the CloudWatch log group, module managed or resolved from settings.cloudwatch, null when encryption is disabled or on spoke accounts"
  value       = var.is_hub ? local.cloudwatch_kms_key_id : null
}

output "cloudwatch_kms_key_arn" {
  description = "ARN of the KMS key encrypting the CloudWatch log group, null when encryption is disabled or on spoke accounts"
  value       = var.is_hub ? local.cloudwatch_kms_key_arn : null
}

output "cloudwatch_kms_key_alias" {
  description = "Alias of the KMS key encrypting the CloudWatch log group, null when the key was given by id or ARN, when encryption is disabled or on spoke accounts"
  value       = var.is_hub ? local.cloudwatch_kms_key_alias : null
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group the trail delivers to, null on spoke accounts"
  value       = var.is_hub ? aws_cloudwatch_log_group.cloudtrail[0].name : null
}
