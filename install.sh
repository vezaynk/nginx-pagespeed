#!/bin/sh

if [ $# -eq 0 ]
  then
    echo "Usage: bash install.sh nginx-full";
    exit 1;
fi

[ `whoami` = root ] || exec su -c "$0 $@" root
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8028BE1819F3E4A0
echo "deb https://nginx-pagespeed.knyz.org/dist/ /" > /etc/apt/sources.list.d/nginx-pagespeed.list
echo "Package: *" > /etc/apt/preferences.d/99nginx-pagespeed
echo "Pin: origin nginx-pagespeed.knyz.org" >> /etc/apt/preferences.d/99nginx-pagespeed
echo "Pin-Priority: 900" >> /etc/apt/preferences.d/99nginx-pagespeed
apt update
apt install $1
echo "pagespeed on;" > /etc/nginx/conf.d/pagespeed.conf
echo "pagespeed FileCachePath \"/var/cache/pagespeed/\";" >> /etc/nginx/conf.d/pagespeed.conf
echo "pagespeed FileCacheSizeKb 102400;" >> /etc/nginx/conf.d/pagespeed.conf
echo "pagespeed FileCacheCleanIntervalMs 3600000;" >> /etc/nginx/conf.d/pagespeed.conf
echo "pagespeed FileCacheInodeLimit 500000;" >> /etc/nginx/conf.d/pagespeed.conf
echo "pagespeed RewriteLevel CoreFilters;" >> /etc/nginx/conf.d/pagespeed.conf

systemctl enable nginx
systemctl start nginx
systemctl reload nginx
