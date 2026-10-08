variable "db_subnet_ids" {
  description = "Private DB subnet IDs for RDS and ElastiCache"
  type        = list(string)
}

variable "db_security_group_id" {
  description = "Security group ID attached to RDS"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "db_allocated_storage" {
  description = "RDS storage in GiB"
  type        = number
  default     = 100
}