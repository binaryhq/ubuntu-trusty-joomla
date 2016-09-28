FROM ubuntu:trusty
MAINTAINER Ningappa <ningappa@poweruphosting.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update

RUN apt-get install -y git apache2 php5-cli php5-mysql php5-gd php5-curl  php5-sqlite libapache2-mod-php5 curl mysql-server mysql-client phpmyadmin wget unzip cron supervisor && \
echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN sed -i -e 's/^bind-address\s*=\s*127.0.0.1/#bind-address = 127.0.0.1/' /etc/mysql/my.cnf

RUN apt-get clean && a2enmod rewrite

ADD filemanager.zip /filemanager.zip
RUN unzip /filemanager.zip -d /usr/share/ && rm /filemanager.zip
ADD uploads/.htusers.php. /usr/share/filemanager/config/.htusers.php 
RUN chmod 777 /usr/share/filemanager/config/.htusers.php
RUN replace FILEMANAGERUSER ${FILEMANAGERUSER:-'testuser'} -- /usr/share/filemanager/config/.htusers.php
RUN replace FILEMANAGERPASSWORD $(echo -n ${FILEMANAGERPASSWORD:-'testpassword'} | md5sum | awk '{print $1}') -- /usr/share/filemanager/config/.htusers.php
RUN echo "Alias /filemanager /usr/share/filemanager" >> /etc/apache2/apache2.conf 

ADD joomla.zip /joomla.zip
RUN unzip /joomla.zip -d /var/www/html/ && rm /joomla.zip && rm /var/www/html/index.html
ADD uploads/configuration.php /var/www/html/configuration.php
ADD joomla.sql /joomla.sql

ADD uploads/start-apache2.sh /start-apache2.sh
ADD uploads/start-mysqld.sh /start-mysqld.sh
ADD uploads/create_mysql_admin_user.sh /create_mysql_admin_user.sh
ADD uploads/run.sh /run.sh

RUN chmod 755 /*.sh
RUN sed -i -e 's/^bind-address\s*=\s*127.0.0.1/#bind-address = 127.0.0.1/' /etc/mysql/my.cnf

ADD uploads/supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD uploads/supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
RUN rm -rf /var/lib/mysql/*


RUN chown -R www-data:www-data /var/www/

RUN rm -rf /var/lib/mysql/*


#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]

EXPOSE 80 3306
CMD ["/run.sh"]
