set nocompatible        " Use Vim defaults (much better!)

set rtp+=~/.vim/bundle/vundle/
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'jaxbot/semantic-highlight.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/nerdcommenter'
Plugin 'tpope/vim-vividchalk'
Plugin 'jamessan/vim-gnupg'
Plugin 'fatih/vim-go'
Plugin 'hdima/python-syntax'
Plugin 'elzr/vim-json'
Plugin 'tpope/vim-unimpaired'
Plugin 'tpope/vim-markdown'
Plugin 'hashivim/vim-terraform'
Plugin 'vim-scripts/confluencewiki.vim'
"Plugin 'seveas/bind.vim'
"Plugin 'tpope/vim-rails'
"Plugin 'vim-ruby/vim-ruby'
"Plugin 'thoughtbot/vim-rspec'
"Plugin 'tpope/vim-rvm'
"Plugin 'wting/rust.vim'
call vundle#end()
filetype plugin indent on

if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
   set fileencodings=ucs-bom,utf-8,latin1
endif

" Set leader key to space
let mapleader = ' '

" ensure ftdetect et al work by including this after the Vundle stuff
filetype plugin indent on

set bs=indent,eol,start        " allow backspacing over everything in insert mode
set ai                         " always set autoindenting on
set smartindent                " cindent
"set backup                     " keep a backup file
set viminfo='20,\"50           " read/write a .viminfo file, don't store more
                               " than 50 lines of registers
set history=50                 " keep 50 lines of command line history
set ruler                      " show the cursor position all the time
set tabstop=2                  " set a hard tabstop
set shiftwidth=2               " set the size of an indent
set softtabstop=2              " set a soft tabstop
set expandtab                  " turn tabs into spaces
set smarttab                   " use shiftwidth where appropriate for tabs
set smartcase                  " case-sensitive search if any caps
set list                       " show trailing whitespace
set listchars=tab:▸\ ,trail:▫  " visible characters for tabs and trailing
set laststatus=2               " always show statusline
set scrolloff=3                " show context above/below cursorline
set ruler                      " show where you are
set showcmd                    " show commands

" in case you forgot to sudo
cnoremap w!! %!sudo tee > /dev/null %


" Only do this part when compiled with support for autocommands
if has("autocmd")
  augroup redhat
  autocmd!
  " In text files, always limit the width of text to 78 characters
  autocmd BufRead *.txt set tw=78
  " When editing a file, always jump to the last cursor position
  autocmd BufReadPost *
  \ if line("'\"") > 0 && line ("'\"") <= line("$") |
  \   exe "normal! g'\"" |
  \ endif
  " don't write swapfile on most commonly used directories for NFS mounts or USB sticks
  autocmd BufNewFile,BufReadPre /media/*,/mnt/* set directory=~/tmp,/var/tmp,/tmp
  " start with spec file template
  autocmd BufNewFile *.spec 0r /usr/share/vim/vimfiles/template.spec
  augroup END

  " don't expand tabs for makefiles
  autocmd FileType make setlocal noexpandtab

  " 4 spaces for some languages
  autocmd Filetype rust setlocal ts=4 sts=4 sw=4
  autocmd Filetype python setlocal ts=4 sts=4 sw=4


endif
" Autoformat terraform files, this doesn't work if we autocmd it, but is
" restricted in the plugin to only terraform files anyhow
let g:terraform_align=1
let g:terraform_fmt_on_save=1

" Set go-vim to use goimports instead of gopls
let b:go_imports_mode = 'goimports'

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

if &term=="xterm"
     set t_Co=8
     set t_Sb=^[[4%dm
     set t_Sf=^[[3%dm
endif

" Don't wake up system with blinking cursor:
" http://www.linuxpowertop.org/known.php
let &guicursor = &guicursor . ",a:blinkon0"

" Set a C&P mode to F2, show that we're in that mode
nnoremap <F2> :set invpaste paste?<CR>
" Semantic coloring toggle
nnoremap <leader>s :SemanticHighlightToggle<CR>
" Nerd tree toggle
nnoremap <leader>n :NERDTreeToggle<CR>
set pastetoggle=<F2>
set showmode

" Python highlighting
let python_highlight_all = 1

"set background=dark
colorscheme vividchalk

"retab when saving files
fu! RetabOnSave()
    %retab!
endfunction

autocmd BufWritePre * :call RetabOnSave()
