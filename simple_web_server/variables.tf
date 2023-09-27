variable "cidr-block" {}
variable "prefix" {}
variable "vpc_cidr" {}
variable "ssh-allow-cidr" {type = list(string)}
variable "web-allow-cidr" {type = list(string)}
variable "key-file" {}
variable "instance-type" {}
variable "avail-zone" {}
variable "ami-name" {}
