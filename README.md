# laravel-docker for development and testing
This package includes: php-fpm 7.4 based enviroment, latest Laravel framework (7.x) with laravel libraries, NodeJs.v14, Nginx LoadBalancer, Laravel Echo, Php Admin, Redis, Mysql

## Installation
~~~
1. Build laravel Image. Use image/build.sh
2. Run prepare.sh to extract laravel app directory from laravel docker image to ./app
3. Start containters start.sh
4. Run create_mysqldb.sh to create default mysql db.

Docker compose works with combination of nginx-proxy https://github.com/MaximMonin/nginx-ssh-proxy-docker, or as local installation
To create nginx-proxy network run sudo docker network create nginx-proxy
~~~

## Setup
~~~
Docker Image laravel includes supeprvisor to run laravel workers, and cron to run laravel scheduler, smtp mail driver
1. /mail catalog consists ssmtp mail configuration files
2. /nginx catalog consists nginx loadbalance configuration.
By default it redirect all http traffic to laravel cluster php-fpm containers, redirects to Laravel Echo socker.io traffic
Uses nginx static web server for your.site/cdn catalog and for *.js and *.css files to reduce load to laravel cluster.
3. /worker/laravel-worker.conf consists supervisor default configuration (count and names of laravel workers)
4. /worker/www.conf consists dafault php-fpm configuration
5. Docker-compose file consists all services in one file. By default laravel container is default site, laravel-worker container run laravels workers and laravel scheduler.
6. Setup laravel app/.env file.

By default port 2380 used for local site testing and 2381 for php administration. (root/root)
~~~

## More
~~~
Copy your project to ./app directory and run npm_run_dev.sh or npm_run_prod.sh to run server in development or production mode
https://github.com/MaximMonin/laravel as test example.
~~~
