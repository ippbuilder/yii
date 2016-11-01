FROM ipropertygroup/webserver:nginx-php-7
MAINTAINER MOHSEN@IPROPERTY

ENV DEBIAN_FRONTEND noninteractive

# Performance optimization - see https://gist.github.com/jpetazzo/6127116
# this forces dpkg not to call sync() after package extraction and speeds up install
RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup
# we don't need and apt cache in a container
RUN echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache

# install the PHP extensions we need
RUN apt-get update && apt-get install -y sendmail libmcrypt-dev libmemcached-dev libpng12-dev libjpeg-dev git \
    && rm -rf /var/lib/apt/lists/* \
    && pecl install memcached \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd mcrypt mysql pdo_mysql \
    && docker-php-ext-enable memcached

# Install Memcached
RUN curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz" && \
mkdir -p memcached && \
tar -C memcached -zxvf /tmp/memcached.tar.gz --strip 1 && \
( \
    cd memcached && \
    phpize && \
    ./configure && \
    make -j$(nproc) && \
    make install \
) && \
rm -r memcached && \
rm /tmp/memcached.tar.gz && \
docker-php-ext-enable memcached

# install NewRelic
ENV NR_INSTALL_SILENT true
ENV NEWRELIC_LICENSE **None**
RUN curl -sL https://download.newrelic.com/548C16BF.gpg | apt-key add - \
 && sh -c 'echo "deb http://apt.newrelic.com/debian/ newrelic non-free" > /etc/apt/sources.list.d/newrelic.list' \
 && apt-get update \
 && apt-get install -y newrelic-php5 \ 
 && apt-get clean \
 && newrelic-install install

# install Composer
COPY composer.json /var/www/html/
COPY composer.lock /var/www/html/
WORKDIR /var/www/html
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer && \
    composer self-update --no-progress && \
    composer install --no-progress

COPY newrelic.ini /usr/local/etc/php/conf.d/newrelic.ini
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]