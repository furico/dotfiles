scriptencoding utf-8
" Init {{{
function! s:add_bundle_path()
  let l:files = globpath(expand("~/.vim/bundle"), "*")
  for path in split(l:files, "\n")
    if isdirectory(path)
      execute "set rtp+=".path
    endif
    let l:after = path . "/after"
    if isdirectory(l:after)
      execute "set rtp+=".l:after
    endif
  endfor
endfunction
if has("vim_starting")
  call s:add_bundle_path()
endif
" }}}
" Basic {{{
set nocompatible
filetype plugin indent on
syntax enable
set hidden
set modelines=1
" }}}
" Searching {{{
set hlsearch
set ignorecase
set smartcase
set incsearch
" }}}
" Backups {{{
set nobackup
set nowritebackup
set noswapfile
set noundofile
" }}}
" Spaces & Tabs {{{
set shiftwidth=2
set tabstop=2
set expandtab
" }}}
" UI {{{
set number
set showcmd
"set cursorline
set list lcs=eol:$,tab:>-
set laststatus=2
set cmdheight=2
set statusline=%r%w%f%m%=[%{&fileformat}][%{&fileencoding}]%y[%3p%%][%3l:%-3c]
" }}}}
" Colors {{{
set t_Co=256
colorscheme desert
"colorscheme jellybeans
" }}}
" Keymaps {{{
let mapleader = "\<Space>"
nnoremap Y y$
noremap <CR> o<Esc>
nnoremap <silent> <Leader>w :update<CR>
nnoremap <silent> <Esc><Esc> :nohlsearch<CR>
nnoremap <Tab> <C-w><C-w>
nnoremap <S-Tab> <C-w>W
" }}}
" AutoGroups {{{
augroup vimrc
  autocmd!
  autocmd FileType vim nnoremap <buffer> <Leader>r :so%<CR>
augroup END
" }}}

" vim:foldmethod=marker
