terraform {
  required_version = "~> 1.9"

  required_providers {
    # Add your providers here, e.g.:
    # aws = {
    #   source  = "hashicorp/aws"
    #   version = "~> 5.0"
    # }
  }

  # Remote backend — configure for your environment:
  # backend "s3" {
  #   bucket = "my-tf-state"
  #   key    = "app/terraform.tfstate"
  #   region = "eu-west-1"
  # }
}

# Example resource — replace with your actual infrastructure:
# resource "aws_ecs_service" "app" {
#   name            = var.app_name
#   task_definition = "${var.app_name}:${var.image_tag}"
# }
