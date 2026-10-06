output "alb_dns_name" {
  description = "DNS name of the RetailEdge Application Load Balancer"
  value       = aws_lb.app.dns_name
}

output "alb_arn" {
  description = "ARN of the RetailEdge Application Load Balancer"
  value       = aws_lb.app.arn
}

output "target_group_arn" {
  description = "ARN of the application target group"
  value       = aws_lb_target_group.app.arn
}

output "autoscaling_group_name" {
  description = "Name of the RetailEdge Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}