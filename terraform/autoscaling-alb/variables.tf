variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_id" {
  description = "Optional VPC ID override"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Optional subnet IDs override"
  type        = list(string)
  default     = []
}

variable "ami_id" {
  description = "AMI ID for instances"
  type        = string
  default     = "ami-0f5ee92e2d63afc18"
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.micro"
}

variable "min_size" {
  description = "Minimum instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum instances"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Desired instances"
  type        = number
  default     = 1
}

variable "key_name" {
  description = "Optional key pair name"
  type        = string
  default     = ""
}
