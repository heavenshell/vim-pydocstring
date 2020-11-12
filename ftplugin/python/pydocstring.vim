" File:     pydocstring.vim
" Author:   Shinya Ohyanagi <sohyanagi@gmail.com>
" Version:  2.3.4
" WebPage:  http://github.com/heavenshell/vim-pydocstriong/
" Description: Generate Python docstring to your Python script file.
" License: BSD, see LICENSE for more details.

let s:save_cpo = &cpo
set cpo&vim

" version check
if !has('nvim') && (!has('channel') || !has('job'))
  echoerr '+channel and +job are required for pydocstring.vim'
  finish
endif

command! -nargs=0 -range=0 -complete=customlist,pydocstring#insert Pydocstring call pydocstring#insert(<q-args>, <count>, <line1>, <line2>)
command! -nargs=0 -complete=customlist,pydocstring#format PydocstringFormat call pydocstring#format()

if !exists('g:pydocstring_enable_mapping')
  let g:pydocstring_enable_mapping = 1
endif

if g:pydocstring_enable_mapping == 1 || hasmapto('<Plug>(pydocstring)')
  nnoremap <silent> <buffer> <Plug>(pydocstring) :call pydocstring#insert()<CR>
  if !hasmapto('<Plug>(pydocstring)')
    nmap <silent> <C-l> <Plug>(pydocstring)
  endif
endif

let &cpo = s:save_cpo
unlet s:save_cpo
