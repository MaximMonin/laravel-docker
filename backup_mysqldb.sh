#!/bin/bash

DBNAME=laravel
CONTAINER=laravel-mysql
echo "backup.. " $DBNAME $CONTAINER
docker exec $CONTAINER /usr/bin/mysqldump -u root --password=root $DBNAME > backup.sql
