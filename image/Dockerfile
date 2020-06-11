FROM php:7.4-apache

# Install tools required for build stage
RUN apt-get update \
 && apt-get install -fyqq \
    bash curl wget rsync ca-certificates openssl openssh-client git libxml2-dev libcurl4-gnutls-dev\
    imagemagick gcc make autoconf libc-dev pkg-config libmagickwand-dev

# Install additional PHP libraries
RUN docker-php-ext-install \
    pcntl \
    bcmath \
    sockets \
    soap \
    opcache \
    intl

# Install mysql plugin
RUN apt-get update \
 && apt-get install -fyqq mariadb-client libmariadbclient-dev \
 && docker-php-ext-install pdo_mysql mysqli \
 && apt-get remove -fyqq libmariadbclient-dev

# Install pgsql plugin
RUN apt-get update \
 && apt-get install -fyqq postgresql-client libpq-dev \
 && docker-php-ext-install pdo_pgsql pgsql \
 && apt-get remove -fyqq libpq-dev

# Install internalization plugin
RUN apt-get update \
 && apt-get install -fyqq libicu63 libicu-dev \
 && docker-php-ext-install intl \
 && apt-get remove -fyqq libicu-dev

# Install libraries for compiling GD, then build it
RUN apt-get update \
 && apt-get install -fyqq libfreetype6-dev libjpeg-dev libpng-dev libwebp-dev libpng16-16 libjpeg62-turbo libjpeg62-turbo-dev \
 && docker-php-ext-install gd \
 && apt-get remove -fyqq libfreetype6-dev libpng-dev libjpeg62-turbo-dev

# Add ZIP archives support
RUN apt-get update \
 && apt-get install -fyqq zip libzip-dev \
 && docker-php-ext-install zip \
 && apt-get remove -fyqq libzip-dev

# Install memcache
RUN apt-get update \
 && apt-get install -fyqq libmemcached11 libmemcached-dev \
 && pecl install memcached \
 && docker-php-ext-enable memcached \
 && apt-get remove -fyqq libmemcached-dev

# Install redis ext
RUN pecl install redis \
 && docker-php-ext-enable redis

# Install xdebug pecl_http imagick
RUN pecl channel-update pecl.php.net && pecl install xdebug \
 && pecl install raphf propro \
 && docker-php-ext-enable raphf propro \
 && pecl install pecl_http

RUN apt install libmagickwand-dev -y && echo '' | pecl install imagick && echo extension=imagick.so > /usr/local/etc/php/conf.d/imagick.ini

# Add apache to run and configure
RUN a2enmod rewrite && a2enmod session && a2enmod session_cookie && a2enmod session_crypto && a2enmod deflate
ADD apache.conf /etc/apache2/sites-available/000-default.conf
COPY php-add.ini /usr/local/etc/php/conf.d/

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
 && chmod 755 /usr/bin/composer

WORKDIR /

# Install laravel
RUN composer create-project --prefer-dist laravel/laravel app
WORKDIR /app
RUN composer require laravel/ui --dev

# Install sms + localization + flysystem
RUN composer require caouecs/laravel-lang:~6.0 \
                     laravel-notification-channels/turbosms \
                     laravel/nexmo-notification-channel \
                     graham-campbell/flysystem \
                     league/flysystem-aws-s3-v3 \
                     league/flysystem-sftp \
                     league/flysystem-webdav \
    && cp -R vendor/caouecs/laravel-lang/src/ru resources/lang/ \
    && cp -R vendor/caouecs/laravel-lang/src/uk resources/lang/ \
    && cp -R vendor/caouecs/laravel-lang/json/ru.json resources/lang/ \
    && cp -R vendor/caouecs/laravel-lang/json/uk.json resources/lang/ \
    && php artisan vendor:publish --provider="Nexmo\Laravel\NexmoServiceProvider" \
    && php artisan vendor:publish --provider="GrahamCampbell\Flysystem\FlysystemServiceProvider" \
    && php artisan vendor:publish --tag=laravel-mail \
    && php artisan vendor:publish --tag=laravel-notifications \
    && php artisan notifications:table

# Custom Composer Json to install Fileupload
#RUN composer require pion/laravel-chunk-upload \
#    && php artisan vendor:publish --provider="Pion\Laravel\ChunkUpload\Providers\ChunkUploadServiceProvider"
COPY composer.json /app
RUN composer update && php artisan vendor:publish --provider="Pion\Laravel\ChunkUpload\Providers\ChunkUploadServiceProvider"

# Generate basic scaffolding... with auth / registration 
RUN php artisan ui -n vue && php artisan ui -n react && php artisan ui -n bootstrap  \
    && php artisan ui -n --auth bootstrap

# Install NodeJs
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \ 
    && apt-get update && apt install nodejs -y

RUN npm install jquery popper.js bootstrap dropzone --save-dev

# Install node_modules
RUN npm install && npm run development

#Install Queue worker
RUN apt install supervisor -y
ADD laravel-worker.conf /etc/supervisor/conf.d
ADD start.sh /

#  Install mail ssmtp
RUN echo 'deb http://deb.debian.org/debian stretch main' >> /etc/apt/sources.list \
    && apt update && apt install ssmtp -y && chfn -f "Laravel" root && chfn -f "Laravel" www-data && chmod -R a+r /etc/ssmtp \
    && sed -i -- 's!/usr/sbin/sendmail -bs!/usr/sbin/sendmail -i -t!' config/mail.php

# change rights
RUN chown www-data:www-data -R bootstrap storage

VOLUME /app
EXPOSE 80
