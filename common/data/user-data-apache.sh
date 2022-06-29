#!/bin/bash
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd
sudo echo "The page was created by the user-data in $HOSTNAME" > /var/www/html/index.html