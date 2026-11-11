# Consolidated zsh configuration for macOS, ported from the bash dotfiles
# in this repo (../bash/): .bash_profile + .bashrc + .exports + .aliases +
# .functions + .bash_prompt, merged into one file.
#
# Plain zsh, no framework (no oh-my-zsh/antidote/zinit), and no starship —
# the prompt is a native zsh prompt that mirrors the bash fallback:
# user@host:path with a git segment ("*" unstaged, "+" staged, "%"
# untracked, "$" stashed).
#
# Symlink this into $HOME (e.g. ln -s ~/git/dotfiles/zsh/.zshrc ~/.zshrc),
# or add it to bootstrap.sh if you like. Per-machine settings that don't
# belong in git go in ~/.zshrc.local, which is sourced at the bottom.
#
# Everything that needs a tool that may not be installed (mise, fzf,
# atuin, zoxide) is guarded, so this file is safe on a bare macOS install.

[[ -o interactive ]] || return

# ---------------------------------------------------------------------------
# Environment and PATH (from .exports/.bash_profile, macOS-only)
# Zsh sources this file for both login and non-login interactive shells,
# so the environment lives here. (Non-interactive shells read ~/.zshenv;
# if you need these PATH entries there too, mirror them or symlink this
# file — the PATH helpers below are duplicate-safe.)
# ---------------------------------------------------------------------------

# PATH helpers: add a directory once, only if it exists.
path_prepend() {
  case ":${PATH}:" in
    *":$1:"*) ;;
    *) [ -d "$1" ] && PATH="$1:$PATH" ;;
  esac
}
path_append() {
  case ":${PATH}:" in
    *":$1:"*) ;;
    *) [ -d "$1" ] && PATH="$PATH:$1" ;;
  esac
}

# Prefer US English with UTF-8, but only if that locale actually exists on
# this machine. Deliberately do not set LC_ALL.
if locale -a 2>/dev/null | grep -qix 'en_US\.utf-\?8'; then
  export LANG="en_US.UTF-8"
fi

# Make vim the default editor
export EDITOR="vim"
# Don't clear the screen after quitting a manual page
MANPAGER="less -X"; export MANPAGER

# Larger history (bash used HISTSIZE=32768 with histappend + per-command
# `history -a`; 32768 entries with immediate incremental append is the
# zsh equivalent). EXTENDED_HISTORY replaces HISTTIMEFORMAT.
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=32768
export SAVEHIST=$HISTSIZE
setopt APPEND_HISTORY       # append, don't overwrite
setopt INC_APPEND_HISTORY   # write each command as it runs (like `history -a`)
setopt EXTENDED_HISTORY     # save timestamps
setopt HIST_IGNORE_SPACE    # don't record commands starting with a space
setopt HIST_IGNORE_ALL_DUPS # erase older duplicates (erasedups)
setopt HIST_FIND_NO_DUPS    # don't show duplicates when searching

# GPG terminal (only when we actually have one; `tty` prints junk otherwise)
if [ -t 1 ]; then
  GPG_TTY=$(tty 2>/dev/null)
  [ -n "$GPG_TTY" ] && export GPG_TTY
fi

# Homebrew first (either prefix). Note: macOS's /etc/zprofile runs
# path_helper, which re-sorts PATH; re-prepending here wins because .zshrc
# is read after it.
if [ -d /opt/homebrew/bin ] || [ -d /opt/homebrew/sbin ]; then
  path_prepend /opt/homebrew/bin
  path_prepend /opt/homebrew/sbin
fi

# MacPorts, only if Homebrew isn't installed
if [ ! -f /usr/local/bin/brew ] && [ ! -f /opt/homebrew/bin/brew ]; then
  path_prepend /opt/local/sbin
  path_prepend /opt/local/bin
fi

# /usr/local/sbin (Homebrew on Intel Macs, misc)
path_prepend /usr/local/sbin

# Go, if installed from the upstream tarball
path_prepend /usr/local/go/bin

# Default GOPATH and its bin directory
export GOPATH=$HOME/godev
path_prepend "$GOPATH/bin"

# mise shims, so non-interactive shells find mise-managed tools even
# without `mise activate`
path_prepend "$HOME/.local/share/mise/shims"

# Pyenv shims, if pyenv is still around on this machine
path_prepend "$HOME/.pyenv/shims"

# Local bin directories
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"

# Rust, if installed via rustup (the env file is POSIX-sh and zsh-safe)
[ -r "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# LM Studio CLI (lms)
path_append "$HOME/.lmstudio/bin"

# Grok CLI
path_prepend "$HOME/.grok/bin"

# Startup script for the python REPL
export PYTHONSTARTUP=$HOME/.pythonrc

# ---------------------------------------------------------------------------
# Shell options and key bindings (from .bashrc)
# ---------------------------------------------------------------------------

# Case-insensitive globbing
setopt NO_CASE_GLOB
# Type a directory name to cd into it
setopt AUTO_CD
# Correct typos in commands/paths (zsh's equivalent of cdspell for cd)
setopt CORRECT
# ** works natively in zsh; no globstar option needed.

# Up/down arrow: prefix history search (the .inputrc equivalent).
# atuin, if installed, handles Ctrl-R instead.
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[OA' history-search-backward
bindkey '^[OB' history-search-forward

# ---------------------------------------------------------------------------
# Completion (from .bashrc's bash-completion/git-completion blocks,
# translated to zsh's native completion system)
# ---------------------------------------------------------------------------

autoload -Uz compinit && compinit

# Case-insensitive matching for completions
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
# Take a plain list menu on conflicts, no forced single-column layout
zstyle ':completion:*' menu select

# SSH/scp/sftp hostnames: zsh's _ssh parses ~/.ssh/config (and /etc/hosts,
# known_hosts) natively, so the bash `complete -W "$(grep ^Host ...)"`
# hack has no equivalent here.
# `killall` similarly completes running process names natively.

# Git completion for the `g` alias (the `g=git` alias is in the aliases
# section below; compdef wires `g` to git's completer, like
# `__git_complete g __git_main` in bash).
compdef g=git

# ---------------------------------------------------------------------------
# Aliases (from .aliases, macOS-only)
# ---------------------------------------------------------------------------

# Easier navigation: .., ..., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ~="cd ~" # `cd` is probably faster to type though
alias -- -="cd -"

# Shortcuts
alias d="cd ~/Development"
alias v="vim"
alias g="git"
alias b="bundle"
alias be="bundle exec"
alias prp="pipenv run python"
alias o="open"
alias oo="open ."

# List all files in long format (-G is "color" on BSD/macOS ls)
alias l="ls -l"

# List all files in long format, including dot files
alias la="ls -la"

# List only directories
alias lsd='ls -l | grep "^d"'

# Always use color output for `ls`
alias ls="command ls -G"
export CLICOLOR=1
# Dark mode colors
export LSCOLORS=GxFxCxDxBxegedabagaced

# Update installed packages with Homebrew (MacPorts if brew isn't installed)
if command -v brew >/dev/null 2>&1; then
  alias update='brew update && brew upgrade'
else
  alias update='sudo port selfupdate && sudo port -u upgrade outdated'
fi

# (`open` is native on macOS, so the xdg-open fallback is gone.)

# Eject the optical drive
alias eject='drutil eject'

# Install/update vim plugins (Vundle)
alias vinstall='vim -c "PluginInstall" -c "q" -c "q"'
alias vupdate='vim -c "PluginUpdate" -c "q" -c "q"'
alias vclean='vim -c "PluginClean!" -c "q" -c "q"'

# IP addresses (Wi-Fi is en0 on modern Macs; the bash files used en1)
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print \$1'"
alias ipsort="sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4"

# Flush Directory Service cache
alias flush="dscacheutil -flushcache"

# View HTTP traffic (en0 = Wi-Fi on modern Macs)
alias sniff="sudo ngrep -d 'en0' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i en0 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

# Trim new lines and copy to clipboard
alias c="tr -d '\n' | pbcopy"

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# File size
alias fs="stat -f \"%z bytes\""

# ROT13-encode text. Works for decoding, too! ;)
alias rot13='tr a-zA-Z n-za-mN-ZA-M'

# Empty the Trash on all mounted volumes and the main HDD
# Also, clear Apple's System Logs to improve shell startup speed
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"

# Show/hide hidden files in Finder
alias show="defaults write com.apple.Finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.Finder AppleShowAllFiles -bool false && killall Finder"

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# URL-encode strings
alias urlencode='python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1]))"'

# Disable Spotlight
alias spotoff="sudo mdutil -a -i off"
# Enable Spotlight
alias spoton="sudo mdutil -a -i on"

# PlistBuddy alias, because sometimes `defaults` just doesn't cut it
alias plistbuddy="/usr/libexec/PlistBuddy"

# One of @janmoesen's ProTip™s
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
  alias "$method"="lwp-request -m '$method'"
done
unset method

# Stuff I never really use but cannot delete either because of http://xkcd.com/530/
alias stfu="osascript -e 'set volume output muted true'"
alias pumpitup="osascript -e 'set volume 10'"
# I have some overly loud USB headphones
alias softer="osascript -e 'set volume 0.05'"

# (The bash `fuck='sudo $(history -p !!)'` alias is dropped: bash's
# history-expansion syntax doesn't exist in zsh. Use `sudo !!` in zsh.)

# Docker cleanup aliases
alias docker_clean_images='docker rmi $(docker images -a --filter=dangling=true -q)'
alias docker_clean_ps='docker rm $(docker ps --filter=status=exited --filter=status=created -q)'

# Terraform helpers
alias tfplan='rm -rf .terraform ~/.terraform.d && mq terraform init && mq terraform plan -- -out tfplan'
alias tfpb='mq terraform show -- -no-color tfplan | pbcopy'

# Intellij Helpers
alias idea='pushd ~/intellij; /usr/local/bin/idea; popd'

# ---------------------------------------------------------------------------
# Functions (from .functions)
# ---------------------------------------------------------------------------

# Create a new directory and enter it. (cd takes one argument, so cd into
# the last directory created when several are given.)
md() {
  local last="${@: -1}"
  mkdir -p "$@" && cd -- "$last" || return
}

# Create a data URL from an image (works for other file types too, if you tweak the Content-Type afterwards)
dataurl() {
  echo "data:image/${1##*.};base64,$(openssl base64 -in "$1")" | tr -d '\n'
}

# Start an HTTP server from a directory, optionally specifying the port
server() {
  local port="${1:-8000}"
  open "http://localhost:${port}/"
  python3 -m http.server "$port"
}

# Test if HTTP compression (RFC 2616 + SDCH) is enabled for a given URL.
# Send a fake UA string for sites that sniff it instead of using the Accept-Encoding header.
httpcompression() {
  encoding="$(curl -LIs -H 'User-Agent: Mozilla/5 Gecko' -H 'Accept-Encoding: gzip,deflate,compress,sdch' "$1" | grep '^Content-Encoding:')" && echo "$1 is encoded using ${encoding#* }" || echo "$1 is not using any encoding"
}

# Gzip-enabled `curl`
gurl() {
  curl -sH "Accept-Encoding: gzip" "$@" | gunzip
}

# Syntax-highlight JSON strings or files
json() {
  if [ -p /dev/stdin ]; then
    # piping, e.g. `echo '{"foo":42}' | json`
    python3 -mjson.tool | pygmentize -l javascript
  else
    # e.g. `json '{"foo":42}'`
    python3 -mjson.tool <<< "$*" | pygmentize -l javascript
  fi
}

# All the dig info
digga() {
  dig +nocmd "$1" any +multiline +noall +answer
}

# Escape UTF-8 characters into their 3-byte format
escape() {
  # split xxd's one-byte-per-line output on newlines (zsh does not
  # word-split unquoted variables)
  local bytes=("${(f)$(printf '%s' "$*" | xxd -p -c1 -u)}")
  printf '\\x%s' "${bytes[@]}"
  echo # newline
}

# Decode \x{ABCD}-style Unicode escape sequences
unidecode() {
  perl -e "binmode(STDOUT, ':utf8'); print \"$*\""
  echo # newline
}

# Get a character's Unicode code point
codepoint() {
  perl -e "use utf8; print sprintf('U+%04X', ord(\"$*\"))"
  echo # newline
}

servedir() {
  port="${1:-8000}"
  mongoose -listening_port "$port"
}

# Replace the ssh hostkey in your known_hosts file
rekey() {
  hostname=$1
  if [ -z "$hostname" ]; then
    echo "Usage: rekey <hostname>"
    return
  fi
  ssh-keygen -R "$hostname"
  ssh-keyscan "$hostname" >> ~/.ssh/known_hosts
}

pyenv-init() {
  export PATH=$HOME/.pyenv/shims:$PATH
  eval "$(pyenv init -)"
}

ghpr() {
  github_url=$(git remote -v | awk '/fetch/{print $2}' | sed -Ee 's#(git@|git://)#https://#' -e 's@com:@com/@' -e 's%\.git$%%' | awk '/github/')
  branch_name=$(git symbolic-ref HEAD | cut -d"/" -f 3,4)
  pr_url=$github_url"/compare/$branch_name?expand=1"
  open "$pr_url"
}

sneknem() {
  chars=4
  if [ -n "$1" ]; then
    chars=$1
  fi
  python3 -c "import string; import random; print(''.join([ random.choice(string.ascii_lowercase) for _ in range(int(${chars})) ]))"
}

# ---------------------------------------------------------------------------
# Optional tool integrations (from .bashrc): use them if installed.
# The _dot_* guards make re-sourcing this file a no-op instead of stacking
# duplicate hooks.
# ---------------------------------------------------------------------------

# mise (replaces the asdf/rbenv/pyenv/jenv blocks)
if command -v mise >/dev/null 2>&1 && [ -z "${_dot_mise:-}" ]; then
  eval "$(mise activate zsh)"
  _dot_mise=1
fi

# fzf key bindings (Ctrl-T, Ctrl-R fallback, Alt-C) and completion.
# fzf >= 0.48 supports `fzf --zsh`; otherwise source the Homebrew shell
# directory directly.
if command -v fzf >/dev/null 2>&1 && [ -z "${_dot_fzf:-}" ]; then
  if fzf --zsh >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
  else
    for _fz in /opt/homebrew/opt/fzf/shell /usr/local/opt/fzf/shell; do
      [ -r "$_fz/completion.zsh" ] && source "$_fz/completion.zsh"
      [ -r "$_fz/key-bindings.zsh" ] && source "$_fz/key-bindings.zsh"
    done
    unset _fz
  fi
  _dot_fzf=1
fi

# zoxide: smarter `z` directory jumping (leaves `cd` alone)
if command -v zoxide >/dev/null 2>&1 && [ -z "${_dot_zoxide:-}" ]; then
  eval "$(zoxide init zsh)"
  _dot_zoxide=1
fi

# atuin: searchable history on Ctrl-R. Up-arrow keeps the prefix history
# search set up above, hence --disable-up-arrow.
if command -v atuin >/dev/null 2>&1 && [ -z "${_dot_atuin:-}" ]; then
  eval "$(atuin init zsh --disable-up-arrow)"
  _dot_atuin=1
fi

# ---------------------------------------------------------------------------
# Prompt (native only, mirrors .bash_prompt):
# user@host:path with a git segment. Upgrades a plain "xterm" TERM to
# xterm-256color when available, and uses 256-color escapes when the
# terminal supports them.
# ---------------------------------------------------------------------------

# Only upgrade a plain "xterm"; leave modern terminals (ghostty, kitty,
# alacritty, *-256color, ...) with the TERM they set for themselves.
if [[ $COLORTERM = (gnome-*|truecolor) && $TERM = xterm ]] && infocmp xterm-256color >/dev/null 2>&1; then
  export TERM=xterm-256color
elif [[ $TERM = xterm ]] && infocmp xterm-256color >/dev/null 2>&1; then
  export TERM=xterm-256color
fi

# Git segment: "(%s)" with * unstaged, + staged, % untracked, $ stashed
# (GIT_PS1_SHOW* equivalents, folded in by hand). Uses one porcelain call.
git_segment=""
precmd() {
  typeset -g git_segment=""
  command -v git >/dev/null 2>&1 || return
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

  local branch
  branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null) || return

  local staged=0 unstaged=0 untracked=0 flags=""
  local porcelain=$(git status --porcelain=v1 --untracked-files=normal 2>/dev/null)
  local line first second
  while IFS= read -r line; do
    first="${line[1,1]}"
    second="${line[2,2]}"
    if [[ "$first" == '?' ]]; then
      untracked=1
    else
      [[ "$first" =~ '[MADRC]' ]] && staged=1
      [[ "$second" =~ '[MADRC]' ]] && unstaged=1
    fi
  done <<< "$porcelain"
  (( unstaged )) && flags+="*"
  (( staged )) && flags+="+"
  (( untracked )) && flags+="%"
  git rev-parse -q --verify refs/stash >/dev/null 2>&1 && flags+="\$"

  git_segment=" %F{172}(${branch}${flags})%f"
}

setopt PROMPT_SUBST
PS1='%B%F{9}%n%f%b@%F{129}%m%f:%F{83}%~%f${git_segment}%(!.#.$) '
PS2='%F{172}=> %f'

# ---------------------------------------------------------------------------
# Per-machine settings that don't belong in git: ~/.zshrc.local
# ---------------------------------------------------------------------------

[ -r "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
