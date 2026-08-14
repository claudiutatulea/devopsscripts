output "vpc_id" {
  description = "The VPC id"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "public_route_table_id" {
  description = "Public route table id"
  value       = aws_route_table.public.id
}

output "web_security_group_id" {
  description = "Security group ID for web servers"
  value       = aws_security_group.web_sg.id
}

output "web_target_group_arn" {
  description = "ARN of the web target group"
  value       = aws_lb_target_group.web_tg.arn
}