# Login shell setup: environment and PATH.
# Interactive configuration lives in ~/.bashrc, which is sourced at the
# bottom of this file for interactive login shells (terminals on macOS,
# SSH logins on Linux). Non-login interactive shells read ~/.bashrc
# directly, and it pulls in ~/.exports itself.
# shellcheck disable=SC1090,SC1091

# Environment and PATH (also sourced by ~/.bashrc; the path helpers in
# ~/.exports are duplicate-safe, so loading it twice is harmless).
[ -r "$HOME/.exports" ] && source "$HOME/.exports"
# Fallbacks in case ~/.exports hasn't been linked yet
declare -F path_prepend >/dev/null 2>&1 || path_prepend() { [ -d "$1" ] && PATH="$1:$PATH"; }
declare -F path_append >/dev/null 2>&1 || path_append() { [ -d "$1" ] && PATH="$PATH:$1"; }

# (Locale handling lives in ~/.exports so non-login shells get it too.)

# Rust, if installed via rustup
[ -r "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# LM Studio CLI (lms)
path_append "$HOME/.lmstudio/bin"

# Grok CLI
path_prepend "$HOME/.grok/bin"

# Local settings that shouldn't be checked into git: either a single
# ~/.bash.local file or a directory of files to source.
if [ -d "$HOME/.bash.local" ]; then
  for _f in "$HOME"/.bash.local/*; do
    [ -f "$_f" ] && source "$_f"
  done
  unset _f
fi
[ -f "$HOME/.bash.local" ] && source "$HOME/.bash.local"

# Interactive login shells get the interactive config too.
if [[ $- == *i* ]] && [ -r "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
fi
