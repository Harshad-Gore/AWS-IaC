output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.web_server.id
}

output "public_ip" {
  description = "Public IP address"
  value       = aws_instance.web_server.public_ip
}

output "public_dns" {
  description = "Public DNS name"
  value       = aws_instance.web_server.public_dns
}

output "web_url" {
  description = "Web server URL"
  value       = "http://${aws_instance.web_server.public_ip}"
}
