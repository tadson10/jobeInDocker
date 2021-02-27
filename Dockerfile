# Jobe-in-Docker: a Dockerised Jobe server (see https://github.com/tadson10/jobe)
# Original repository is found on https://github.com/trampgeek/jobe
# With thanks to David Bowes (d.h.bowes@herts.ac.uk) who did all the hard work
# on this originally.

FROM ubuntu:20.04

LABEL maintainers="ts6103@student.uni-lj.si"
ARG TZ=Europe/Ljubljana
ARG ROOTPASS=jobeServerUniLj
# Set up the (apache) environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV LANG C.UTF-8

#Copy start.sh
COPY start.sh /start.sh

#Copy mysql.php
COPY mysql.php /mysql.php

# Set timezone
# Install extra packages
# Redirect apache logs to stdout
# Configure apache
# Configure php
# Setup root password
# Get and install jobe
# Clean up
RUN ln -snf /usr/share/zoneinfo/"$TZ" /etc/localtime && \
  echo "$TZ" > /etc/timezone && \
  apt-get update && \
  apt-get --no-install-recommends install -yq acl \
  apache2 \
  build-essential \
  fp-compiler \
  git \
  libapache2-mod-php \
  nodejs \
  octave \
  openjdk-11-jdk \
  php \
  php-cli \
  php-cli \
  php-mbstring \
  python3 \
  python3-pip \
  python3-setuptools \
  sqlite3 \
  sudo \
  tzdata \
  mysql-server \
  php-mysql \
  curl \
  php-xml \
  systemd \
  npm \
  unzip && \
  npm install -g express-generator && \
  npm install express && \
  systemctl enable mysql && \
  python3 -m pip install pylint && \
  pylint --reports=no --score=n --generate-rcfile > /etc/pylintrc && \
  /usr/bin/curl -sS https://getcomposer.org/installer | php && \
  mv composer.phar /usr/local/bin/composer && \
  ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
  ln -sf /proc/self/fd/1 /var/log/apache2/error.log && \
  sed -i -e "s/export LANG=C/export LANG=$LANG/" /etc/apache2/envvars && \
  sed -i -e "1 i ServerName localhost" /etc/apache2/apache2.conf && \
  sed -i 's/ServerTokens\ OS/ServerTokens \Prod/g' /etc/apache2/conf-enabled/security.conf && \
  sed -i 's/ServerSignature\ On/ServerSignature \Off/g' /etc/apache2/conf-enabled/security.conf && \
  sed -i 's/expose_php\ =\ On/expose_php\ =\ Off/g' /etc/php/7.4/cli/php.ini && \
  mkdir -p /var/crash && \
  echo "root:$ROOTPASS" | chpasswd && \
  echo "Jobe" > /var/www/html/index.html && \
  git clone https://github.com/tadson10/jobe /var/www/html/jobe && \
  sudo service apache2 start && \
  cd /var/www/html/jobe && sudo ./install && composer require zircote/swagger-php && \
  chown -R www-data:www-data /var/www/html && \
  apt-get -y autoremove --purge && \
  apt-get -y clean && \
  rm -rf /var/lib/apt/lists/*


# Expose apache
EXPOSE 80
# Expose JOBE ports
EXPOSE 3000-3100

# Start apache and mysql server
CMD ["sh", "/start.sh"]

