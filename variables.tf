variable "cidr-block" {}
variable "prefix" {}
variable "vpc" {
  description = "vpc"
  type = object({
    cidr = string
    region = string
  })
}
variable "ssh_allow_cidr" {type = list(string)}
variable "web_allow_cidr" {type = list(string)}
variable "key_pair" {}
variable "instance_type" {}
variable "avail-zone" {}