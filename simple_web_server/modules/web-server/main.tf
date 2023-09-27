
resource "aws_default_security_group" "default_sg" {
  vpc_id = var.vpc.id
  tags = {
    Name = "${var.prefix}-default-sg"
  }
  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    cidr_blocks = var.ssh-allow-cidr
  }
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_sg" {
  vpc_id = var.vpc.id
  name = "web-sg"
  tags = {
    Name = "${var.prefix}-web-sg"
  }
  ingress {
    from_port = 8080
    protocol  = "tcp"
    to_port   = 8080
    cidr_blocks = var.web-allow-cidr
  }
}

data "aws_ami" "latest_amazon_ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name   = "name"
    values = [var.ami-name]
  }
}

resource "aws_key_pair" "key_pair" {
  key_name = "${var.prefix}-key-pair"
  public_key = file(var.key-file)
}

resource "aws_instance" "web_server" {
  ami = data.aws_ami.latest_amazon_ami.id
  instance_type = var.instance-type
  subnet_id = var.subnet.id
  key_name = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [
    aws_security_group.web_sg.id,
    aws_default_security_group.default_sg.id
  ]
  user_data = file("entrypoint.sh")
  tags = {
    Name = "${var.prefix}-server"
  }
}