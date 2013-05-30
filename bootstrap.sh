#!/bin/bash
cd "$(dirname "$0")"
#git pull

function gitStuff() {
  my_email=`git config --get user.email`
  my_name=`git config --get user.name`
}

function doIt() {
  rsync --exclude ".git/" --exclude ".DS_Store" --exclude "*.sh" --exclude "README.md" -av . ~
}

function BackUp() {
  bud="dotbackup/$(date +%s)"
  if [ ! -d $bud ]; then
    mkdir -p ~/$bud
  fi
  for f in * .*; do
    if [ -f ~/$f ]; then
      rsync -avP ~/$f ~/$bud/
    fi
  done
}


gitStuff
if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt
else
  BackUp
	doIt
fi
unset doIt
unset BackUp
unset gitStuff
source ~/.bash_profile

IFS=''
if [ -z $my_email ]; then
  echo -n "Git E-mail? "
  read my_email
fi
git config --global user.email $my_email
if [ -z $my_name ]; then
  echo -n "Git Name? "
  read my_name
fi
git config --global user.name $my_name
