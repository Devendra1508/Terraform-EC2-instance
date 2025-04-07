#!/bin/bash

yum update -y

yum install httpd -y

systemctl start httpd
systemctl enable httpd

echo "Welcome To Web-Server-2" > /var/www/html/index.html