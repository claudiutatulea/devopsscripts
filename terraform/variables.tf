variable "image_tag" {
  description = "Docker image tag (git SHA) to deploy"
  type        = string
  default     = "local"
}

variable "project_name" {
  description = "2 ubuntu web server - AWS starter project"
  type        = string
  default     = "terraform-starter"
}

variable "environment" {
  description = "Deployment environment (development, qa, production)"
  type        = string
  default     = "development"
}

variable "aws_region" {
  description = "AWS region for the deployment"
  type        = string
  default     = "eu-north-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets used by the load balancer"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets used by the web servers"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "instance_type" {
  description = "EC2 instance size for the web servers"
  type        = string
  default     = "t3.micro"
}

variable "admin_cidr" {
  description = "CIDR block allowed to reach SSH"
  type        = string
  default     = "0.0.0.0/0"
}
