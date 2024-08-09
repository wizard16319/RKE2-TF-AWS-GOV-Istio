#### Fixed AMI issues, fixed conflict with Subnets, fixed resource parameter types, works as of 08--08 for testing
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
  ami           = "ami-0e7315f6773f0b25e"  # To get your ami run this command: aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" --query "Images[*].[ImageId,CreationDate]" --region us-gov-west-1 --output text | sort -k2 -r | head -n 1
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.subnet_a.id
  vpc_security_group_ids = [aws_security_group.rke2.id]  # Use vpc_security_group_ids instead of security_group_ids was the fix here

  tags = {
    Name = "RKE2-Server"
  }
}

resource "aws_instance" "rke2_agent" {
  count         = 2
  ami           = "ami-0e7315f6773f0b25e"  # Replace with a valid AMI ID from the above command
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.subnet_a.id
  vpc_security_group_ids = [aws_security_group.rke2.id]  # Use vpc_security_group_ids instead of security_group_ids

  tags = {
    Name = "RKE2-Agent-${count.index + 1}"
  }
}
