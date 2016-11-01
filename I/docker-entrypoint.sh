#!/bin/bash
set -e

if [[ "$1" == nginx ]] || [ "$1" == php-fpm ]; 
then
  echo "<?php phpinfo(); ?>" > /var/www/html/info.php
  chown -R 0:0 /var/www/html
  echo "Selecting configuration based on environment ..."
    if [ "${CAENV}" = "production" ]
    then 
      mv .env.production .env
      echo "Production configs are set."
    elif [ "${CAENV}" = "staging" ]
    then 
      mv .env.staging .env
      echo "Staging configs are set."
    else
      echo "Environment veriable is not set! Task aborted."
    fi
  echo "Setting up Newrelic configs ..."
    if [ "${NEWRELIC_LICENSE}" != "**None**" ]
    then
      sed -i "s/newrelic.enabled = false/newrelic.enabled = true/g" /usr/local/etc/php/conf.d/newrelic.ini
      sed -i "s/NRKEY/"${NEWRELIC_LICENSE}"/g" /usr/local/etc/php/conf.d/newrelic.ini
      sed -i 's/NRNAME/"${NEWRELIC_APPNAME}"/g' /usr/local/etc/php/conf.d/newrelic.ini
      echo "Newrelic configs are set."
    else
      echo "No Newrelic license found! Task aborted."
    fi
  echo "Running PHP-FPM ..."
    php-fpm --allow-to-run-as-root --nodaemonize &
  echo "Running Nginx ..."
    nginx -g 'daemon off;'
fi

exec "$@"