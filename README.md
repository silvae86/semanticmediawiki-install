## How to install Semantic MediaWiki on Ubuntu 18.04 LTS

Original repository with scripts for installation: https://github.com/silvae86/semanticmediawiki-install

This is intended as a record of my installations of [Semantic MediaWiki](https://en.wikipedia.org/wiki/Semantic_MediaWiki) for the course of Information Management and Collaboration that I teach at the [Master in Information Science](https://sigarra.up.pt/feup/en/cur_geral.cur_view?pv_curso_id=737) at [FEUP](https://sigarra.up.pt/feup/en/web_page.Inicial).

It can also be used by anyone who needs to install a Semantic MediaWiki instance from scratch.

## Pre-requisites

A fresh Ubuntu machine (I am using 18.04 LTS on a Virtual Machine at the moment).

## Dependencies

Semantic MediaWiki needs MySQL, Apache2, PHP, Inkscape and others. We will install these as part of the process, as well as SendMail to be able to notify people when they register and to be able to recover passwords.

## Installation of MediaWiki

Before we can install the Semantic extension we need to install the base MediaWiki software.

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
sudo wget --progress=bar:force https://releases.wikimedia.org/mediawiki/1.31/mediawiki-1.31.1.tar.gz
tar -xvzf ./mediawiki-1.31.1.tar.gz
sudo rm -rf /var/lib/mediawiki
sudo mkdir -p /var/lib/mediawiki
sudo mv mediawiki-1.31.1/* /var/lib/mediawiki
cd /var/www/html
sudo ln -s /var/lib/mediawiki mediawiki
cd -
ls /var/www/html/mediawiki # You should see a file listing after these commands are run. It is the contents of mediawiki correctly installed in the Apache HTML folder.
```

### Increase maximum upload size on Apache to allow uploads larger than 2M to the wiki

**You may need to modify the PHP version** in the following commands as it changes. 7.2 needs to become 7.4, or whatever is installed on your system. Run `ls /etc/php`,  see which version of PHP you have installed and **modify the paths accordingly:**

```bash
sudo sed -i '/upload_max_filesize = 2M/c\\upload_max_filesize = 50M' /etc/php/7.2/apache2/php.ini
sudo sed -i '/memory_limit = 8M/c\\memory_limit = 128M' /etc/php/7.2/apache2/php.ini
sudo service apache2 restart # restart apache with new settings

```

### Configure your new mediawiki

Go to your website address in the browser (for my case http://gcc-mci.fe.up.pt/mediawiki, in your case you will adjust accordingly) and configure MediaWiki using the wizard.

![Mediawiki Setup Welcome Screen](https://github.com/silvae86/semanticmediawiki-install/raw/master/images/mediawiki_welcome.png)

#### Setup process

![Mediawiki Setup Language](https://github.com/silvae86/semanticmediawiki-install/raw/master/images/setup/1_language.png)

![Mediawiki Setup Database](https://github.com/silvae86/semanticmediawiki-install/raw/master/images/setup/2_db_setup.png)

![Mediawiki Setup Wiki Details](https://github.com/silvae86/semanticmediawiki-install/raw/master/images/setup/3_type_of_db.png)

![Mediawiki Setup Language](https://github.com/silvae86/semanticmediawiki-install/raw/master/images/setup/4_wiki_details.png)

![Mediawiki Setup Admin Details](https://github.com/silvae86/semanticmediawiki-install/raw/master/images/setup/5_add_admin_details.png)

![Mediawiki Setup Install Now](https://github.com/silvae86/semanticmediawiki-install/raw/master/images/setup/6_install_it.png)

![Mediawiki Setup Ready to Install](https://github.com/silvae86/semanticmediawiki-install/raw/master/images/setup/7_before_install.png)

![Mediawiki Setup Install Finished](https://github.com/silvae86/semanticmediawiki-install/raw/master/images/setup/8_finished.png)

![Mediawiki Setup Download LocalSettings](https://github.com/silvae86/semanticmediawiki-install/raw/master/images/setup/9_download_localsettings.png)

### Download LocalSettings.php to the MediaWiki installation

After the setup is complete, your browser will automatically download a file called `LocalSettings.php`. This will have to be placed in a specific directory and customised to suit our particular needs.

Upload the `LocalSettings.php` file to your home directory using an FTP client and then copy it to the MediaWiki installation directory

```bash
cd ~
sudo mv ~/LocalSettings.php /var/www/html/mediawiki
sudo chown -R www-data /var/www/html
```

### Set right permissions to enable file uploads

sudo chmod -R 0755 /var/www/html/mediawiki/images

### Mediawiki is Ready

You should now see the MediaWiki home page ready to work

![Mediawiki Ready](https://github.com/silvae86/semanticmediawiki-install/raw/master/images/setup/10_mediawiki_installed.png)

## Installation of Semantic MediaWiki extension

Semantic Mediawiki relies on PHP Composer. Let's install it first.

### Install PHP Composer

```bash
cd ~
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"

sudo apt-get -y -qq install composer

```

### Run PHP Composer on HTML Folder and update MediaWiki dependencies

```bash
cd /var/www/html
sudo chmod ugo+w composer.json
sudo mkdir -p /var/www/html/vendor
sudo chmod ugo+rw /var/www/html/vendor

cd /var/www/html/mediawiki
composer update
```

### Install Semantic Mediawiki extension in MediaWiki

```bash
cd /var/www/html/mediawiki
sudo mkdir -p ./extensions/SemanticMediaWiki
sudo chmod ugo+rw ./extensions/SemanticMediaWiki
sudo composer require mediawiki/semantic-media-wiki "3.0.0" --update-no-dev
sudo composer require mediawiki/semantic-result-formats "3.0.0"
composer update --no-dev
php maintenance/update.php
```

### Finishing Touches

The LocalSettings.php file needs to be customised with some tuning add-ons.

Add at the end:

```php
// Set custom logo if you want
$wgLogo = $wgScriptPath . '/images/feup_logo.png';

// Enable semantics for the wiki. Replace with the root URL of your wiki
enableSemantics( 'http://gcc-mci.fe.up.pt/mediawiki' ); //FIXME
//
//Prevent new user registrations except by sysops
$wgGroupPermissions['*']['createaccount'] = false;

//enable uploads
$wgEnableUploads = true; # Enable uploads

$wgTrustedMediaFormats[] = 'application/zip';

$wgFileExtensions = array( 'png', 'gif', 'jpg', 'jpeg', 'doc',
    'xls', 'mpp', 'pdf', 'ppt', 'tiff', 'bmp', 'docx', 'xlsx',
    'pptx', 'ps', 'odt', 'ods', 'odp', 'odg', 'zip'
);

//enable captchas to present spam
wfLoadExtensions( array( 'ConfirmEdit', 'ConfirmEdit/QuestyCaptcha' ) );

// Add your questions in LocalSettings.php using this format:
// A question may have many answers
$wgCaptchaQuestions = array(
    'Qual é o nome ou sigla desta Unidade Curricular?' => array( 'GCC', 'gestt
ão de conhecimento e colaboração', 'Gestão de Conhecimento', 'Gestão de C
onhecimento e Colaboração', 'gestao de conhecimento e colaboracao' )
);

$wgGroupPermissions['*']['edit'] = false;
```

## Extra 1: Promote users to admins if you need it

Access these pages and select your users; attribute them to the administration groups

http://your-wiki-address/mediawiki/index.php/Special:Privileges (in English)
http://your-wiki-address/mediawiki/index.php/Especial:Privil%C3%A9gios (in Portuguese)

### Your SemanticMediaWiki should be ready

Go to your wiki address, in my case http://gcc-mci.fe.up.pt/mediawiki/wiki/Special:Version or http://gcc-mci.fe.up.pt/mediawiki/index.php/Especial:Versão (in Portuguese wikis). You should see that your list includes Semantic Mediawiki:

![Semantic Mediawiki Installed](https://github.com/silvae86/semanticmediawiki-install/raw/master/images/setup/11-smw_installed.png)

Happy Wiki'ing!

## Extra 2: how to clone a semantic mediawiki installation

Sometimes you need to create different installations for separate permissions management. In my case I had to create several SMW instances where my students had administrative permissions to be able to parametrize controlled vocabularies. However, if they would be administrator of their wiki, they would see everyone's work (which is obviously not good for evaluation!)

The solution is to completely clone the wiki and make it into separate workspaces, so that they can be admins of their own wikis but not see their colleagues' work in their own wikis.

### Copy the folder to a new one

```bash
cp -R /var/www/html/mediawiki /var/www/html/grupo1
cp -R /var/www/html/mediawiki /var/www/html/grupo2
cp -R /var/www/html/mediawiki /var/www/html/grupo3
# ...
```

Now for all the new subfolders, you need to run the following operations.

### Enter the cloned folders

```bash
cd /var/www/html/grupo1
```

### Create an empty MySQL Database for every new cloned wiki

```bash
mysql -u root -pMYSQL_ROOT_PASSWORD # replace MYSQL_ROOT_PASSWORD with your mysql admin password

mysql> create database grupo1;
Query OK, 1 row affected (0.00 sec)

mysql> create database grupo2;
Query OK, 1 row affected (0.00 sec)

mysql> create database grupo3;
Query OK, 1 row affected (0.00 sec)
```

### Edit LocalSettings.php inside each cloned folder

If you do not edit this, all three wikis will be editing the same MySQL database! We need to change the database being used by each wiki, among other stuff.

```PHP
# Site name
$wgSitename = "Semantic MediaWiki Grupo 1 GCC"; # (Before) $wgSitename = "Semantic MediaWiki Sandbox GCC";

# Namespace, must be unique
$wgMetaNamespace = "Semantic_MediaWiki_Grupo1_GCC"; # (Before) $wgMetaNamespace = "Semantic_MediaWiki_Sandbox_GCC";

# Wiki subfolder
$wgScriptPath = "/grupo1";  # (Before) $wgScriptPath = "/mediawiki";  

## Database settings
$wgDBname = "grupo1"; # (Before) $wgDBname = "demo";

# Site secret
$wgSecretKey = "a_very_long_key"; # (Before) $wgSecretKey = "another_very_long_key";
```

### Recreate MediaWiki database tables

```bash
mysql -u root -pMYSQL_ROOT_PASSWORD < maintenance/tables.sql
```

### Recreate Semantic MediaWiki database tables

```bash
php maintenance/update.php
```

### Create admin user in each wiki

```bash
cd /var/www/html/grupo1
php maintenance/createAndPromote.php --sysop --bureaucrat new_user_username my_secret_password # create 'new_user_username' with password 'my_secret_password'
```
