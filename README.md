# How to install a base Semantic MediaWiki

This is intended as a record of my installations of Semantic MediaWiki for the course of Information Management and Collaboration at FEUP.

It can also be used by anyone who needs to install a Semantic MediaWiki instance from scratch.

## Pre-requisites

A fresh Ubuntu machine (I am using 18.04 LTS on a Virtual Machine at the moment).

## Dependencies

Semantic MediaWiki needs MySQL, Apache2, PHP, Inkscape and others. We will install these as part of the process, as well as SendMail to be able to notify people when they register and to be able to recover passwords.

## Installation

Now lets get on with the installation.

### Set up some variables for the installation

First is necessary to set up some preliminary values that will be used later in the script. Remember, if you close the current terminal session you will have to set them up again.

```bash
MYSQL_PASSWORD="FIXME__PASSWORD"
HOST="gcc-mci.fe.up.pt"
echo $HOST
ADDRESS="http://${HOST}"
echo $ADDRESS
```

1. The default root password for MySQL (keep it safe!)
2. The host name of the machine you are configuring
3. The internet address of the machine.

**Replace these with what you need before typing Enter in the terminal!**

### Some cleanup

```bash
sudo dpkg --configure -a
sudo apt-get -y -qq update
sudo apt-get -y -qq upgrade
```

### Install SendMail

```bash
#install sendmail
sudo apt-get update
sudo apt-get install -y -qq sendmail
```

### Install Apache2, PHP and MySQL Client and other dependencies

```bash
sudo apt-get -y -f -qq install wget apache2 php php-mysql libapache2-mod-php php-xml php-mbstring php-apcu php-intl imagemagick inkscape php-gd php-cli mysql-client-5.7
```

### Install MySQL Server and set password automatically

```bash
sudo apt-get -y -f -qq install debconf-utils
debconf-set-selections <<< "mysql-server mysql-server/root_password password ${MYSQL_PASSWORD}"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${MYSQL_PASSWORD}"
apt-get update
sudo apt-get -y install mysql-server
#will try to login using the root password
mysql -u root -p${MYSQL_PASSWORD}
# you should see the mysql prompt
```

### Download MediaWiki and move it to installation directory

```bash
mkdir -p Downloads
cd Downloads
sudo wget --progress=bar:force https://releases.wikimedia.org/mediawiki/1.27/mediawiki-1.27.1.tar.gz
tar -xvzf ./mediawiki-1.27.1.tar.gz
sudo rm -rf /var/lib/mediawiki
sudo mkdir -p /var/lib/mediawiki
sudo mv mediawiki-1.27.1/* /var/lib/mediawiki
cd /var/www/html
sudo ln -s /var/lib/mediawiki mediawiki
cd -
ls /var/www/html/mediawiki # You should see a file listing after these commands are run. It is the contents of mediawiki correctly installed in the Apache HTML folder.
```

### Increase maximum upload size on Apache to allow uploads larger than 2M to the wiki

**You may need to modify the PHP version in the following commands as it changes. 7.2 needs to become 7.4, or whatever is installed on your system. Run `ls /etc/php`,  see which version of PHP you have installed and modify the paths accordingly:

```bash
sudo sed -i '/upload_max_filesize = 2M/c\\upload_max_filesize = 50M' /etc/php/7.2/apache2/php.ini
sudo sed -i '/memory_limit = 8M/c\\memory_limit = 128M' /etc/php/7.2/apache2/php.ini
sudo service apache2 restart # restart apache with new settings

```

### Configure your new mediawiki

Go to your website address in the browser (for my case http://gcc-mci.fe.up.pt/mediawiki, in your case you will adjust accordingly) and configure MediaWiki using the wizard.

![Mediawiki Setup Welcome Screen](https://github.com/silvae86/semanticmediawiki-install/raw/master/images/mediawiki_welcome.png)

#### Setup process

![Mediawiki Setup Language](https://github.com/silvae86/semanticmediawiki-install/raw/master/images/mediawiki_welcome.png)

![Mediawiki Setup Database](https://github.com/silvae86/semanticmediawiki-install/raw/master/images/mediawiki_welcome.png)

![Mediawiki Setup Database 2](https://github.com/silvae86/semanticmediawiki-install/raw/master/images/mediawiki_welcome.png)

![Mediawiki Setup Wiki Details](https://github.com/silvae86/semanticmediawiki-install/raw/master/images/mediawiki_welcome.png)

![Mediawiki Setup Language](https://github.com/silvae86/semanticmediawiki-install/raw/master/images/mediawiki_welcome.png)

![Mediawiki Setup Install Now](https://github.com/silvae86/semanticmediawiki-install/raw/master/images/mediawiki_welcome.png)

![Mediawiki Setup Install Finished](https://github.com/silvae86/semanticmediawiki-install/raw/master/images/mediawiki_welcome.png)

![Mediawiki Setup Download LocalSettings](https://github.com/silvae86/semanticmediawiki-install/raw/master/images/mediawiki_welcome.png)
