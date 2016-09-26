FROM ubuntu:trusty
MAINTAINER Ningappa <ningappa@poweruphosting.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update

RUN apt-get install -y git apache2 php5-cli php5-mysql php5-gd php5-curl  php5-sqlite libapache2-mod-php5 curl mysql-server mysql-client phpmyadmin wget unzip cron supervisor && \
echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN apt-get clean && a2enmod rewrite

ADD filemanager.zip /filemanager.zip
RUN unzip /filemanager.zip -d /usr/share/ && rm /filemanager.zip
ADD uploads/.htusers.php. /usr/share/filemanager/config/.htusers.php
RUN replace FILEMANAGERUSER ${FILEMANAGERUSER:-'testuser'} -- /usr/share/filemanager/config/.htusers.php
RUN replace FILEMANAGERPASSWORD $(echo -n ${FILEMANAGERPASSWORD:-'testpassword'} | md5sum | awk '{print $1}') -- /usr/share/filemanager/config/.htusers.php
RUN echo "Alias /filemanager /usr/share/filemanager" >> /etc/apache2/apache2.conf

EXPOSE 80 3306
