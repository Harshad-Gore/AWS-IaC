provider "aws" {
  region = "ap-south-1"   # Change region if needed
}


resource "aws_key_pair" "my_key" {
  key_name   = "my-terraform-key"
  public_key = file("key2.ppk")  # Path to your public key
}


resource "aws_security_group" "my_sg" {
  name        = "my-security-group"
  description = "Allow SSH and HTTP"
  vpc_id      = "vpc-0a1a9c27cb913a539"  # Replace with your VPC ID

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "My-SG"
  }
}



resource "aws_instance" "my_ec2" {
  ami           = "ami-0f5ee92e2d63afc18"  # Amazon Linux 2 (ap-south-1)
  instance_type = "t2.micro"

  subnet_id              = "subnet-00a31c6fdba6bbf6c"   # Replace with your subnet ID
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  key_name               = aws_key_pair.my_key.key_name

  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install httpd -y
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Server Launched using Terraform</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "My-Terraform-Server"
  }
}


output "instance_public_ip" {
  value = aws_instance.my_ec2.public_ip
}