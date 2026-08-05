variable "state_bucket" {
  description = "S3 bucket used for Terraform remote state"
  type        = string
}

variable "state_region" {
  description = "AWS region for the remote state bucket"
  type        = string
}

variable "state_table" {
  description = "DynamoDB table used for Terraform state locking"
  type        = string
}
