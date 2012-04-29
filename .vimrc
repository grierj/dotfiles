" Vim Pathogen
" in ~/.vim/autoload run:
" wget https://raw.github.com/tpope/vim-pathogen/HEAD/autoload/pathogen.vim
" in ~/.vim/bundle run:
" git clone git://github.com/klen/python-mode.git
" git clone git://github.com/tpope/vim-fugitive.git
" or any other module that loads with pathogen
call pathogen#infect()
call pathogen#helptags()

filetype plugin indent on

if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
   set fileencodings=ucs-bom,utf-8,latin1
endif

set nocompatible        " Use Vim defaults (much better!)
set bs=indent,eol,start         " allow backspacing over everything in insert mode
"set ai                 " always set autoindenting on
set smartindent     " cindent
"set backup             " keep a backup file
set viminfo='20,\"50    " read/write a .viminfo file, don't store more
                        " than 50 lines of registers
set history=50          " keep 50 lines of command line history
set ruler               " show the cursor position all the time
set tabstop=4       " set a hard tabstop
set shiftwidth=4    " set the size of an indent
set softtabstop=4   " set a soft tabstop
set expandtab       " turn tabs into spaces
set smarttab

" don't expand tabs for makefiles
autocmd FileType make setlocal noexpandtab

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
set pastetoggle=<F2>
set showmode

