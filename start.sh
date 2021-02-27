#!/bin/bash
usermod -d /var/lib/mysql/ mysql
/etc/init.d/mysql start
php /mysql.php
/usr/sbin/apache2ctl -D FOREGROUND