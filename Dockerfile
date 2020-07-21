FROM php:7.4-fpm

# Install tools required for build stage
RUN apt-get update \
 && apt-get install -fyqq --no-install-recommends \
    bash curl wget rsync ca-certificates openssl openssh-client git libxml2-dev libcurl4-gnutls-dev\
    imagemagick gcc make autoconf libc-dev pkg-config libmagickwand-dev \
# Install additional PHP libraries
&&  docker-php-ext-install \
    pcntl \
    bcmath \
    sockets \
    soap \
    opcache \
    intl \
# Install mysql plugin
&&  apt-get update \
 && apt-get install -fyqq mariadb-client libmariadbclient-dev \
 && docker-php-ext-install pdo_mysql mysqli \
 && apt-get remove -fyqq libmariadbclient-dev \
# Install pgsql plugin
&& apt-get update \
 && apt-get install -fyqq postgresql-client libpq-dev \
 && docker-php-ext-install pdo_pgsql pgsql \
 && apt-get remove -fyqq libpq-dev \
# Install libraries for compiling GD, then build it
&& apt-get update \
 && apt-get install -fyqq libfreetype6-dev libjpeg-dev libpng-dev libwebp-dev libpng16-16 libjpeg62-turbo libjpeg62-turbo-dev \
 && docker-php-ext-install gd \
 && apt-get remove -fyqq libfreetype6-dev libpng-dev libjpeg62-turbo-dev \
# Add ZIP archives support
&& apt-get update \
 && apt-get install -fyqq zip libzip-dev \
 && docker-php-ext-install zip \
 && apt-get remove -fyqq libzip-dev \
# Install memcache
&& apt-get update \
 && apt-get install -fyqq libmemcached11 libmemcached-dev \
 && pecl install memcached \
 && docker-php-ext-enable memcached \
 && apt-get remove -fyqq libmemcached-dev \
# Install redis ext
&& pecl install redis \
 && docker-php-ext-enable redis \
# Install xdebug pecl_http imagick
&& pecl channel-update pecl.php.net && pecl install xdebug \
 && pecl install raphf propro \
 && docker-php-ext-enable raphf propro \
 && pecl install pecl_http \
 && echo extension=http.so > /usr/local/etc/php/conf.d/docker-php-ext-http.ini \
 && apt install libmagickwand-dev -y && echo '' | pecl install imagick && echo extension=imagick.so > /usr/local/etc/php/conf.d/imagick.ini \
# Install composer
&& curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
 && chmod 755 /usr/bin/composer \
# Autoclean
 && apt-get autoclean -y && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/pear/ \
 && apt-get remove libgmp-dev libgnutls28-dev libhashkit-dev libidn2-dev libmariadb-dev libp11-kit-dev libsasl2-dev libtasn1-6-dev nettle-dev -y \
 && apt-get update && apt upgrade -y && apt-get install procps -y

COPY image/php-add.ini /usr/local/etc/php/conf.d/

# Install laravel
WORKDIR /
RUN composer create-project --prefer-dist laravel/laravel app
WORKDIR /app
RUN composer require laravel/ui --dev

# Install sms + localization + flysystem + chunk upload + image processing
RUN composer require caouecs/laravel-lang:~6.0 \
                     laravel-notification-channels/turbosms \
                     laravel/nexmo-notification-channel \
                     graham-campbell/flysystem \
                     league/flysystem-aws-s3-v3 \
                     league/flysystem-sftp \
                     league/flysystem-webdav \
                     pion/laravel-chunk-upload \
                     intervention/image \
    && cp -R vendor/caouecs/laravel-lang/src/ru resources/lang/ \
    && cp -R vendor/caouecs/laravel-lang/src/uk resources/lang/ \
    && cp -R vendor/caouecs/laravel-lang/json/ru.json resources/lang/ \
    && cp -R vendor/caouecs/laravel-lang/json/uk.json resources/lang/ \
    && php artisan vendor:publish --provider="Nexmo\Laravel\NexmoServiceProvider" \
    && php artisan vendor:publish --provider="GrahamCampbell\Flysystem\FlysystemServiceProvider" \
    && php artisan vendor:publish --provider="Pion\Laravel\ChunkUpload\Providers\ChunkUploadServiceProvider" \
    && php artisan vendor:publish --provider="Intervention\Image\ImageServiceProviderLaravelRecent" \
    && php artisan vendor:publish --tag=laravel-mail \
    && php artisan vendor:publish --tag=laravel-notifications \
    && php artisan notifications:table \
    && php artisan storage:link \
    && php artisan ui -n vue && php artisan ui -n react && php artisan ui -n bootstrap  \
    && php artisan ui -n --auth bootstrap \
# Install Laravel Dusk
    && apt-get -y install libnss3 && composer require laravel/dusk --dev && php artisan dusk:install

# Install google chrome for Laravel Dusk
ARG CHROME_VERSION="google-chrome-stable"
RUN apt-get install -y gnupg2 && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install \
    ${CHROME_VERSION:-google-chrome-stable} \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

COPY image/DuskTestCase.php /app/tests/
COPY image/.env /app/

# Install gitlab runner
RUN curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash - \
  && apt install -y gitlab-runner

# Install NodeJs
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \ 
    && apt-get update && apt install nodejs -y

RUN npm install jquery popper.js bootstrap dropzone socket.io-client laravel-echo --save-dev 
RUN npm install vue vue-router bootstrap-vue vuex vue-template-compiler --save-dev

# Install node_modules
RUN npm install && npm run development

# Install Queue worker
RUN apt install supervisor -y
ADD image/laravel-worker.conf /etc/supervisor/conf.d
ADD image/start.sh /

# Install mail ssmtp
RUN echo 'deb http://deb.debian.org/debian stretch main' >> /etc/apt/sources.list \
    && apt update && apt install ssmtp -y && chfn -f "Laravel" root && chfn -f "Laravel" www-data && chmod -R a+r /etc/ssmtp \
    && sed -i -- 's!/usr/sbin/sendmail -bs!/usr/sbin/sendmail -i -t!' config/mail.php

# Install cron laravel scheduler
RUN apt-get update && apt-get install -y cron && echo "# Laravel scheduler" >> /etc/crontab \
  && echo "* * * * * root cd /app && php artisan schedule:run >> /dev/null 2>&1" >> /etc/crontab

# change rights
RUN chown www-data:www-data -R bootstrap storage && chmod -R a+rw bootstrap storage tests && chmod a+rw /app

VOLUME /app
