FROM bennyplo1218/ubuntu-desktop-mac-m1:latest
LABEL maintainer "bennyplo@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

EXPOSE 80
EXPOSE 8080
EXPOSE 22
EXPOSE 443
EXPOSE 20
EXPOSE 21
EXPOSE 3306
EXPOSE 33060

RUN apt-get update -y
RUN apt-get -y install mysql-server mysql-client libmysqlclient-dev
RUN apt-get -y install apache2 apache2-doc apache2-utils libexpat1 ssl-cert
RUN apt-get -y install phpmyadmin
RUN apt-get -y install software-properties-common
RUN add-apt-repository ppa:ondrej/php
RUN apt-get -y install php8.1
RUN apt-get -y install libapache2-mod-php8.1

RUN apt-get -y update
#RUN apt-get -y install php7.4 libapache2-mod-php7.4 php7.4-curl
#php7.4-intl php7.4-zip php7.4-soap
#RUN apt-get -y install php7.4-xml php7.4-gd php7.4-mbstring php7.4-bcmath
#php7.4-common php7.4-xml
#RUN apt-get -y install php7.4-mysqli
#RUN apt-get -y install php-php-gettext
#RUN a2enmod php7.4
RUN apt -y install php8.1-mysql php8.1-curl php8.1-xml
RUN echo "<?php\nphpinfo();\n?>" >> /var/www/html/phpinfo.php
RUN a2enmod rewrite
#RUN su
RUN service apache2 restart
RUN apt-get -y install composer
####### install firefox
RUN  sudo add-apt-repository -y ppa:mozillateam/ppa
RUN echo 'Package: *' >> /etc/apt/preferences.d/mozilla-firefox
RUN echo 'Pin: release o=LP-PPA-mozillateam'>>/etc/apt/preferences.d/mozilla-firefox
RUN echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox
RUN echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";'\
 >> /etc/apt/apt.conf.d/51unattended-upgrades-firefox
RUN sudo apt-get install firefox -y --allow-downgrades
RUN apt -y upgrade
#############

WORKDIR /var/www/html
RUN apt -y install php-intl
RUN composer create-project typo3/cms-base-distribution:^11 example-project-directory
RUN touch /var/www/html/example-project-directory/public/FIRST_INSTALL
WORKDIR /var/www/html/example-project-directory
RUN composer install --no-dev
RUN ln -s /var/www/html/example-project-directory/public/ typo3


####Set up mysql ######
#RUN apt-get update
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server
#RUN rm -rf /var/lib/apt/lists/*
#RUN  sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/my.cnf
#RUN  sed -i 's/^\(log_error\s.*\)/# \1/' /etc/mysql/my.cnf

RUN  echo "mysqld_safe &" > /tmp/config
RUN  echo "mysqladmin --silent --wait=30 ping || exit 1" >> /tmp/config
RUN echo "mysql -e 'CREATE USER \"ubuntu\"@\"localhost\" IDENTIFIED WITH caching_sha2_password BY \"ubuntu\"'" >>/tmp/config
RUN echo "mysql -e 'GRANT ALL PRIVILEGES ON *.* TO \"ubuntu\"@\"localhost\" WITH GRANT OPTION;'" >> /tmp/config
RUN echo "mysql -e 'ALTER USER \"root\"@\"localhost\" IDENTIFIED WITH caching_sha2_password BY \"ubuntu\"'" >> /tmp/config
RUN bash /tmp/config
RUN rm -f /tmp/config
#################
#ENV DEBIAN_FRONTEND interactive
#set up the phpmyadmin
WORKDIR /root
#RUN apt-get install -y expect
#RUN printf '#!/usr/bin/expect\nset timeout 20 \nspawn sudo apt reinstall phpmyadmin\nexpect \"dbconfig-common? \[yes/no\] \"\nsend \"yes\\r\"\nexpect \"reconfigure automatically: \"\nsend \"1\\r\"\ninteract' >> install_script
#RUN chmod +x install_script
#RUN ./install_script
#RUN rm -f /install_script
RUN printf "\$dbserver='127.0.0.1';" >> /etc/phpmyadmin/config-db.php
#################
#set up the mysql_secure_installation
#RUN service apache2 start
#RUN service mysql start
#RUN printf '#!/usr/bin/expect\nset timeout 10\nspawn mysql_secure_installation\nexpect \"user root: \"\nsend \"ubuntu\\r\"\nexpect \"Press y|Y for Yes, any other key for No: \"\nsend \"n\\r\"\nexpect \"((Press y|Y for Yes, any other key for No) : \"\nsend \"n\\r\"\nexpect \"Remove anonymous users? (Press y|Y for Yes, any other key for No) : \"\nsend \"y\\r\"\nexpect \"Disallow root login remotely? (Press y|Y for Yes, any other key for No) : \"\nsend \"y\\r\"\nexpect \"Remove test database and access to it? (Press y|Y for Yes, any other key for No) :\"\nsend \"y\\r\"\nexpect \"Reload privilege tables now? (Press y|Y for Yes, any other key for No) : \"\nsend \"y\\r\"\ninteract' >> install_script2
#RUN chmod +x install_script2

###################
#set up typo3
RUN chown -R www-data:www-data /var/www/html/example-project-directory/
RUN ln -s /var/www/html/example-project-directory/public /var/www/html/typo3
RUN echo "<Directory /var/www/>" >>/etc/apache2/apache2.conf
RUN echo "Options Indexes FollowSymLinks" >>/etc/apache2/apache2.conf
RUN echo "AllowOverride All" >>/etc/apache2/apache2.conf
RUN echo "Require all granted" >>/etc/apache2/apache2.conf
RUN echo "</Directory>" >>/etc/apache2/apache2.conf
#RUN echo '<meta http-equiv="refresh" content="0; URL=./typo3/" />' >> /var/www/html/web

#RUN apt -y update
#RUN apt -y upgrade
#RUN apt -y install imagemagick
#RUN apt -y install ghostscript

###################
# Set up wiki
WORKDIR /var/www/html/
RUN wget https://releases.wikimedia.org/mediawiki/1.38/mediawiki-1.38.2.tar.gz
RUN tar -xf mediawiki-1.38.2.tar.gz
RUN rm mediawiki-1.38.2.tar.gz
RUN echo '<meta http-equiv="refresh" content="0; URL=http://127.0.0.1:6080/mediawiki-1.38.2/index.php/Main_Page" />' >> /var/www/html/wiki
WORKDIR /root


############
#note: need to run the following to set up the phpmyadmin
#$sudo apt reinstall phpmyadmin
#$sudo dpkg --configure -a
#$service apache2 start
#$service mysql start
#$service vncserver start
# to get to phpmyadmin go to:
# http://127.0.0.1:6080/phpmyadmin/
# you can check the php via:
# http://127.0.0.1:6080/phpinfo.php
#######################
#To set up the mediawiki
# http://127.0.0.1:6080/mediawiki-1.38.2
# afterwards, you then download the LocalSetting.php
# then sftp to upload the file
# $sftp -oPort=55000 ubuntu@localhost
# password: ubuntu
# then copy that file into /var/www/html/mediawiki-1.38.2
# cp /home/ubuntu/LocalSettings.php /var/www/html/mediawiki-1.38.2/.


#########################
#do the following to setup the typo3 webserver:
#1. Modify the php configurations
#$nano /etc/php/8.1/apache2/php.ini
# change the max_execution_time to 240
# change the max_input_vars to 1500
#then reload the apache2
#$service apache2 reload
#
#go to page: http://127.0.0.1:6080/typo3/
#then follow the instructions
#note the database username/password is both: ubuntu
#suggest you set the user name of typo3 to ubuntu and password: ubuntu1234
#after setting it up, you can get access to the webpage via: http://127.0.0.1:6080/web
