variable "vpc_cidr" {
  description = "CIDR block for the RetailEdge VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones used by RetailEdge"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}