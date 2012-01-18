" File:     pydocstring.vim
" Author:   Shinya Ohyanagi <sohyanagi@gmail.com>
" Version:  0.0.1
" WebPage:  http://github.com/heavenshell/vim-pydocstriong/
" Description: Generate Python docstring to your Python script file.
" License: BSD, see LICENSE for more details.

if exists('g:loaded_pydocstring')
  finish
endif
let g:loaded_pydocstring = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=0 -complete=customlist,pydocstring#insert Pydocstring call pydocstring#insert()

nnoremap <silent> <Plug>(pydocstring) :call pydocstring#insert()<CR>
nmap <silent> <C-l> <Plug>(pydocstring)

let &cpo = s:save_cpo
unlet s:save_cpo
