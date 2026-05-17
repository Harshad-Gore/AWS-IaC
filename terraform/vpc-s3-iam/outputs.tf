output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}

output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.app.bucket
}

output "iam_user_arn" {
  description = "IAM user ARN"
  value       = aws_iam_user.user.arn
}
