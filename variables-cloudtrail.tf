##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

## Settings documentation - YAML format
# settings:
#   organization:                             # (Optional) Organization delegation, only used on spoke accounts
#     account_id: "123456789012"              # (Required when delegated is true) Account to register as CloudTrail delegated administrator
#     delegated: true | false                 # (Optional) Whether the account will delegate organization management, defaults to false
#   cloudtrail_name: "my-cloudtrail"          # (Required) Name of the CloudTrail, only required if is_hub is true
#   cloudtrail_s3_key_prefix: "cloudtrail-catch-all"  # (Optional) S3 key prefix for CloudTrail logs, defaults to "cloudtrail-catch-all"
#   cloudtrail_bucket_name: "my-cloudtrail-bucket"  # (Optional) Custom bucket name for CloudTrail logs, defaults to naming convention
#   cloudtrail_expiration_days: 1500          # (Optional) Number of days to retain CloudTrail logs, defaults to 5 years (1825 days)
#   cloudwatch_expiration_days: 90            # (Optional) Number of days to retain the CloudWatch log group events, defaults to 90
#   cloudwatch_other_regions:                 # (Optional) List of regions to enable CloudWatch logging for CloudTrail
#     - "us-west-1"
#     - "us-east-1"
#   encryption:                               # (Optional) KMS encryption of the trail, its S3 bucket and the CloudWatch log group, defaults to enabled with module managed keys
#     enabled: true | false                   # (Optional) Enable KMS encryption, defaults to true. When false no key is created or looked up: the trail
#                                             #            delivers unencrypted logs, the bucket uses SSE-S3 (AES256) and the log group uses the CloudWatch default
#     kms_key_id: "1234abcd-..."              # (Optional) Existing KMS key id or ARN for the trail and its bucket. Its policy must grant cloudtrail.amazonaws.com,
#                                             #            the module only manages the policy of the key it creates. Defaults to "" (module managed key)
#     kms_key_alias: "alias/my-key"           # (Optional) Existing KMS key alias for the trail and its bucket, used only when kms_key_id is not set; the "alias/"
#                                             #            prefix is added when missing. Defaults to "" (module managed key)
#     deletion_window: 15                     # (Optional) Deletion window in days for the module managed keys, defaults to 15. Possible values: 7 to 30
#     rotation_enabled: true | false          # (Optional) Enable automatic rotation of the module managed keys, defaults to true
#     rotation_period: 90                     # (Optional) Rotation period in days for the module managed keys, defaults to 90. Possible values: 90 to 2560.
#                                             #            Only applies when rotation_enabled is true
#     multi_region: true | false              # (Optional) Create the module managed keys as multi-region keys, defaults to false
#   cloudwatch:                               # (Optional) CloudWatch log group encryption key, only used when encryption.enabled is true
#     kms_key_id: "1234abcd-..."              # (Optional) Existing KMS key id or ARN for the log group. Its policy must grant logs.<region>.amazonaws.com.
#                                             #            Defaults to "" (module managed key). The trail key is never reused for the log group
#     kms_key_alias: "alias/my-key"           # (Optional) Existing KMS key alias for the log group, used only when kms_key_id is not set; the "alias/"
#                                             #            prefix is added when missing. Defaults to "" (module managed key)
#   multi_region: true | false                # (Optional) Whether the CloudTrail is multi-region, defaults to true
#   organization_trail: true | false          # (Optional) Whether the CloudTrail is an organization trail, defaults to true
#   log_file_validation: true | false         # (Optional) Whether to enable log file validation, defaults to true
#   enable_logging: true | false              # (Optional) Whether to enable logging, defaults to true
#   include_global_events: true | false       # (Optional) Whether to include global service events, defaults to true
#   trail_insight_type: "ApiCallRateInsight"  # (Optional) Type of insight to enable, defaults to null. Possible values: "ApiCallRateInsight", "ApiErrorRateInsight"
#   trail_event_selectors:                    # (Optional) List of event selectors for the CloudTrail
#     - exclude_management_event_sources: ["s3.amazonaws.com"] # (Optional) List of management event sources to exclude
#       include_management_events: true | false  # (Optional) Whether to include management events, defaults to false
#       read_write_type: "ReadOnly" | "WriteOnly" | "All"  # (Optional) Type of events to log, defaults to "ReadOnly"
#       data_resource:                            # (Optional) Data resource configuration
#         type: "AWS::S3::Object"                # (Optional) Type of data resource, defaults to "AWS::S3::Object"
#         values: ["arn:aws:s3:::*/*"]           # (Optional) List of ARNs for data resources, defaults to all S3 objects
#   trail_advanced_event_selectors:           # (Optional) List of advanced event selectors for the CloudTrail
#     - name: "MyAdvancedSelector"              # (Optional) Name of the advanced event selector
#       field_selectors:                        # (Optional) List of field selectors for the advanced event selector
#         - field: "eventCategory"              # (Required) Field to filter on
#           equals: ["Management"]              # (Optional) List of values to match for the field
#           not_equals: ["Data"]                # (Optional) List of values to exclude for the field
#           starts_with: ["arn:aws:s3::"]       # (Optional) List of values to match the start of the field
#           not_starts_with: ["arn:aws:ec2::"]  # (Optional) List of values to exclude by the start of the field
#           ends_with: ["*"]                    # (Optional) List of values to match the end of the field
#           not_ends_with: ["/"]                # (Optional) List of values to exclude by the end of the field
variable "settings" {
  description = "Module settings for Cloudtrail Setup"
  type        = any
  default     = {}

  validation {
    condition     = try(var.settings.encryption.deletion_window, 15) >= 7 && try(var.settings.encryption.deletion_window, 15) <= 30
    error_message = "settings.encryption.deletion_window must be between 7 and 30 days."
  }

  validation {
    condition     = try(var.settings.encryption.rotation_period, 90) >= 90 && try(var.settings.encryption.rotation_period, 90) <= 2560
    error_message = "settings.encryption.rotation_period must be between 90 and 2560 days."
  }
}
