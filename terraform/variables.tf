variable "image_tag" {
  description = "Docker image tag (git SHA) to deploy"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "app"
}

variable "environment" {
  description = "Deployment environment (e.g. staging, production)"
  type        = string
  default     = "production"
}
