" Insert Docstring.
" Author:      Shinya Ohyanagi <sohyanagi@gmail.com>
" WebPage:     http://github.com/heavenshell/vim-pydocstriong/
" Description: Generate Python docstring to your Python script file.
" License:     BSD, see LICENSE for more details.
" NOTE:        This module is heavily inspired by php-doc.vim and
"              sonictemplate.vim
let s:save_cpo = &cpo
set cpo&vim

let g:pydocstring_templates_dir = get(g:, 'pydocstring_templates_dir', '')
let g:pydocstring_formatter = get(g:, 'pydocstring_formatter', 'sphinx')

function! s:insert_docstring(docstrings, insertpos) abort
  let paste = &g:paste
  let &g:paste = 1

  silent! execute 'normal! ' . a:insertpos . 'G$'
  let current_pos = line('.')
  " If current position is bottom, add docstring below.
  if a:insertpos == current_pos
    silent! execute 'normal! O' . a:docstrings['docstring']
  else
    silent! execute 'normal! o' . a:docstrings['docstring']
  endif

  let &g:paste = paste
  silent! execute 'normal! ' . a:insertpos . 'G$'
endfunction

function! s:callback(ch, msg, indent, insertpos) abort
  let docstrings = json_decode(a:msg)
  call s:insert_docstring(docstrings[0], a:insertpos + 1)
endfunction

let s:results = []

function! s:format_callback(ch, msg, indent, insertpos) abort
  call add(s:results, a:msg)
endfunction

function! s:exit_callback(ch, msg) abort
  if len(s:results)
    let view = winsaveview()
    silent execute '% delete'
    call setline(1, s:results)
    call winrestview(view)
    let s:results = []
  endif
  echomsg reltimestr(reltime(s:start_time))
endfunction

function! s:execute(cmd, lines, indent, insertpos, callback) abort
  if exists('s:job') && job_status(s:job) != 'stop'
    call job_stop(s:job)
  endif

  let s:job = job_start(a:cmd, {
    \ 'callback': {c, m -> a:callback(c, m, a:indent, a:insertpos)},
    \ 'exit_cb': {c, m -> s:exit_callback(c, m)},
    \ 'in_mode': 'nl',
    \ })

  let channel = job_getchannel(s:job)
  if ch_status(channel) ==# 'open'
    call ch_sendraw(channel, a:lines)
    call ch_close_in(channel)
  endif
endfunction

function! s:create_cmd(style) abort
  let cmd = printf(
    \ 'lib/doq --style=%s --formatter=%s --indent=%s',
    \ a:style,
    \ g:pydocstring_formatter,
    \ &softtabstop
    \ )
  if g:pydocstring_templates_dir !=# ''
    let cmd = printf('%s --template_path=%s', cmd, g:pydocstring_templates_dir)
  endif

  return cmd
endfunction

function! pydocstring#format() abort
  let s:start_time = reltime()
  let bufnum = bufnr('%')
  let lines = join(getbufline(bufnum, 1, '$'), "\n") . "\n"

  let cmd = s:create_cmd('string')
  let indent = &softtabstop
  let insertpos = line('.')
  call s:execute(cmd, lines, indent, insertpos, function('s:format_callback'))
endfunction

function! pydocstring#insert() abort
  let s:start_time = reltime()
  let pos = getpos('.')

  let line = getline('.')
  let indent = matchstr(line, '^\(\s*\)')

  let space = repeat(' ', &softtabstop)
  if len(indent) == 0
    let indent = space
  else
    let indent = indent . space
  endif

  let startpos = line('.')
  let insertpos = search(')\(.*\):')
  call setpos('.', pos)

  let lines = join(getline(startpos, insertpos), "\n")
  let lines = printf("%s\n%s%s", lines, indent, 'pass')

  let cmd = s:create_cmd('json')
  call s:execute(cmd, lines, indent, insertpos, function('s:callback'))
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
