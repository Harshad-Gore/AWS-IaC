variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.40.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR"
  type        = string
  default     = "10.40.1.0/24"
}

variable "public_az" {
  description = "Public subnet AZ"
  type        = string
  default     = "ap-south-1a"
}

variable "bucket_prefix" {
  description = "S3 bucket prefix"
  type        = string
  default     = "exam-s3-"
}

variable "iam_user_name" {
  description = "IAM user name"
  type        = string
  default     = "exam-iam-user"
}
