# laravel-docker for development and testing
This package includes: php-fpm 7.4 based enviroment, latest Laravel framework (7.x) with laravel libraries, NodeJs.v14, Vue.js, Nginx LoadBalancer, Laravel Echo, Laravel Dusk, Selenium, Php Admin, Redis, Mysql, gitlab-runner

## Installation
1. Build laravel Image. Use build.sh. You can use docker pull maximmonin/laravel instead.   
2. Run prepare.sh to extract laravel app directory from laravel docker image to ./app   
3. Copy env-docker file to .env and change values to your site   
4. Start containters start.sh   
5. Run create_mysqldb.sh to create default mysql db.   

Docker compose works with combination of nginx-proxy https://github.com/MaximMonin/nginx-ssh-proxy-docker, or as local installation   
To create nginx-proxy network run sudo docker network create nginx-proxy   

## Setup
Docker Image laravel includes supepvisor to run laravel workers, and cron to run laravel scheduler, smtp mail driver   
1. /mail catalog consists ssmtp mail configuration files   
2. /nginx catalog consists nginx loadbalance configuration.   
By default it redirect all http traffic to laravel cluster php-fpm containers, redirects socket.io traffic to Laravel Echo. 
Uses nginx static web server for your.site/cdn catalog and for *.js and *.css files to reduce load to laravel cluster.   
3. /worker/laravel-worker.conf consists supervisor default configuration (count and names of laravel workers)   
4. /worker/www.conf consists dafault php-fpm configuration (on demand, max 100 threads, auto shutdown 10 sec)   
5. Docker-compose file consists all services in one file.    
By default laravel container is default site, laravel-worker container run laravels workers and laravel scheduler.   
6. Setup laravel app/.env file.   

By default port 2380 used for local site testing and 2381 for mysql administration. (root/root)   

## More
Copy your project to ./app directory and run npm_run_dev.sh or npm_run_prod.sh to compile java script in development or production mode   
https://github.com/MaximMonin/laravel as test example.   
Use run_tests.sh to run phpunit tests, and run_tests_dusk.sh to run browser tests through Laravel Dusk and Selenium   

## Staging
This image also used to create stage enviroment, with auto build, auto test capabilities. Gitlab-runner used for integration with Gitlab CI/CD process.
See https://github.com/MaximMonin/laravel-stage project for more info.   
