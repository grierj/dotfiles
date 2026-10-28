# dotfiles

Bash dotfiles for Linux (tuned for Omarchy) and, lightly, macOS.
Everything lives in `bash/` and gets symlinked into `$HOME`.

## Install on a new machine

Requires only bash and git (this is meant to be one of the first things
installed):

```sh
git clone <this repo> ~/git/dotfiles
cd ~/git/dotfiles
./bootstrap.sh --dry-run   # preview what would happen
./bootstrap.sh             # link everything, backing up replaced files
./bootstrap.sh --vim       # also install Vundle + vim plugins
```

Then open a new terminal (or `source ~/.bashrc`).

Bootstrap is idempotent: re-running it only relinks what's wrong.
Anything it replaces is moved to `~/dotbackup/<timestamp>/` unless
`--force` is given. It does not install packages and does not change
your login shell — on macOS, where the default shell is zsh, run
`chsh -s /bin/bash` yourself if you want these to load automatically.

`~/.gitconfig` is *copied*, not linked, and bootstrap only creates it if
missing, so your name/email (which it will prompt for if unset) never
gets committed back to this repo.

## Layout

- `.bash_profile` — login shells: locale, then sources `.bashrc` if interactive
- `.bashrc` — interactive shells: aliases, functions, completion, tools
- `.exports` — environment and PATH (sourced by both, duplicate-safe)
- `.bash_prompt` — fallback prompt with git status; replaced by starship
  when starship is installed
- `.aliases`, `.functions`, `.inputrc`, `.tmux.conf`, `.vimrc`, etc.
- `config/starship.toml` — linked to `~/.config/starship.toml`;
  `user@host:/full/path` layout matching the fallback prompt

Per-machine settings that don't belong in git go in `~/.bash.local`
(a file, or a directory of files) or `bash/.extra`.

## Optional tools

The shell config uses these when present and silently skips them when
not: [starship](https://starship.rs) (prompt), [mise](https://mise.jdx.dev)
(tool versions), [fzf](https://github.com/junegunn/fzf) and
[atuin](https://atuin.sh) (fuzzy/history search), and
[zoxide](https://github.com/ajeetdsouza/zoxide) (`z` directory jumping).
All of them ship with Omarchy.
