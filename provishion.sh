#!/bin/bash

# Database password (we could randomly generate this).
DB_PASS=Myzkfuv9E4ic

# Move resources.
cp /vagrant/resources/* /home/vagrant

# Install Apache.
yum install -y httpd
service httpd start

# Install MariaDB.
yum install -y mariadb-server
service mariadb start

# Install PHP.
yum install -y php
yum install -y php-mysqli
service httpd restart

# Install Git.
yum install -y git

# Clone website into web root.
rm -rf /var/www/*
git clone https://github.com/lambdacasserole/hack-this.git /var/www

# Set up database.
mysql -uroot < /var/www/sql/db.sql

# Secure MariaDB installation.
yum install -y expect
expect db_secure.exp $DB_PASS

# Set database password for website.
sed -i -e "s/define('DB_PASS', '');/define('DB_PASS', '$DB_PASS');/g" /var/www/web/db_configuration.php

# Go to web root.
cd /var/www

# Create symlink into project web root.
ln -s web html

# Install NPM.
yum install -y epel-release
curl --silent --location https://rpm.nodesource.com/setup_6.x | sudo bash -
yum install -y nodejs

# Run project build.
npm install
./node_modules/.bin/bower install install --allow-root
./node_modules/.bin/gulp

# Make web root owned by the Apache user.
chown apache:apache /var/www/* -R
