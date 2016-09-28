#!/bin/bash

/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

DBPASS=${MYSQL_PASS:-'admin'}
DBUSER=${MYSQL_USER:-'admin'}
DBNAME=${MYSQL_DBNAME:-'wordpress'}
VIRTUAL_HOST=${VIRTUAL_HOST:-'localhost'}
USER_EMAIL=${USER_EMAIL:-'support@'$VIRTUAL_HOST}
WP_USER=${WP_USER:-'admin'}
WP_PASSTEMP=${WP_PASS:-'password'}
#WP_PASS=$(printf '%s' $WP_PASSTEMP | md5sum)
WP_PASS=$(echo -n $WP_PASSTEMP | md5sum | awk '{print $1}')

_word=$( [ ${MYSQL_PASS} ] && echo "preset" || echo "random" )
echo "=> Creating MySQL $DBUSER user with ${_word} password"
echo "================================================================ "
echo "DB USER => $DBUSER"
echo "DB PASSWORD => $DBPASS"
echo "DB NAME => $DBNAME"
echo "WP USER => $WP_USER"
echo "WP PASS => $WP_PASS"
echo "WP TEMP => $WP_PASSTEMP"
echo "WP MAIL -> $USER_EMAIL"
echo "================================================================ "
mysql -uroot -e "CREATE DATABASE $DBNAME"
mysql -uroot -e "CREATE USER '$DBUSER'@'%' IDENTIFIED BY '$DBPASS'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '$DBUSER'@'%' WITH GRANT OPTION"
replace DOMAINNAMEHERE $VIRTUAL_HOST -- wordpress.sql
replace SITETITLEHERE $VIRTUAL_HOST -- wordpress.sql
replace USERNAMEHERE $WP_USER -- wordpress.sql
replace PASSWORDHERE $WP_PASS -- wordpress.sql
replcae USEREMAILHERE@EMAIL.COM $USER_EMAIL -- wordpress.sql

replace MYSQL_DBNAME $DBNAME -- /var/www/html/wp-config.php
replace MYSQL_USER $DBUSER -- /var/www/html/wp-config.php
replace MYSQL_PASS $DBPASS -- /var/www/html/wp-config.php

replace SITENAME ${VIRTUAL_DOMAIN:-'testuser'} -- /var/www/html/configuration.php
replace DBUSER $DBUSER -- /var/www/html/configuration.php 
replace DBPASSWORD $DBPASS -- /var/www/html/configuration.php
replace DBNAME $DBNAME -- /var/www/html/configuration.php 
replace TABLEPREFIX ${TABLEPREFIX:-'prefix_'} -- /var/www/html/configuration.php

replace TABLEPREFIX ${TABLEPREFIX:-'prefix_'} -- /joomla.sql 
replace USER_USERNAME $WP_USER -- /joomla.sql 
replace USER_EMAIL $USER_EMAIL -- /joomla.sql 
replace PASSWORDHERE $WP_PASS -- /joomla.sql 

replace MAIL $USER_EMAIL -- /var/www/html/configuration.php 

mysql -uroot $DBNAME < joomla.sql

rm wordpress.sql
# You can create a /mysql-setup.sh file to intialized the DB
if [ -f /mysql-setup.sh ] ; then
  . /mysql-setup.sh
fi

echo "=> Done!"

echo "========================================================================"
echo "You can now connect to this MySQL Server using:"
echo ""
echo "    mysql -u$DBUSER -p$DBPASS -h<host> -P<port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "MySQL user 'root' has no password but only allows local connections"
echo "========================================================================"

mysqladmin -uroot shutdown
