#!/bin/bash

sudo apt-get autoremove --purge squid -y

# install squid
cd
echo "deb http://ftp.debian.org/debian/ jessie main contrib non-free
deb-src http://ftp.debian.org/debian/ jessie main contrib non-free
deb http://security.debian.org/ jessie/updates main contrib
deb-src http://security.debian.org/ jessie/updates main contrib
deb http://ftp.debian.org/debian/ jessie-updates main contrib non-free
deb-src http://ftp.debian.org/debian/ jessie-updates main contrib non-free" >> /etc/apt/sources.list
    
apt update
apt install -y gcc-4.9 g++-4.9
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 10
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 10
update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 30
update-alternatives --set cc /usr/bin/gcc
update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 30
update-alternatives --set c++ /usr/bin/g++

cd /usr/src
wget http://www.squid-cache.org/Versions/v3/3.1/squid-3.1.23.tar.gz
tar zxvf squid-3.1.23.tar.gz
cd squid-3.1.23
./configure --prefix=/usr \
--localstatedir=/var/squid \
--libexecdir=${prefix}/lib/squid \
--srcdir=. \
--datadir=${prefix}/share/squid \
--sysconfdir=/etc/squid \
--with-default-user=proxy \
--with-logdir=/var/log/squid \
--with-pidfile=/var/run/squid.pid
make -j$(nproc)
make install

wget --no-check-certificate -O /etc/init.d/squid http://firenetvpn.net/files/slowdns/squid.sh
chmod +x /etc/init.d/squid
update-rc.d squid defaults
chown -cR proxy /var/log/squid
squid -z
cd /etc/squid/
rm squid.conf

echo "acl Firenet dst `curl -s https://api.ipify.org`" >> squid.conf

echo 'http_port 8080
http_port 8181
visible_hostname Proxy
acl PURGE method PURGE
acl HEAD method HEAD
acl POST method POST
acl GET method GET
acl CONNECT method CONNECT
http_access allow Firenet
http_reply_access allow all
http_access deny all
icp_access allow all
always_direct allow all
visible_hostname Firenet-Proxy
error_directory /share/squid/errors/templates' >> squid.conf

cd /share/squid/errors/templates
rm ERR_INVALID_URL
echo '<!--FirenetDev--><!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>SECURE PROXY</title><meta name="viewport" content="width=device-width, initial-scale=1"><meta http-equiv="X-UA-Compatible" content="IE=edge"/><link rel="stylesheet" href="https://bootswatch.com/4/slate/bootstrap.min.css" media="screen"><link href="https://fonts.googleapis.com/css?family=Press+Start+2P" rel="stylesheet"><style>body{font-family: "Press Start 2P", cursive;}.fn-color{color: #ffff; background-image: -webkit-linear-gradient(92deg, #f35626, #feab3a); -webkit-background-clip: text; -webkit-text-fill-color: transparent; -webkit-animation: hue 5s infinite linear;}@-webkit-keyframes hue{from{-webkit-filter: hue-rotate(0deg);}to{-webkit-filter: hue-rotate(-360deg);}}</style></head><body><div class="container" style="padding-top: 50px"><div class="jumbotron"><h1 class="display-3 text-center fn-color">SECURE PROXY</h1><h4 class="text-center text-danger">SERVER</h4><p class="text-center">😍 %w 😍</p></div></div></body></html>' >> ERR_INVALID_URL
chmod 755 *
/etc/init.d/squid start
fi
