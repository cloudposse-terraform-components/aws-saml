variable "region" {
  type        = string
  description = "AWS Region"
}

variable "saml_providers" {
  type        = map(string)
  description = "Map of provider names to XML data filenames"
}

variable "attach_permissions_to_group" {
  type        = bool
  default     = false
  description = "If true, attach IAM permissions to a group rather than directly to the API user"
  nullable    = false
}
