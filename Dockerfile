FROM maximmonin/laravel-base:latest

COPY image/php-add.ini /usr/local/etc/php/conf.d/

# Install laravel
WORKDIR /
RUN composer create-project --prefer-dist laravel/laravel=~7.28 app
WORKDIR /app
RUN composer require laravel/ui=~2.4

# Install sms + localization + flysystem + chunk upload + image processing + video processing
RUN composer require caouecs/laravel-lang:~6.0 \
                     laravel-notification-channels/turbosms \
                     laravel/nexmo-notification-channel \
                     league/flysystem-aws-s3-v3 \
                     league/flysystem-sftp \
                     league/flysystem-webdav \
                     pion/laravel-chunk-upload \
                     intervention/image \
                     php-ffmpeg/php-ffmpeg \
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
  && apt install -y gitlab-runner \
# Add sudo right to gitlab-runner
  && apt install -y sudo \
  && echo 'gitlab-runner ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo '' >> /etc/sudoers

# Install NodeJs
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \ 
    && apt-get update && apt install nodejs -y

RUN npm install jquery popper.js bootstrap dropzone socket.io-client laravel-echo --save-dev \
 && npm install vue vue-router bootstrap-vue vuex vue-template-compiler --save-dev \
# Install node_modules
 && npm install && npm run development

# Install Queue worker
ADD image/laravel-worker.conf /etc/supervisor/conf.d
ADD image/start.sh /

# Install mail ssmtp
RUN sed -i -- 's!/usr/sbin/sendmail -bs!/usr/sbin/sendmail -i -t!' config/mail.php \
# Install cron laravel scheduler
  && echo "# Laravel scheduler" >> /etc/crontab \
  && echo "* * * * * root cd /app && php artisan schedule:run >> /dev/null 2>&1" >> /etc/crontab \
# change rights
  && chown www-data:www-data -R bootstrap storage && chmod -R a+rw bootstrap storage tests && chmod a+rw /app

VOLUME /app
