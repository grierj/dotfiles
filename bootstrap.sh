#!/bin/bash
cd "$(dirname "$0")"

function die() {
  if [ $0 != 0 ]; then
    echo $@
    exit 1
  fi
}

function gitStuff() {
  my_email=`git config --get user.email`
  my_name=`git config --get user.name`
}

function makePlugin() {
  CUSTOM_PREFIX="custom/plugins/mydotfiles"
  CUSTOM_FILE="$CUSTOM_PREFIX/mydotfiles.plugin.zsh"
  if [ ! -d $CUSTOM_PREFIX ]; then
    mkdir -p $CUSTOM_PREFIX
  fi
  cat .aliases > $CUSTOM_FILE
  cat .functions >> $CUSTOM_FILE
  cat .exports >> $CUSTOM_FILE
}

function doIt() {
  if [[ "$OSTYPE" = darwin* ]]; then
    rsync --exclude "custom/" --exclude ".bash*" --exclude ".inputrc" --exclude ".aliases" --exclude ".export" --exclude ".functions" --exclude ".git/" --exclude ".DS_Store" --exclude "*.sh" --exclude "README.md" -av . ~
  else
    rsync --exclude ".git/" --exclude ".DS_Store" --exclude "*.sh" --exclude "README.md" -av . ~
  fi
}

function getVundle() {
  if [ ! -d ~/.vim/bundle/vundle ]; then
    if [ ! -d ~/.vim/bundle ]; then
      mkdir ~/.vim/bundle || die "Can't make bundle directory for vim"
    fi
    cd ~/.vim/bundle
    git clone https://github.com/gmarik/Vundle.vim.git vundle
  fi
}

# When vundle is first installed, we don't have colors and so vim
# stops and asks for you to hit return
function commentColor() {
  if [ -f ~/.vimrc ]; then
    perl -pi -e 's#colorscheme#"colorscheme#' ~/.vimrc
  fi
}

function uncommentColor() {
  if [ -f ~/.vimrc ]; then
    perl -pi -e 's#"colorscheme#colorscheme#' ~/.vimrc
  fi
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
makePlugin
if [ "$1" == "--force" -o "$1" == "-f" ]; then
  echo "Skipping backup due to --force"
else
  BackUp || die "Couldn't backup old file, use --force to override"
fi
doIt || die "Something went terribly wrong installing your dotfiles"
unset doIt
unset BackUp
unset gitStuff
unset makePlugin

if [[ "$OSTYPE" = darwin* ]]; then
  # can't source from in bash
  echo "#####################"
  echo "Run 'source ~/.zshrc'"
  echo "#####################"
else
  source ~/.bash_profile
fi

getVundle || die "Vundle failed to install"
unset getVundle
commentColor
vim -c "BundleInstall" -c "q" -c "q"
uncommentColor
unset commentColor
unset uncommentColor

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
