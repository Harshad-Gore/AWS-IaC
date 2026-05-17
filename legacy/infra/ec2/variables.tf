variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI ID"
  type        = string
  # Ubuntu 22.04 LTS for different regions:
  # us-east-1: ami-0866a3c8686eaeeba
  # us-west-2: ami-05134c8ef96964280
  # ap-south-1: ami-0f58b397bc5c1f2e8
  default = "ami-0f58b397bc5c1f2e8"  # ap-south-1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
