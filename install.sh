#!/bin/bash
# Aoo Basic installation wrapper # Version 1.0.0.2
# Script Developed by Apivat Pattana-Anurak
# SysAdmin & Programmer Form #Bangkok #Thailand 
# curl -O https://raw.githubusercontent.com/aoopa/Nextcloud/master/install.sh
# sh install.sh

#########################################
##### Step 1 : Install Apache Web Server
yum install httpd -y
systemctl start httpd
systemctl enable httpd


##### Open Firewall P:80
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --list-all
firewall-cmd --reload

#########################################
##### Step 2 : Install MariaDB
yum install epel-release -y
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
yum install httpd php70w php70w-dom php70w-mbstring php70w-gd php70w-pdo php70w-json php70w-xml php70w-zip php70w-curl php70w-mcrypt php70w-pear setroubleshoot-server bzip2

yum install mariadb-server php70w-mysql -y
systemctl start mariadb
systemctl enable mariadb

mysql_secure_installation
mysql -u root -p
####### ตั้งค่า-เริ่มสร้าง Database , Uname , Pass โดยตอบคำถามดังต่อไปนี้
#Answer1 CREATE DATABASE nextcloud;
#Answer2 create user 'bestidc'@localhost identified by 'Biss@min2019';
#Answer3 GRANT ALL PRIVILEGES ON nextcloud.* TO 'bestidc'@'localhost';
#Answer4 FLUSH PRIVILEGES;
#Answer5 exit;

#########################################
##### Step 3: Install NextCloud
cd /var/www/html
curl -o nextcloud-14-latest.tar.bz2 https://download.nextcloud.com/server/releases/latest-14.tar.bz2
tar -xvjf nextcloud-14-latest.tar.bz2
mkdir nextcloud/data
chown -R apache:apache nextcloud
rm nextcloud-14-latest.tar.bz2

echo -e " Alias /nextcloud "/var/www/html/nextcloud/" "
>> /etc/httpd/conf.d/nextcloud.conf
echo -e "<Directory /var/www/html/nextcloud/>\n
         Options +FollowSymlinks \n
         AllowOverride All \n
         <IfModule mod_dav.c> \n
         Dav off    \n
         </IfModule>  \n
         SetEnv HOME /var/www/html/nextcloud \n
         SetEnv HTTP_HOME /var/www/html/nextcloud     \n
         </Directory>  "
>> /etc/httpd/conf.d/nextcloud.conf

#########################################
##### Step 4 : Setting Apache and SELinux
semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/nextcloud/data(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/nextcloud/config(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/nextcloud/apps(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/nextcloud/.htaccess'
semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/nextcloud/.user.ini'
restorecon -Rv '/var/www/html/nextcloud/'

setsebool -P httpd_can_network_connect_db 1
systemctl restart httpd
