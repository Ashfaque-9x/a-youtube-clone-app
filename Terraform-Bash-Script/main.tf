# Security group for instances
resource "aws_security_group" "security_group" {
  name        = "YouTube-sg"
  description = "Allow inbound traffic"

  dynamic "ingress" {
    for_each = [22, 80, 443, 8080, 8081, 8082, 9000, 3000]
    content {
      description      = "inbound rule for port ${ingress.value}"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# Instances
resource "aws_instance" "ec1" {
  ami                    = "ami-0287a05f0ef0e9d9a"
  instance_type          = "t2.micro"
  key_name               = "ec2-project-key"
  vpc_security_group_ids = [aws_security_group.security_group.id]
  user_data              = templatefile("./jenkins-master.sh", {})

  tags = {
    Name = "Jenkins-master"
  }

  root_block_device {
    volume_size = 15
  }
}

resource "aws_instance" "ec2" {
  ami                    = "ami-0287a05f0ef0e9d9a"
  instance_type          = "t2.small"
  key_name               = "ec2-project-key"
  vpc_security_group_ids = [aws_security_group.security_group.id]
  user_data              = templatefile("./jenkins-slave.sh", {})

  tags = {
    Name = "Jenkins-slave"
  }

  root_block_device {
    volume_size = 20
  }
}

resource "aws_instance" "ec3" {
  ami                    = "ami-0287a05f0ef0e9d9a"
  instance_type          = "t3.medium"
  key_name               = "ec2-project-key"
  vpc_security_group_ids = [aws_security_group.security_group.id]
  user_data              = templatefile("./sonar-trivy-pg.sh", {})

  tags = {
    Name = "Sonar-Trivy-Prometheus"
  }

  root_block_device {
    volume_size = 30
  }
}

resource "aws_instance" "ec4" {
  ami                    = "ami-0287a05f0ef0e9d9a"
  instance_type          = "t3.small"
  key_name               = "ec2-project-key"
  vpc_security_group_ids = [aws_security_group.security_group.id]
  user_data              = templatefile("./eks.sh", {})

  tags = {
    Name = "EKS-Bootstrap"
  }

  root_block_device {
    volume_size = 15
  }
}
