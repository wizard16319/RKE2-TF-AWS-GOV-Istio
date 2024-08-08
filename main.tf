#### Terraform Configuration
provider "aws" {
  region = "us-gov-west-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-gov-west-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "rke2" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "rke2_server" {
  ami           = "ami-0c55b159cbfafe1f0" # Ubuntu 20.04 LTS for GovCloud
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.subnet_a.id
  security_groups = [aws_security_group.rke2.name]

  tags = {
    Name = "RKE2-Server"
  }
}

resource "aws_instance" "rke2_agent" {
  count         = 2
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.subnet_a.id
  security_groups = [aws_security_group.rke2.name]

  tags = {
    Name = "RKE2-Agent"
  }
}
