terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.86.0"
    }
  }
}
provider "aws" {
  region = "eu-central-1"
}

data "aws_caller_identity" "current" {}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "nginx_proxy_sg" {
  name_prefix = "nginx_proxy_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_ssm_parameter" "github_pat" {
  name        = "github_pat"
  description = "GitHub Personal Access Token for repository access"
  type        = "SecureString"
  value       = "replace-with-actual-value"

  lifecycle {
    ignore_changes = [value]
  }
}


resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2_ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ssm_policy" {
  name = "ssm_policy"
  role = aws_iam_role.ec2_ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:DescribeParameters"
        ]
        Resource = aws_ssm_parameter.github_pat.arn
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_ssm_profile"
  role = aws_iam_role.ec2_ssm_role.name
}

resource "aws_instance" "nginx_proxy" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  key_name                    = "udevril@gmail.com"
  vpc_security_group_ids      = [aws_security_group.nginx_proxy_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name


  root_block_device {
    encrypted   = true
    volume_size = 8
    volume_type = "gp3"
  }

  tags = { Name = "NGINX Reverse Proxy" }

  user_data = templatefile("user_data.yml", {})
}

output "nginx_proxy_public_ip" {
  value = aws_instance.nginx_proxy.public_ip
}
