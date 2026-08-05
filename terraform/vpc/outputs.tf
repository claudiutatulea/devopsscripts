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