##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

## Settings documentation - YAML format
# settings:
#   organization:
#     account_id: "123456789012"
#     delegated: true | false                       # (optional) Whether the account will delegate organization management
#   cloudtrail_name: "my-cloudtrail"              # (required) Name of the CloudTrail, only required if is_hub is true
#   cloudtrail_s3_key_prefix: "cloudtrail-catch-all"  # (optional) S3 key prefix for CloudTrail logs, defaults to "cloudtrail-catch-all"
#   cloudtrail_bucket_name: "my-cloudtrail-bucket"  # (optional) Custom bucket name for CloudTrail logs, defaults to naming convetion
#   cloudtrail_expiration_days: 1500          # (optional) Number of days to retain CloudTrail logs, defaults to 5 years (1825 days)
#   cloudwatch_other_regions:                 # (optional) List of regions to enable CloudWatch logging for CloudTrail
#     - "us-west-1"
#     - "us-east-1"
#   multi_region: true | false                 # (optional) Whether the CloudTrail is multi-region, defaults to true
#   organization_trail: true | false           # (optional) Whether the CloudTrail is an organization trail, defaults to true
#   log_file_validation: true | false          # (optional) Whether to enable log file validation, defaults to true
#   enable_logging: true | false               # (optional) Whether to enable logging, defaults to true
#   include_global_events: true | false        # (optional) Whether to include global service events, defaults to true
#   trail_insight_type: "ApiCallRateInsight"  # (optional) Type of insight to enable, defaults to null
#   trail_event_selectors:                    # (optional) List of event selectors for the CloudTrail
#     - exclude_management_event_sources: ["s3.amazonaws.com"] # (optional) List of management event sources to exclude
#       include_management_events: true | false  # (optional) Whether to include management events, defaults to false
#       read_write_type: "ReadOnly" | "WriteOnly" | "All"  # (optional) Type of events to log, defaults to "ReadOnly"
#       data_resource:                            # (optional) Data resource configuration
#         type: "AWS::S3::Object"                # (optional) Type of data resource, defaults to "AWS::S3::Object"
#         values: ["arn:aws:s3:::*/*"]           # (optional) List of ARNs for data resources, defaults to all S3 objects
#   trail_advanced_event_selectors:           # (optional) List of advanced event selectors for the CloudTrail
#     - name: "MyAdvancedSelector"              # (optional) Name of the advanced event selector
#       field_selectors:                        # (optional) List of field selectors for the advanced event selector
#         - field: "eventCategory"              # (required) Field to filter on
#           equals: ["Management"]              # (optional) List of values to match for the field
#           not_equals: ["Data"]                # (optional) List of values to exclude for the field
#           starts_with: ["arn:aws:s3::"]       # (optional) List of values to match the start of the field
#           ends_with: ["*"]                    # (optional) List of values to match the end of the field
#           contains: ["s3"]                    # (optional) List of values to match within the field
#           not_contains: ["ec2"]               # (optional) List of values to exclude from the field
variable "settings" {
  description = "Module settings for Cloudtrail Setup"
  type        = any
  default     = {}
}