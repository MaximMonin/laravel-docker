FROM php:7.4-apache

# Install tools required for build stage
RUN apt-get update \
 && apt-get install -fyqq \
    bash curl wget rsync ca-certificates openssl openssh-client git tzdata \
    libxrender1 fontconfig libc6 \
    gnupg binutils-gold autoconf \
    g++ gcc gnupg libgcc1 linux-headers-amd64 make python

# Install additional PHP libraries
RUN docker-php-ext-install \
    pcntl \
    bcmath \
    sockets

# Install mbstring plugin
RUN apt-get update \
 && apt-get install -fyqq libonig5 libonig-dev \
 && docker-php-ext-install mbstring \
 && apt-get remove -fyqq libonig-dev

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
 && apt-get install -fyqq libfreetype6 libfreetype6-dev libpng16-16 libpng-dev libjpeg62-turbo libjpeg62-turbo-dev \
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

# Install xdebug
RUN pecl install xdebug

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
 && chmod 755 /usr/bin/composer

# Add apache to run and configure
RUN a2enmod rewrite && a2enmod session && a2enmod session_cookie && a2enmod session_crypto && a2enmod deflate
ADD apache.conf /etc/apache2/sites-available/000-default.conf

WORKDIR /

# Install laravel
RUN composer create-project --prefer-dist laravel/laravel app

# Install NodeJs
#RUN git clone https://github.com/nodejs/node.git
#WORKDIR /node
#RUN apt-get update && apt install python3-distutils -y && ./configure && make -j4 install 
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \ 
    && apt-get update && apt install nodejs -y

WORKDIR /app
# change rights
RUN chown www-data:www-data -R bootstrap && chown www-data:www-data -R storage

# Install node_modules
RUN npm install && npm run development
RUN php artisan vendor:publish --tag=laravel-pagination

VOLUME /app
EXPOSE 80
