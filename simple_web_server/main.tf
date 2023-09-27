provider "aws" {}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

module "subnet" {
  source = "./modules/subnet"
  cidr-block = var.cidr-block
  prefix = var.prefix
  avail-zone = var.avail-zone
  vpc = aws_vpc.vpc
}

module "web-server" {
  source = "./modules/web-server/"
  ami-name = var.ami-name
  instance-type = var.instance-type
  key-file = var.key-file
  prefix = var.prefix
  ssh-allow-cidr = var.ssh-allow-cidr
  subnet = module.subnet.sub
  vpc = aws_vpc.vpc
  web-allow-cidr = var.web-allow-cidr
}