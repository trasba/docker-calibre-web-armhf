#!/bin/bash
configFile="/.env"
configPath="/.trasba/testing"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
bak=".bak"
### default values
def_PGID="1000"
def_PUID="1000"
def_TZ="TZ=CET-1CEST,M3.5.0/2,M10.5.0/3"
def_volbooks="~/.trasba/calibre-web/books"
def_volconfig="~/.trasba/calibre-web/config"
### define functions
function setconfig { #ask user for settings
  echo "leave empty to use default"
  read -p "PGID [1000]: " PGID
  read -p "PUID [1000]: " PUID
  read -p "TZ (timezone) [$def_TZ]: " TZ
  read -p "volbooks [$def_volbooks]: " volbooks
  read -p "volconfig [$def_volconfig]: " volconfig
  if [ -z $PGID ]; then
    echo "PGID=$def_PGID" > $hd$configPath$configFile
  else
    echo "PGID=$PGID" > $hd$configPath$configFile
  fi
  if [ -z $PUID ]; then
    echo "PUID=$def_PUID" >> $hd$configPath$configFile
  else
    echo "PUID=$PUID" >> $hd$configPath$configFile
  fi
  if [ -z $TZ ]; then
    echo "TZ=$def_TZ" >> $hd$configPath$configFile
  else
    echo "TZ=$TZ" >> $hd$configPath$configFile
  fi
  if [ -z $volbooks ]; then
    echo "volbooks=$def_volbooks" >> $hd$configPath$configFile
  else
    echo "volbooks=$volbooks" >> $hd$configPath$configFile
  fi
  if [ -z $volconfig ]; then
    echo "volconfig=$def_volconfig" >> $hd$configPath$configFile
  else
    echo "volconfig=$volconfig" >> $hd$configPath$configFile
  fi
}

function checklocal { # true if file exists, false if not
  if [ -f $DIR$configFile ]; then
    existslocal=1
  else
    existslocal=0
  fi
}

function create-symlink {
  echo "Creating symlink $hd$configPath$configFile -> $DIR$configFile"
  ln -s $hd$configPath$configFile $DIR$configFile
}
### get user home dir
hd=$( getent passwd "$USER" ) #hd  => homedir
hdRC=$? #hdRC => homedir Return Code
if [ $hdRC == 0 ];
  then
    hd=$(echo $hd|cut -d: -f6)
elif [ $hdRC == 2 ];
  then
    echo "getent error: One or more supplied key could not be found in the database."
    echo "Does the user exist?"
    exit 1
fi
### echo remote dir and local dir
echo "Remote config path is: $hd$configPath"
echo "Local config path is: $DIR"
### check if file exists remotely, and create it if not
if [ ! -f $hd$configPath$configFile ]; then
  echo "Config file does not exist."
  echo "Creating config path"
  mkdir -p $hd$configPath #make dir if it does not exist
  setconfig
else
  echo "Remote config file exists."
fi
### check if file exists locally
checklocal
if [ $existslocal == 1 ]; then
  echo "Local config file exists."
  realpath=$(readlink -f $DIR$configFile)
  if [ $realpath == $hd$configPath$configFile ]; then
    echo "Symlink already created."
    while true; do
      read -p "Recreate config file?(y/n) " recreate
      case $recreate in
        [Yy]* ) echo "Backing up old config file"; cp $DIR$configFile $DIR$configFile$bak; rm $DIR$configFile; setconfig; create-symlink; break;;
        [Nn]* ) echo "Nothing to do."; break;;
        * ) echo "Please answer yes or no.";;
      esac
    done
    echo "Exiting."
    exit 0
  fi
  while true; do
    read -p "Overwrite local config file?(y/n) " overwrite
    case $overwrite in
      [Yy]* ) echo "Backing up old config file"; cp $DIR$configFile $DIR$configFile$bak; rm $DIR$configFile; create-symlink; break;;
      [Nn]* ) echo "Aborting"; exit;;
      * ) echo "Please answer yes or no.";;
    esac
  done
else
  create-symlink
  echo "Exiting."
fi
exit 0
