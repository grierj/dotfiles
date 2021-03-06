#!/bin/bash
cd "$(dirname "$0")"

if [[ "$SHELL" = */zsh ]]; then
  PREFIX="zsh"
else
  PREFIX="bash"
fi

function die() {
  if [ $0 != 0 ]; then
    echo $@
    exit 1
  fi
}

function installOhMyZsh {
  if [[ -z $ZSH ]] || [[ ! -d $ZSH ]]; then
    bash -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
}

function gitStuff() {
  my_email=`git config --get user.email`
  my_name=`git config --get user.name`
}

function makeLink() {
  file="$1"
  final_file=$(realpath $file)
  filename=$(basename $file)
  if [[ "$filename" == "/" ]] || [[ "$filename" == "." ]] || [[ "$filename" == ".." ]] || [[ "$filename" == "" ]]; then
    die "Got '$filename' for linking, which you don't want, your script is busted"
  fi
  homefile="$HOME/$filename"
  if [[ -h $homefile ]] && [[ "$(readlink -n $homefile)" != "$final_file" ]]; then
    echo "$(readlink $homefile) isn't the same as $final_file) removing link"
    rm $homefile
  fi
  if [[ ! -h $homefile ]]; then
    if [[ -e $homefile ]] && [[ -e $final_file ]]; then
      rm -rf $homefile
    fi
    echo "Linking $final_file to $homefile"
    ln -s $final_file $homefile
  fi
}


function doIt() {
  pushd $PREFIX
    for dotfile in .[a-zA-Z0-9]*; do
      makeLink $PWD/$dotfile
    done
  popd
  # I don't want to check in whatever user/e-mail I am at the time because this leaks employer info
  cp .gitconfig ~/.gitconfig
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
    perl -pi -e 's#colorscheme#"colorscheme#' $(realpath ~/.vimrc)
  fi
}

function uncommentColor() {
  if [ -f ~/.vimrc ]; then
    perl -pi -e 's#"colorscheme#colorscheme#' $(realpath ~/.vimrc)
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
if [[ "$PREFIX" = "zsh" ]]; then
  installOhMyZsh || die "Couldn't install oh my zsh, you'll have to do it manually"
fi
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

if [[ "$PREFIX" = "zsh" ]]; then
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
