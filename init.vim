set nocompatible              " required
filetype off                  " required
"-------------------Settings-------------------
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
set splitbelow
set splitright
"----------------------------------------------


"-------------------Plugins-------------------
call plug#begin('~/.config/nvim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'nvie/vim-flake8'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
call plug#end()
"----------------------------------------------


"-------------------Config-------------------
" for html/rb files, 2 spaces
autocmd Filetype sql set tabstop=2 shiftwidth=2 expandtab

"-------------------CocConf-------------------
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
"----------------------------------------------

"-------------------Flake8-------------------
autocmd BufWritePost *.py call flake8#Flake8()
"----------------------------------------------

"-------------------lightline-------------------
let g:lightline = {
          \ 'colorscheme': 'wombat',
      \ }
"----------------------------------------------


"-------------------fugitive-------------------
nmap <leader>gs :G<CR>
"----------------------------------------------




"-------------------Binds-------------------
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

nnoremap <F9> <Esc>:w<CR>:!./%<CR>
nnoremap <C-c> :!clear;g++ -std=c++11 % -Wall -g -o %.out && ./%.out<CR>
inoremap <C-x> <C-x><C-o>
nnoremap <C-N> :Files <CR>

"----------------------------------------------




