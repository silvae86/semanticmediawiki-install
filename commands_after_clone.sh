#!/bin/bash

#cd to install dir
cd /var/lib/mediawiki

# since we have changed the temp folder and cache folder parameters in LocalSettings.php:
sudo mkdir -p cache
sudo chmod ugo+w cache
mkdir -p temp 
sudo chmod ugo+w temp

#rebuild or install databases
sudo php maintenance/rebuildall.php
cd extensions/SemanticMediaWiki/
sudo php maintenance/SMW_setup.php
sudo php maintenance/rebuildData.php
