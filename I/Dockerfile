FROM ipropertygroup/webserver:nginx-php-5
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

# install NewRelic
ENV NR_INSTALL_SILENT true
ENV NEWRELIC_LICENSE **None**
RUN curl -sL https://download.newrelic.com/548C16BF.gpg | apt-key add - \
 && sh -c 'echo "deb http://apt.newrelic.com/debian/ newrelic non-free" > /etc/apt/sources.list.d/newrelic.list' \
 && apt-get update \
 && apt-get install -y newrelic-php5 \ 
 && apt-get clean \
 && newrelic-install install

COPY newrelic.ini /usr/local/etc/php/conf.d/newrelic.ini
COPY docker-entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]