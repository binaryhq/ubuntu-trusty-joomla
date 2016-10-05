FROM ubuntu:trusty
MAINTAINER Ningappa <ningappa@poweruphosting.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update

RUN apt-get install -y git apache2 php5-cli php5-mysql php5-gd php5-curl  php5-sqlite libapache2-mod-php5 curl mysql-server mysql-client  wget unzip cron supervisor && \
	apt-get clean && \
	rm -r /var/lib/apt/lists/*
	
RUN sed -i -e 's/^bind-address\s*=\s*127.0.0.1/#bind-address = 127.0.0.1/' /etc/mysql/my.cnf

RUN apt-get clean && a2enmod rewrite

ADD uploads/pbn	/usr/share/pbn
ADD uploads/html	/var/www/html

RUN chmod 777 /usr/share/pbn/filemanager/config/.htusers.php && \
	echo "IncludeOptional /usr/share/pbn/apache2.conf" >> /etc/apache2/apache2.conf && \
	echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
	rm /var/www/html/index.html && \
	rm -rf /var/lib/mysql/*

ADD uploads/joomla.sql /joomla.sql

ADD uploads/start-apache2.sh /start-apache2.sh
ADD uploads/start-mysqld.sh /start-mysqld.sh
ADD uploads/create_mysql_admin_user.sh /create_mysql_admin_user.sh
ADD uploads/run.sh /run.sh

RUN chmod 755 /*.sh

ADD uploads/supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD uploads/supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

RUN chown -R www-data:www-data /var/www/

#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]

EXPOSE 80 3306 2083
CMD ["/run.sh"]
