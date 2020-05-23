#!/bin/bash

docker rm -f laravel
docker run -d -v $(pwd)/tmp:/tmp --name laravel laravel
docker exec -i laravel cp -R /app /tmp
docker rm -f laravel
mv $(pwd)/tmp/app .
chmod -R a+rw app
rm -r tmp
cp env-example ./app/.env
docker run -d -v $(pwd)/app:/app --name laravel laravel
docker exec -i laravel chown -R www-data:www-data /app/bootstrap /app/storage
docker rm -f laravel
