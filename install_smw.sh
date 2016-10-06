#!/usr/bin/env bash

MYSQL_PASSWORD="FIXME__PASSWORD"
HOST="your.website.com"
ADDRESS="http://${HOST}"

#DNS fixes
sudo rm /etc/resolv.conf
sudo ln -s ../run/resolvconf/resolv.conf /etc/resolv.conf
sudo resolvconf -u

#start setup
sudo dpkg --configure -a
sudo apt-get -y -qq update
sudo apt-get -y -qq upgrade
sudo apt-get -y -f -qq install wget apache2 php php-mysql libapache2-mod-php php-xml php-mbstring php-apcu php-intl imagemagick inkscape php-gd php-cli mysql-client-5.7

#mysql config + install
sudo apt-get -y -f -qq install debconf-utils

debconf-set-selections <<< "mysql-server mysql-server/root_password password ${MYSQL_PASSWORD}"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${MYSQL_PASSWORD}"
apt-get update
sudo apt-get -y install mysql-server

mkdir -p Downloads
cd Downloads
sudo wget --progress=bar:force https://releases.wikimedia.org/mediawiki/1.27/mediawiki-1.27.1.tar.gz
tar -xvzf ./mediawiki-1.27.1.tar.gz
sudo rm -rf /var/lib/mediawiki
sudo mkdir -p /var/lib/mediawiki
sudo mv mediawiki-1.27.1/* /var/lib/mediawiki

mysqladmin -u root -p "${MYSQL_PASSWORD}"
history -c

sudo sed -i '/upload_max_filesize = 2M/c\\upload_max_filesize = 50M' /etc/php/7.0/apache2/php.ini
sudo sed -i '/memory_limit = 8M/c\\memory_limit = 128M' /etc/php/7.0/apache2/php.ini


cd /var/www/html
sudo ln -s /var/lib/mediawiki mediawiki
cd -
echo "Visit http://$HOST/mediawiki to access your new MediaWiki installation and configure it."
echo "Type 'yes' when you have configured your MediaWiki. After that, we will continue with the installation of the Semantic Mediawiki module."
read CONFIRM

if [ "$CONFIRM" = "yes" ] ; then
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
	php -r "if (hash_file('SHA384', 'composer-setup.php') === 'e115a8dc7871f15d853148a7fbac7da27d6c0030b848d9b3dc09e2a0388afed865e6a3d6b3c0fad45c48e2b5fc1196ae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
	php composer-setup.php
	php -r "unlink('composer-setup.php');"

	cd /var/www/html
	sudo chmod ugo+w composer.json
	sudo mkdir -p /var/www/html/vendor
	sudo chmod ugo+rw /var/www/html/vendor
	
	sudo mkdir -p ./extensions/SemanticMediaWiki
	sudo chmod ugo+rw ./extensions/SemanticMediaWiki
	
	php ~/composer.phar require mediawiki/semantic-media-wiki "~2.1" --update-no-dev
	cd mediawiki
	php maintenance/update.php

	lineToAppend ="enableSemantics( '${ADDRESS}' );"
	fileToModify = "LocalSettings.php"

	grep -q -F '$lineToAppend' $fileToModify || echo '$lineToAppend' >> $fileToModify
	cd -
	
	echo "Please visit ${ADDRESS}/wiki/Special:Version to check it Semantic Mediawiki is installed."
	
fi
