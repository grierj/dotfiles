set nocompatible        " Use Vim defaults (much better!)

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Vundles
Bundle 'gmarik/vundle'
Bundle 'jamessan/vim-gnupg'
Bundle 'fatih/vim-go'
Bundle 'seveas/bind.vim'
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-vividchalk'
Bundle 'vim-ruby/vim-ruby'
Bundle 'hdima/python-syntax'
Bundle 'wting/rust.vim'
Bundle 'elzr/vim-json'
Bundle 'thoughtbot/vim-rspec'
Bundle 'tpope/vim-rvm'
Bundle 'tpope/vim-unimpaired'
Bundle 'tpope/vim-markdown'
Bundle 'vim-scripts/confluencewiki.vim'
Bundle 'jaxbot/semantic-highlight.vim'
Bundle 'scrooloose/nerdtree'
Bundle 'scrooloose/nerdcommenter'

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
