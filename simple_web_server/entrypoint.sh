#! /bin/bash

sudo yum update
sudo yum install docker -y
sudo usermod -aG docker ec2-user
sudo systemctl start docker
docker run -p 8080:80 nginx

