variable "vpc" {
  description = "vpc"
  type = object({
    prefix = string
    cidr = string
    region = string
  })
}
variable "ssh_allow_cidr" {type = list(string)}
variable "web_allow_cidr" {type = list(string)}
variable "private_subnets" {
  description = "private subnets"
  type = list(string)
}
variable "public_subnets" {
  description = "private subnets"
  type = list(string)
}
variable "key_pair" {}
variable "instance_type" {}

provider "aws" {}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc.cidr
  tags = {
    Name = "${var.vpc.prefix}-vpc"
  }
}

resource "aws_subnet" "private-sub-1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.private_subnets[0]
  availability_zone = "${var.vpc.region}a"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.vpc.prefix}-private-sub-1"
  }
}

resource "aws_subnet" "private-sub-2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.private_subnets[1]
  availability_zone = "${var.vpc.region}b"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.vpc.prefix}-private-sub-2"
  }
}

resource "aws_subnet" "public-sub-3" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.public_subnets[0]
  availability_zone = "${var.vpc.region}c"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc.prefix}-public-sub-3"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc.prefix}-igw"
  }
}

resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  tags = {
    Name = "${var.vpc.prefix}-default-route-table"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.vpc.prefix}-route-table"
  }
}

resource "aws_route_table_association" "public_association" {
  route_table_id = aws_route_table.route_table.id
  subnet_id = aws_subnet.public-sub-3.id
}

resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc.prefix}-default-sg"
  }
  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    cidr_blocks = var.ssh_allow_cidr
  }
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
  }
}

resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.vpc.id
  name = "web-sg"
  tags = {
    Name = "${var.vpc.prefix}-web-sg"
  }
  ingress {
    from_port = 8080
    protocol  = "tcp"
    to_port   = 8080
    cidr_blocks = var.web_allow_cidr
  }
}

data "aws_ami" "latest_amazon_ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_key_pair" "key_pair" {
  key_name = "${var.vpc.prefix}-key-pair"
  public_key = file(var.key_pair)
}

resource "aws_instance" "web_server" {
  ami = data.aws_ami.latest_amazon_ami.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.public-sub-3.id
  key_name = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [
    aws_security_group.web_sg.id,
    aws_default_security_group.default_sg.id
  ]
  tags = {
    Name = "${var.vpc.prefix}-server"
  }
}

output "server_ip" {
  value = aws_instance.web_server.public_ip
}