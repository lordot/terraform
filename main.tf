variable "vpc" {
  description = "vpc"
  type = object({
    name = string
    cidr = string
  })
}

variable "private_subnets" {
  description = "private subnets"
  type = list(object({
    name = string
    cidr = string
    availability_zone = string
  }))
}

variable "public_subnets" {
  description = "private subnets"
  type = list(object({
    name = string
    cidr = string
    availability_zone = string
  }))
}

provider "aws" {}

resource "aws_vpc" "dev-vpc" {
  cidr_block = var.vpc.cidr
  tags = {
    Name = var.vpc.name
  }
}

resource "aws_subnet" "dev-private-sub-1" {
  vpc_id = aws_vpc.dev-vpc.id
  cidr_block = var.private_subnets[0].cidr
  availability_zone = var.private_subnets[0].availability_zone
  map_public_ip_on_launch = false
  tags = {
    Name = var.private_subnets[0].name
  }
}

resource "aws_subnet" "dev-private-sub-2" {
  vpc_id = aws_vpc.dev-vpc.id
  cidr_block = var.private_subnets[1].cidr
  availability_zone = var.private_subnets[1].availability_zone
  map_public_ip_on_launch = false
  tags = {
    Name = var.private_subnets[1].name
  }
}

resource "aws_subnet" "dev-public-sub-3" {
  vpc_id = aws_vpc.dev-vpc.id
  cidr_block = var.public_subnets[0].cidr
  availability_zone = var.public_subnets[0].availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = var.public_subnets[0].name
  }
}

output "dev-private-sub-1" {
  value = aws_subnet.dev-private-sub-1.id
}

output "dev-private-sub-2" {
  value = aws_subnet.dev-private-sub-2.id
}

output "dev-public-sub-3" {
  value = aws_subnet.dev-public-sub-3.id
}