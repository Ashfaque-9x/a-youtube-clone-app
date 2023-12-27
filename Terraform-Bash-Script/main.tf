# create VPC
resource "aws_vpc" "yt-vpc" {
  cidr_block = "10.10.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# create subnet
resource "aws_subnet" "yt-subnet" {
  vpc_id      = aws_vpc.yt-vpc.id
  cidr_block  = "10.10.10.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "yt-subnet"
  }
}

# create internet gateway
resource "aws_internet_gateway" "yt-igw" {
  vpc_id = aws_vpc.yt-vpc.id

  tags = {
    Name = "yt-igw"
  }
}

# create route table
resource "aws_route_table" "yt-rt" {
  vpc_id = aws_vpc.yt-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.yt-igw.id
  }

  tags = {
    Name = "yt-rt"
  }
}

# associate subnet with route table
resource "aws_route_table_association" "yt-rta" {
  subnet_id       = aws_subnet.yt-subnet.id
  route_table_id  = aws_route_table.yt-rt.id
}


# Security group for instances
resource "aws_security_group" "YouTube-sg" {
  name        = "YouTube-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.yt-vpc.id

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
  vpc_security_group_ids = [aws_security_group.YouTube-sg.id]
  user_data              = templatefile("./jenkins-master.sh", {})
  subnet_id              = aws_subnet.yt-subnet.id 
  associate_public_ip_address = true

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
  vpc_security_group_ids = [aws_security_group.YouTube-sg.id]
  user_data              = templatefile("./jenkins-slave.sh", {})
  subnet_id              = aws_subnet.yt-subnet.id 
  associate_public_ip_address = true

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
  vpc_security_group_ids = [aws_security_group.YouTube-sg.id]
  user_data              = templatefile("./sonar-trivy-pg.sh", {})
  subnet_id              = aws_subnet.yt-subnet.id 
  associate_public_ip_address = true

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
  vpc_security_group_ids = [aws_security_group.YouTube-sg.id]
  user_data              = templatefile("./eks.sh", {})
  subnet_id              = aws_subnet.yt-subnet.id 
  associate_public_ip_address = true

  tags = {
    Name = "EKS-Bootstrap"
  }

  root_block_device {
    volume_size = 15
  }
}
