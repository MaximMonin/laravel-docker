#!/bin/bash

DBNAME=laravel
CONTAINER=laravel-mysql
echo "creating.. " $DBNAME $CONTAINER
echo "create database $DBNAME; create user 'laravel'@'localhost' identified by 'laravel';grant all privileges on *.* to 'laravel'@'localhost';"| sudo docker exec -i $CONTAINER /usr/bin/mysql -u root --password=root
echo "create user laravel identified by 'laravel';grant all privileges on *.* to 'laravel'@'%';"| sudo docker exec -i $CONTAINER /usr/bin/mysql -u root --password=root
cat backup.sql | docker exec -i $CONTAINER /usr/bin/mysql -u root --password=root $DBNAME
