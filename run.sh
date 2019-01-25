#!/bin/bash

ln -sf /usr/share/zoneinfo/Asia/Chongqing /etc/localtime

set|grep '_.*=' >/vue-msf/.ssh/environment

mkdir -p /vue-msf/data/www

MODULES="php supervisor redis-6379 redis-6380 redis-6381 redis-7379 redis-7380 redis-7381 memcached mongodb rabbitmq"
for i in $MODULES
do
mkdir -p /vue-msf/data/$i/log
mkdir -p /vue-msf/data/$i/run
done
mkdir -p /vue-msf/data/nginx/logs

# chown
chown super.super /vue-msf
chown super.super /vue-msf/data
chown super.super /vue-msf/data/www
chown super.super -R /home/super
dotfile=`cd /vue-msf && find . -maxdepth 1 -name '*' |sed -e 's#^.$##' -e 's#^.\/##' -e 's#^data$##'`
datadir=`cd /vue-msf/data && find . -maxdepth 1 -name '*' |sed -e 's#^.$##' -e 's#^.\/##' -e 's#^www$##'`
cd /vue-msf && chown -R  super.super $dotfile
cd /vue-msf/data && chown -R  super.super $datadir

chown root.super /vue-msf/nginx/sbin/nginx
chmod u+s /vue-msf/nginx/sbin/nginx

chmod 700 /vue-msf/.ssh
chmod 600 /vue-msf/.ssh/authorized_keys

# index.html index.php

if [ ! -f /vue-msf/data/www/index.html ]; then
	echo 'vue-msf' > /vue-msf/data/www/index.html
	chown super.super /vue-msf/data/www/index.html
fi
if [ ! -f /vue-msf/data/www/index.php ]; then
	echo '<?php phpinfo();' > /vue-msf/data/www/index.php
	chown super.super /vue-msf/data/www/index.php
fi

#nohup /usr/sbin/init >/dev/null 2>&1 &
#/usr/sbin/init & 

if [ -f /vue-msf/bin/init.sh ]; then
    echo '/vue-msf/bin/init.sh'
    chmod a+x /vue-msf/bin/init.sh
    su super -c '/vue-msf/bin/init.sh'
fi

echo 'supervisord -c /vue-msf/supervisor/supervisord.conf'
nohup supervisord -c /vue-msf/supervisor/supervisord.conf >/dev/null 2>&1 & 

echo '系统部分完成!'
if [ -f /vue-msf/data/publish.sh ]; then
    sh /vue-msf/data/publish.sh
fi

echo '/etc/init.d/sshd start'
#/etc/init.d/sshd start
/usr/sbin/sshd -D
