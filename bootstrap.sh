#!/bin/bash
cd "$(dirname "$0")"
#git pull

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

BackUp

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt
	fi
fi
unset doIt
source ~/.bash_profile

