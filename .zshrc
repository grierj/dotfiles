whereami() {
  SOURCE="${BASH_SOURCE[0]}"
  while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  done
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  echo $DIR
}

# Load ~/.extra, ~/.bash_prompt, ~/.exports, ~/.aliases and ~/.functions
# ~/.extra can be used for settings you don’t want to commit
for file in $(whereami)/.{extra,zsh_prompt,exports,aliases,functions}; do
  [ -r "$file" ] && source "$file"
done
unset file

# Case-insensitive globbing (used in pathname expansion)
unsetopt CASE_GLOB

# Append to the history file, rather than overwriting it
HISTFILE=~/.zsh_history     #Append history to the history file (no overwriting)
#Where to save history to disk
setopt    appendhistory
#Share history across terminalsry
setopt    sharehistory
#Immediately append to the history file, not just when a term is killed
setopt    incappendhistory

# Autocorrect typos in path names when using `cd`
ENABLE_CORRECTION="true"

# Prefer US English and use UTF-8
export LC_ALL="en_US.UTF-8"
export LANG="en_US"

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

# Use RVM if it exists
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
# Use rbenv if it exists and rvm didn't init
if [ -z $rvm_path ]; then
  if which rbenv > /dev/null 2>&1; then eval "$(rbenv init -)"; fi
fi

# Use pyenv if it exists
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

# Source a local file for things that shouldn't be checked into git
[[ -f "$HOME/.bash.local" ]] && source "$HOME/.bash.local"
