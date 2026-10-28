# Interactive bash configuration. Login shells reach this via
# ~/.bash_profile; non-login interactive shells read it directly.
# Everything here is interactive-only, and anything that needs a tool that
# may not be installed (mise, starship, fzf, atuin, zoxide) is guarded, so
# this file is safe on a bare Linux or macOS install.
# shellcheck disable=SC1090,SC1091

[[ $- == *i* ]] || return

# Where this file's real (post-symlink) directory is, so the split config
# files can be loaded from the repo rather than relying on $HOME links.
whereami() {
  local source dir
  source="${BASH_SOURCE[0]}"
  while [ -h "$source" ]; do
    dir="$(cd -P "$(dirname "$source")" && pwd)"
    source="$(readlink "$source")"
    [[ $source != /* ]] && source="$dir/$source"
  done
  cd -P "$(dirname "$source")" && pwd
}

# Environment/PATH (idempotent; login shells already loaded it), then the
# fallback prompt, aliases, and functions. ~/.extra is for uncommitted
# per-machine settings.
for _file in "$(whereami)"/.{exports,extra,bash_prompt,aliases,functions}; do
  [ -r "$_file" ] && source "$_file"
done
unset _file
unset -f whereami

# Append to the history file rather than overwriting it, and write each
# command out as it runs so other shells/tmux panes pick it up.
shopt -s histappend
shopt -s cmdhist lithist 2>/dev/null
case ";${PROMPT_COMMAND};" in
  *";history -a;"*) ;;
  *) PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
esac

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob
# Autocorrect typos in path names when using `cd`
shopt -s cdspell
# Keep LINES/COLUMNS current after each command
shopt -s checkwinsize
# Bash 4+ niceties (silently skipped on macOS's stock bash 3.2):
# type a directory name to cd into it, correct completion typos, ** globbing
shopt -s autocd dirspell globstar 2>/dev/null

# Programmable completion. Arch loads this from /etc/bash.bashrc already;
# other distros and macOS (Homebrew) need it sourced here.
if ! declare -p BASH_COMPLETION_VERSINFO >/dev/null 2>&1; then
  for _bc in /usr/share/bash-completion/bash_completion \
             /etc/bash_completion \
             /opt/homebrew/etc/profile.d/bash_completion.sh \
             /usr/local/etc/profile.d/bash_completion.sh; do
    if [ -r "$_bc" ]; then
      # shellcheck disable=SC1090
      source "$_bc"
      break
    fi
  done
  unset _bc
fi

# Git completion, including for the `g` alias. bash-completion lazy-loads
# this, so load it explicitly where git ships it.
if ! declare -F __git_complete >/dev/null 2>&1; then
  for _gc in /usr/share/git/completion/git-completion.bash \
             /usr/share/bash-completion/completions/git \
             /opt/homebrew/etc/bash_completion.d/git-completion.bash \
             /usr/local/etc/bash_completion.d/git-completion.bash \
             /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash; do
    if [ -r "$_gc" ]; then
      # shellcheck disable=SC1090
      source "$_gc"
      break
    fi
  done
  unset _gc
fi
declare -F __git_complete >/dev/null 2>&1 && __git_complete g __git_main

# Tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

if [[ "$OSTYPE" =~ ^darwin ]]; then
  # Tab completion for `defaults read|write NSGlobalDomain`
  complete -W "NSGlobalDomain" defaults
  # `killall` completion for common apps
  complete -o "nospace" -W "Finder Dock Mail Safari SystemUIServer" killall
fi

# Grok CLI completion
[ -r "$HOME/.grok/completions/bash/grok.bash" ] && source "$HOME/.grok/completions/bash/grok.bash"

# --- Optional tool integrations, Omarchy-style: use them if installed ---
# The _dot_* guards (deliberately not exported) make re-sourcing ~/.bashrc
# a no-op instead of stacking duplicate PROMPT_COMMAND hooks.

# mise (replaces the asdf/rbenv/pyenv/jenv blocks from the zsh setup)
if command -v mise >/dev/null 2>&1 && [ -z "${_dot_mise:-}" ]; then
  eval "$(mise activate bash)"
  _dot_mise=1
fi

# fzf key bindings (Ctrl-T, Ctrl-R fallback, Alt-C) and completion
if command -v fzf >/dev/null 2>&1 && [ -z "${_dot_fzf:-}" ]; then
  if [ -r /usr/share/fzf/key-bindings.bash ]; then
    [ -r /usr/share/fzf/completion.bash ] && source /usr/share/fzf/completion.bash
    source /usr/share/fzf/key-bindings.bash
  else
    eval "$(fzf --bash 2>/dev/null)"
  fi
  _dot_fzf=1
fi

# zoxide: smarter `z` directory jumping (leaves `cd` alone)
if command -v zoxide >/dev/null 2>&1 && [ -z "${_dot_zoxide:-}" ]; then
  eval "$(zoxide init bash)"
  _dot_zoxide=1
fi

# atuin: searchable history on Ctrl-R. Up-arrow keeps .inputrc's
# prefix history search, hence --disable-up-arrow.
if command -v atuin >/dev/null 2>&1 && [ -z "${_dot_atuin:-}" ]; then
  eval "$(atuin init bash --disable-up-arrow)"
  _dot_atuin=1
fi

# starship prompt, if installed; otherwise the ~/.bash_prompt above stands.
# Keep this last so it can wrap PROMPT_COMMAND set up by everything else.
if command -v starship >/dev/null 2>&1 && [[ ${TERM:-} != "dumb" ]] && [ -z "${_dot_starship:-}" ]; then
  eval "$(starship init bash)"
  _dot_starship=1
fi
