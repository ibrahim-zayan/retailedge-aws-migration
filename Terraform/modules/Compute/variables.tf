variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances"
  type        = number
}

variable "min_size" {
  description = "Minimum number of EC2 instances"
  type        = number
}

variable "max_size" {
  description = "Maximum number of EC2 instances"
  type        = number
}

variable "app_port" {
  description = "Port used by the application"
  type        = number
}

variable "alb_port" {
  description = "Port used by the ALB listener"
  type        = number
}

variable "ami_id" {
  description = "AMI ID used by the Launch Template"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the application"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)
}

variable "app_subnet_ids" {
  description = "Private application subnet IDs for the ASG"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security Group ID for the ALB"
  type        = string
}

variable "app_security_group_id" {
  description = "Security Group ID for application instances"
  type        = string
}