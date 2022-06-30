variable "tags" {
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)"
  type        = map(any)
  default     = {}
}

variable "deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction of the resource"
  default     = 10
}

variable "enable_key_rotation" {
  description = "Specifies whether key rotation is enabled"
  default     = "true"
}

variable "description" {
  description = "The description of the key as viewed in AWS console"
  type        = string
  default     = "Parameter Store KMS master key"
}

variable "alias" {
  description = "The display name of the alias. The name must start with the word `alias` followed by a forward slash"
  type        = string
  default     = ""
}

variable "iam_policy" {
  description = "The IAM policy to apply to the KMS key"
  type        = string
  default     = ""
}
