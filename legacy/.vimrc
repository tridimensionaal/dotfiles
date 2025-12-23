set nocompatible              " required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

"vimtex"
Plugin 'lervag/vimtex'

"to see files
Plugin 'preservim/nerdtree'

"
Plugin 'itchyny/lightline.vim'

"para autocompletar el código (para python y c++)
Bundle 'Valloric/YouCompleteMe'

"css color
Plugin 'ap/vim-css-color'

"emmet-vim is a vim plug-in which provides support for expanding abbreviations similar to emmet.
Plugin 'mattn/emmet-vim'

"
Plugin 'valloric/MatchTagAlways'

"Plugin for python pep8
Plugin 'nvie/vim-flake8'

"
Plugin 'christoomey/vim-tmux-navigator'

" indentation lines
Plugin 'Yggdroot/indentLine'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" Uncomment the next line to make Vim more Vi-compatible
" NOTE: debian.vim sets 'nocompatible'.  Setting 'compatible' changes numerous
" options, so any other options should be set AFTER setting 'compatible'.
"set compatible

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
if has("syntax")
  syntax on
endif

" If using a dark background within the editing area and syntax highlighting
" turn on this option as well
"set background=dark


" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Uncomment the following to have Vim load indentation rules and plugins
" according to the detected filetype.
if has("autocmd")
  filetype plugin indent on
endif

if (&term == 'xterm-256color')
    set t_Co=256
endif


"" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
set exrc
set relativenumber 
set nu
set hidden
set noerrorbells 
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent  
set nowrap
set incsearch 
set scrolloff=8
set colorcolumn=80
set signcolumn=yes

set showcmd		    " Show (partial) command in status line.
set showmatch		" Show matching brackets.
"set ignorecase		" Do case insensitive matching
set smartcase		" Do smart case matching
set autowrite		" Automatically save before commands like :next and :make
set foldmethod=indent
set ruler
set laststatus=2
set backspace=indent,eol,start
set noswapfile
set clipboard+=unnamed
set background=dark

" Source a global configuration file if available
if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif


"indent"
autocmd FileType html setl tabstop=2|setl shiftwidth=2|setl softtabstop=2
autocmd FileType htmldjango setl tabstop=2|setl shiftwidth=2|setl softtabstop=2
autocmd FileType css setl tabstop=2|setl shiftwidth=2|setl softtabstop=2

"activar los splits?
set splitbelow
set splitright

"split navigations
"nnoremap lo que hace es que, dada una tecla bindeada, le cambia el bindeo, la parte de no se refiera que se está trabajando en modo normal
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

"ajuste para nerdtree
"ignorar archivos formato .pyc
let NERDTreeIgnore=['\.pyc$', '\~$']

"ajuste para nerdtree
"ignorar archivos formato .cpp.out
let NERDTreeIgnore=['\.cpp.out*$', '\~$']
let NERDTreeIgnore=['\.out*$', '\~$']

"ignorar archivos formato latex
let NERDTreeIgnore=['\.aux$', '\.fdb_latexmk$', '\.fls$', '\.lof$', '\.log$', '\.lol$', '\.lot$', '\.pdf$', '\.synctex.gz$', '\.toc$']

"vimtex"
let g:tex_flavor = 'latex'

"Enable emmet just for html/css
let g:user_emmet_install_global = 0
autocmd FileType html,css,htmldjango EmmetInstall

"Emmet shortcuts
let g:user_emmet_mode='n'
let g:user_emmet_leader_key=','


"blacklist you complete me"
let g:ycm_filetype_blacklist = {'html': 1, 'css': 1}


"Autocomplete html, css
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType htmldjango set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS

"binds
map <C-n> <Esc>:NERDTreeToggle<CR>
map <F9> <Esc>:w<CR>:!clear;./%<CR>
nnoremap <C-c> :!clear;g++ -std=c++11 "%" -Wall -g -o "%".out && ./"%".out<CR>
inoremap <C-x> <C-x><C-o>

" vim-flake8
autocmd BufWritePost *.py call Flake8()

"
let g:indentLine_setConceal = 0
