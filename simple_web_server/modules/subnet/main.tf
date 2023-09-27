resource "aws_subnet" "public-sub" {
  vpc_id = var.vpc.id
  cidr_block = var.cidr-block
  availability_zone = var.avail-zone
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.prefix}-public-sub"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = var.vpc.default_route_table_id
  tags = {
    Name = "${var.prefix}-default-route-table"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = var.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.prefix}-route-table"
  }
}

resource "aws_route_table_association" "public_association" {
  route_table_id = aws_route_table.route_table.id
  subnet_id = aws_subnet.public-sub.id
}