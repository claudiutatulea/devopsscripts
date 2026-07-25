output "deployed_image_tag" {
  description = "The image tag that was deployed"
  value       = var.image_tag
}

output "alb_dns_name" {
  description = "DNS name of the public application load balancer"
  value       = aws_lb.app.dns_name
}

output "web_instance_ids" {
  description = "IDs of the private web instances"
  value       = aws_instance.web[*].id
}

output "web_private_ips" {
  description = "Private IP addresses of the web instances"
  value       = aws_instance.web[*].private_ip
}
