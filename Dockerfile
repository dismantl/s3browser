# DockerHub base image
#
FROM php:5.6.30-apache

RUN \
  apt-get update && \
  apt-get install -y ca-certificates git && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Enable required Apache modules
RUN a2enmod \
  rewrite \
  proxy proxy_http headers

# Basic Apache config to serve the S3Browser
COPY etc/apache2/sites-available/000-default.conf \
  /etc/apache2/sites-available/000-default.conf

# Put App files
COPY composer.json /srv/www/s3browser/www/composer.json
COPY composer.lock /srv/www/s3browser/www/composer.lock
WORKDIR /srv/www/s3browser/www
RUN composer update && composer install
COPY www /srv/www/s3browser/www

RUN echo "if [ 'true' = \"\${S3BROWSER_PROXY_DOWNLOAD}\" ]; then export APACHE_ARGUMENTS='-DS3Proxy'; fi;" >> /etc/apache2/envvars
RUN sed -i 's/\(-DFOREGROUND\)/\1 ${APACHE_ARGUMENTS}/'  /usr/local/bin/apache2-foreground
