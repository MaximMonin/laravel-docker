#!/bin/bash

DBNAME=laravel
CONTAINER=laravel_mysql
echo "restoring.. " $DBNAME $CONTAINER
cat backup.sql | docker exec -i $CONTAINER /usr/bin/mysql -u root --password=root $DBNAME
