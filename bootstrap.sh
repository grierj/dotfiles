#!/bin/bash
# Link the dotfiles in bash/ into $HOME, backing up anything replaced.
#
# This is meant to run on a nearly bare machine, so it only assumes bash
# and basic coreutils (git is needed for the optional --vim step and to
# have cloned this repo in the first place). It deliberately avoids
# GNU-only tools like realpath/readlink -f so it also works on macOS
# with the stock bash 3.2.
#
# Usage: ./bootstrap.sh [--dry-run] [--force] [--vim]

set -eu

DRY_RUN=0
FORCE=0
DO_VIM=0
BACKUP_DIR=""

usage() {
  echo "Usage: $0 [--dry-run] [--force] [--vim]"
  echo "  --dry-run, -n   print what would happen, change nothing"
  echo "  --force, -f     replace existing files without backing them up"
  echo "  --vim           also install Vundle and vim plugins (needs git, vim, network)"
}

for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY_RUN=1 ;;
    --force|-f)   FORCE=1 ;;
    --vim)        DO_VIM=1 ;;
    --help|-h)    usage; exit 0 ;;
    *) echo "Unknown argument: $arg" >&2; usage >&2; exit 1 ;;
  esac
done

# Run from the repo root regardless of where the script was invoked from.
cd "$(dirname "$0")"
REPO_DIR=$(pwd -P)

run() {
  # Echo and (unless --dry-run) execute a command.
  if [ "$DRY_RUN" = "1" ]; then
    echo "would run: $*"
  else
    "$@"
  fi
}

# Print the canonical path of $1, resolving symlinks one hop at a time.
# (Neither readlink nor ls are fancy here; this is the portable subset.)
resolve_path() {
  _rp_path=$1
  while [ -L "$_rp_path" ]; do
    _rp_dir=$(cd -P "$(dirname "$_rp_path")" && pwd)
    _rp_path=$(readlink "$_rp_path")
    case "$_rp_path" in
      /*) ;;
      *) _rp_path="$_rp_dir/$_rp_path" ;;
    esac
  done
  _rp_dir=$(cd -P "$(dirname "$_rp_path")" 2>/dev/null && pwd) || _rp_dir=$(dirname "$_rp_path")
  echo "$_rp_dir/$(basename "$_rp_path")"
}

# Move $1 aside into ~/dotbackup/<timestamp>/ (created on first use).
backup() {
  if [ -z "$BACKUP_DIR" ]; then
    BACKUP_DIR="$HOME/dotbackup/$(date +%Y%m%d%H%M%S)"
    run mkdir -p "$BACKUP_DIR"
    echo "Backing up replaced files to $BACKUP_DIR"
  fi
  echo "  backup: $1 -> $BACKUP_DIR/"
  run mv "$1" "$BACKUP_DIR/"
}

# Symlink $2 -> $1, backing up (or with --force, removing) whatever is
# currently at $2. Already-correct links are left alone.
make_link() {
  _ml_src=$(resolve_path "$1")
  _ml_dst=$2

  if [ -L "$_ml_dst" ] && [ "$(resolve_path "$_ml_dst")" = "$_ml_src" ]; then
    echo "ok: $_ml_dst"
    return 0
  fi

  if [ -e "$_ml_dst" ] || [ -L "$_ml_dst" ]; then
    if [ "$FORCE" = "1" ]; then
      echo "  remove: $_ml_dst (--force)"
      run rm -rf "$_ml_dst"
    else
      backup "$_ml_dst"
    fi
  fi

  echo "link: $_ml_dst -> $_ml_src"
  run ln -s "$_ml_src" "$_ml_dst"
}

# Link every dotfile in bash/ into $HOME.
echo "Linking dotfiles from $REPO_DIR/bash into $HOME"
for _f in "$REPO_DIR"/bash/.[!.]*; do
  make_link "$_f" "$HOME/$(basename "$_f")"
done
# The repo-root .gitignore doubles as the global one (~/.gitconfig points
# core.excludesfile at ~/.gitignore).
make_link "$REPO_DIR/.gitignore" "$HOME/.gitignore"

# ~/.config items: config/<name> in the repo links to ~/.config/<name>.
run mkdir -p "$HOME/.config"
make_link "$REPO_DIR/config/starship.toml" "$HOME/.config/starship.toml"

# ~/.gitconfig is copied, not linked, and only created when missing, so
# the name/email set below live in the copy and never get committed.
if [ -e "$HOME/.gitconfig" ] || [ -L "$HOME/.gitconfig" ]; then
  echo "ok: ~/.gitconfig already exists, leaving it alone"
else
  echo "copy: ~/.gitconfig"
  run cp "$REPO_DIR/.gitconfig" "$HOME/.gitconfig"
fi

if command -v git >/dev/null 2>&1; then
  if [ "$DRY_RUN" = "1" ]; then
    echo "would check git user.name/user.email and prompt if unset"
  else
    _email=$(git config --global --get user.email || true)
    _name=$(git config --global --get user.name || true)
    if [ -z "$_email" ] && [ -t 0 ]; then
      printf "Git E-mail? "
      read -r _email
    fi
    if [ -z "$_name" ] && [ -t 0 ]; then
      printf "Git Name? "
      read -r _name
    fi
    [ -n "$_email" ] && git config --global user.email "$_email"
    [ -n "$_name" ] && git config --global user.name "$_name"
    if [ -z "$_email" ] || [ -z "$_name" ]; then
      echo "Note: git identity incomplete; set it later with git config --global user.name/user.email"
    fi
  fi
else
  echo "Note: git not found, skipping git identity setup"
fi

# Optional: Vundle + plugins. Needs network, git, and vim.
if [ "$DO_VIM" = "1" ]; then
  if ! command -v git >/dev/null 2>&1 || ! command -v vim >/dev/null 2>&1; then
    echo "--vim needs both git and vim installed; skipping" >&2
  else
    _bundle="$HOME/.vim/bundle"
    # The old layout cloned Vundle to bundle/vundle; the current one
    # (and ~/.vimrc) expects bundle/Vundle.vim.
    if [ -d "$_bundle/vundle" ] && [ ! -e "$_bundle/Vundle.vim" ]; then
      echo "Renaming old bundle/vundle to bundle/Vundle.vim"
      run mv "$_bundle/vundle" "$_bundle/Vundle.vim"
    fi
    if [ ! -d "$_bundle/Vundle.vim" ]; then
      run mkdir -p "$_bundle"
      run git clone https://github.com/VundleVim/Vundle.vim.git "$_bundle/Vundle.vim"
    else
      echo "ok: Vundle already installed"
    fi
    # ~/.vimrc uses `silent! colorscheme`, so this runs fine before the
    # plugin providing the colorscheme exists.
    echo "Installing vim plugins..."
    run vim -n -i NONE +PluginInstall +qall
  fi
fi

if [ -n "$BACKUP_DIR" ] && [ "$DRY_RUN" != "1" ]; then
  echo "Replaced files were backed up to $BACKUP_DIR"
fi

# This script runs as a subprocess, so it cannot update your current
# shell; say what to do instead of pretending otherwise.
case "${SHELL:-}" in
  */bash) ;;
  *) echo "Note: your login shell is ${SHELL:-unknown}; these are bash dotfiles -- run 'bash' or 'chsh -s /bin/bash' to use them by default" ;;
esac
if ! command -v starship >/dev/null 2>&1; then
  echo "Note: starship not found, the built-in prompt in ~/.bash_prompt will be used"
fi
echo "Done. Open a new terminal, or run: source ~/.bashrc"
