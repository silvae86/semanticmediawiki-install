# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/xenial64"
  config.vm.box_version = "20160606.1.0"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.

  config.vm.network "private_network", ip: ENV['VAGRANT_VM_IP']

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    #vb.gui = true

    # Customize the amount of memory on the VM:
    vb.memory = "1024"
    vb.name="smw"
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    #DNS fixes
    sudo rm /etc/resolv.conf
    sudo ln -s ../run/resolvconf/resolv.conf /etc/resolv.conf
    sudo resolvconf -u

    #start setup
    sudo dpkg --configure -a
    sudo apt-get -y -qq update
    sudo apt-get -y -qq upgrade
    sudo apt-get -y -f -qq install wget apache2 php php-mysql libapache2-mod-php php-xml php-mbstring php-apcu php-intl imagemagick inkscape php-gd php-cli mysql-client-5.7

    sudo apt-get install php-xml
    sudo apt-get install php-mbstring
    sudo service apache2 restart
    sudo apt-get install php-apcu
    sudo apt-get install php-cache
    
    #mysql config + install
    sudo apt-get -y -f -qq install debconf-utils

    debconf-set-selections <<< 'mysql-server mysql-server/root_password password #{ENV['VAGRANT_MYSQL_PASSWORD']}'
    debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password #{ENV['VAGRANT_MYSQL_PASSWORD']}'
    apt-get update
    sudo apt-get -y install mysql-server

    mkdir -p Downloads
    cd Downloads
    sudo wget --progress=bar:force https://releases.wikimedia.org/mediawiki/1.27/mediawiki-1.27.1.tar.gz
    tar -xvzf ./mediawiki-1.27.1.tar.gz
    sudo rm -rf /var/lib/mediawiki
    sudo mkdir -p /var/lib/mediawiki
    sudo mv mediawiki-1.27.1/* /var/lib/mediawiki

    mysqladmin -u root -p "#{ENV['VAGRANT_MYSQL_PASSWORD']}"
    history -c

    sudo sed -i '/upload_max_filesize = 2M/c\\upload_max_filesize = 50M' /etc/php/7.0/apache2/php.ini
    sudo sed -i '/memory_limit = 8M/c\\memory_limit = 128M' /etc/php/7.0/apache2/php.ini


    cd /var/www/html
    sudo ln -s /var/lib/mediawiki mediawiki
    cd -
    echo "Visit http://#{ENV['VAGRANT_VM_IP']}/mediawiki to access your new MediaWiki installation and configure it."
    echo "Type 'yes' when you have configured your MediaWiki. After that, we will continue with the installation of the Semantic Mediawiki module."
    read CONFIRM

    if [ "$CONFIRM" = "yes" ] ; then
      php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
      php -r "if (hash_file('SHA384', 'composer-setup.php') === 'e115a8dc7871f15d853148a7fbac7da27d6c0030b848d9b3dc09e2a0388afed865e6a3d6b3c0fad45c48e2b5fc1196ae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
      php composer-setup.php
      php -r "unlink('composer-setup.php');"

      cd /var/www/html
      php composer.phar require mediawiki/semantic-media-wiki "~2.1" --update-no-dev
      cd mediawiki
      php maintenance/update.php

      lineToAppend ="enableSemantics( '#{ENV['SMW_SETUP_ADDRESS']}' );"
      fileToModify = "LocalSettings.php"

      grep -q -F '$lineToAppend' $fileToModify || echo '$lineToAppend' >> $fileToModify
      cd -

      echo "Please visit http://#{ENV['SMW_SETUP_ADDRESS']}/wiki/Special:Version to check it Semantic Mediawiki is installed."
    fi

  SHELL
end
