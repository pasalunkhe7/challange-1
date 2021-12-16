#!/bin/bash

yum update -y
yum install -y

echo "Hello sever 1" > /var/www/html/index.html