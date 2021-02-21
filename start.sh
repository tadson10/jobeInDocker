#!/bin/bash
sudo usermod -d /var/lib/mysql/ mysql
sudo /etc/init.d/mysql start
sudo php /mysql.php $1
/usr/sbin/apache2ctl -D FOREGROUND