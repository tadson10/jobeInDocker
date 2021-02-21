#!/bin/bash

sudo usermod -d /var/lib/mysql/ mysql
sudo /etc/init.d/mysql start

/usr/sbin/apache2ctl -D FOREGROUND