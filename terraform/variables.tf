variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "cluster_identifier" {
  description = "Identifier for the DocumentDB cluster"
  type        = string
  default     = "my-docdb-cluster"
}

variable "master_username" {
  description = "Username for the DocumentDB master user"
  type        = string
  default     = "root"
}

variable "master_password" {
  description = "Password for the DocumentDB master user"
  type        = string
  sensitive   = true
}

variable "instance_count" {
  description = "Number of DocumentDB instances to create"
  type        = number
  default     = 2
}

variable "instance_class" {
  description = "Instance class for DocumentDB instances"
  type        = string
  default     = "db.t3.medium"
}

variable "vpc_id" {
  description = "VPC ID where DocumentDB will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for DocumentDB subnet group"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to DocumentDB"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}
