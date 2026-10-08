output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = aws_db_instance.this.endpoint
}

output "rds_master_secret_arn" {
  description = "Secrets Manager ARN for the RDS master password"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "cache_primary_endpoint" {
  description = "ElastiCache primary endpoint"
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}