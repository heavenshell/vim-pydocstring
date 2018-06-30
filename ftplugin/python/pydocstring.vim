" File:     pydocstring.vim
" Author:   Shinya Ohyanagi <sohyanagi@gmail.com>
" Version:  0.6.0
" WebPage:  http://github.com/heavenshell/vim-pydocstriong/
" Description: Generate Python docstring to your Python script file.
" License: BSD, see LICENSE for more details.

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=0 -buffer -complete=customlist,pydocstring#insert Pydocstring call pydocstring#insert()

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
