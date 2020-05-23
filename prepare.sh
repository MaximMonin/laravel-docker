#!/bin/bash

docker rm -f laravel
docker run -d -v /tmp:/tmp --name laravel laravel
sleep 5
docker exec -i laravel cp -R /app /tmp
docker rm -f laravel
mv /tmp/app .
cp env-example ./app/.env
sleep 5
docker run -d -v $(pwd)/app:/app --name laravel laravel
sleep 5
docker exec -i laravel chown -R www-data:www-data /app/bootstrap /app/storage
docker rm -f laravel
