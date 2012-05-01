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


if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt
else
    BackUp
	doIt
fi
unset doIt
unset BackUp
source ~/.bash_profile

