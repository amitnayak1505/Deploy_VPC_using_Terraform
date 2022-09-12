#!/bin/bash
  
echo "*** Installing apache2"
yum update -y
yum install httpd -y
echo "*** Completed Installing apache2"
systemctl start httpd
systemctl enable httpd
echo "<html><body><h1>Hi there</h1></body></html>" > /var/www/html/index.html

