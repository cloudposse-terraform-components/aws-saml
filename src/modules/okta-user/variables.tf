# AWS KMS alias used for encryption/decryption
# default is alias used in SSM
variable "kms_alias_name" {
  type        = string
  default     = "alias/aws/ssm"
  description = "The name of the KMS alias used for encryption/decryption of SSM parameters (API key)"
}

variable "attach_permissions_to_group" {
  type        = bool
  default     = false
  description = "If true, attach IAM permissions to a group rather than directly to the API user"
}
