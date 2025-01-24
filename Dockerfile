FROM ubuntu:14.04

MAINTAINER Dan Pupius <dan@pupi.us>

RUN apt-get update
RUN apt-get -y upgrade

# Install Apache PHP and Mods
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
   apache2 \
   libapache2-mod-php5 \
   php5-mysql \
   php5-gd \
   php-pear \
   php-apc \
   php5-curl \
   #php5-mongo \
   php5-mcrypt \
   php5-redis \
   php5-intl \
   php5-dev \
   curl \
   libpcre3-dev \
   libcurl4-openssl-dev \
   pkg-config \
   libssl-dev \
   libsslcommon2-dev

# Install mongo
RUN pecl install mongo

# Enable PHP Mods
RUN php5enmod mcrypt

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Enable apache mods.
RUN a2enmod php5
RUN a2enmod rewrite

# PHP INI
RUN sed -i -e 's/upload_max_filesize = 2M/upload_max_filesize = 100M/g' /etc/php5/apache2/php.ini
RUN sed -i -e 's/;max_input_nesting_level = 64/max_input_nesting_level = 10000/g' /etc/php5/apache2/php.ini
RUN sed -i -e 's/; max_input_vars = 1000/max_input_vars = 10000/g' /etc/php5/apache2/php.ini
RUN sed -i -e "\$aextension=mongo.so" /etc/php5/apache2/php.ini
RUN sed -ri -e "s/;upload_tmp_dir =/upload_tmp_dir = \/var\/www\/c2\/tmp/g" /etc/php5/apache2/php.ini

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

EXPOSE 80

# Update the default Apache site
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf



# By default, simply start apache.
CMD /usr/sbin/apache2ctl -D FOREGROUND
