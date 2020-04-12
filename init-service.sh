#!/bin/bash
tmplFile="/docker-template.service"
configFile="/docker.calibre-web-rpi.service"
configPath="/.trasba/testing"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
def_username="pi"
def_dockercompose="\/docker-compose.yml"
bak=".bak"
### define functions
function get_dockercompose_path {
  dockercompose_bin=$(which docker-compose)
  tmp_ext=$?
  if [ $tmp_ext == 1  ]; then
    echo "docker-compose could not be found with which. Is it installed?"
    echo "Exiting"
    exit 1
  fi
}
function enable_service {
  if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
  fi
  systemctl enable $DIR$configFile
  service docker.docker-calibre-web start
}
function setconfig { #ask user for settings
  echo "Creating service file with current directory as working dir"
  echo "leave empty to use default"
  read -p "username [$def_username]: " username
  if [ -z $username ]; then
    username=$def_username
  else
    username=$username
  fi
  sed 's,~~WORK-DIR~~,'"$DIR"',g' $DIR$tmplFile > $hd$configPath$configFile
  sed -i 's,~~USER~~,'"$username"',g' $hd$configPath$configFile
  sed -i 's,~~DOCKER-COMPOSE~~,'"$DIR$def_dockercompose"',g' $hd$configPath$configFile
  sed -i 's,~~DOCKER-COMPOSE-BIN~~,'"$DIR$dockercompose_bin"',g' $hd$configPath$configFile
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
get_dockercompose_path
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
        [Yy]* ) echo "Backing up old config file"; mv $DIR$configFile $DIR$configFile$bak; setconfig; create-symlink; break;;
        [Nn]* ) echo "Nothing to do."; break;;
        * ) echo "Please answer yes or no.";;
      esac
    done
    echo "enabling service"
    enable_service
    echo "Exiting."
    exit 0
  fi
  while true; do
    read -p "Overwrite local config file?(y/n) " overwrite
    case $overwrite in
      [Yy]* ) echo "Backing up old config file"; mv $DIR$configFile $DIR$configFile$bak; create-symlink; break;;
      [Nn]* ) echo "Aborting"; exit;;
      * ) echo "Please answer yes or no.";;
    esac
  done
else
  create-symlink
  echo "Exiting."
fi
exit 0
