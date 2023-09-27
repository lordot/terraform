module "subnet" {
  source = "./modules/subnet"
  cidr-block = var.cidr-block
  prefix = var.prefix
  avail-zone = var.avail-zone
  vpc = aws_vpc.vpc
}

provider "aws" {}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc.cidr
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.prefix}-default-sg"
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
    Name = "${var.prefix}-web-sg"
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
  key_name = "${var.prefix}-key-pair"
  public_key = file(var.key_pair)
}

resource "aws_instance" "web_server" {
  ami = data.aws_ami.latest_amazon_ami.id
  instance_type = var.instance_type
  subnet_id = module.subnet.sub.id
  key_name = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [
    aws_security_group.web_sg.id,
    aws_default_security_group.default_sg.id
  ]
  tags = {
    Name = "${var.prefix}-server"
  }
}

output "server_ip" {
  value = aws_instance.web_server.public_ip
}