provider "aws" {
  region = "us-east-1"  # Change if needed
}

resource "aws_security_group" "focalboard_sg" {
  name        = "focalboard-security-group"
  description = "Allow inbound traffic for Focalboard"
  
  # Allow HTTP (80) and HTTPS (443)
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

  # Allow Focalboard port (default: 8000)
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH for access
  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "focalboard" {
  ami           = "ami-085ad6ae776d8f09c"  # Amazon Linux 2 AMI (Change based on region)
  instance_type = "t2.micro"
  key_name      = "ssh.pem"  # Change to your SSH key
  security_groups = [aws_security_group.focalboard_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ec2-user
              docker run -d -p 8000:8000 --name focalboard mattermost/focalboard
              EOF

  tags = {
    Name = "Focalboard-Server"
  }
}
