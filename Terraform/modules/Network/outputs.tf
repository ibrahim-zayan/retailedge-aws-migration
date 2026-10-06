output "vpc_id" {
  description = "ID of the RetailEdge VPC"
  value       = aws_vpc.retailedge.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "app_subnet_ids" {
  description = "IDs of the private application subnets"
  value = [
    aws_subnet.app_a.id,
    aws_subnet.app_b.id
  ]
}

output "db_subnet_ids" {
  description = "IDs of the private database subnets"
  value = [
    aws_subnet.db_a.id,
    aws_subnet.db_b.id
  ]
}

output "alb_security_group_id" {
  description = "Security Group ID for the Application Load Balancer"
  value       = aws_security_group.alb_sg.id
}

output "app_security_group_id" {
  description = "Security Group ID for application servers"
  value       = aws_security_group.app_sg.id
}

output "db_security_group_id" {
  description = "Security Group ID for the database"
  value       = aws_security_group.db_sg.id
}