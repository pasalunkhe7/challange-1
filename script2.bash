#!/bin/bash

yum update -y
yum install -y

echo "Hello sever 2" > /var/www/html/index.html