" Insert Docstring.
" Last Change:  2013-12-14
" Maintainer:   Shinya Ohyanagi <sohyanagi@gmail.com>
" License:      This file is placed in the public domain.
" NOTE:         This module is heavily inspired by php-doc.vim and
"               sonictemplate.vim
let s:save_cpo = &cpo
set cpo&vim

" Path to docstring template.
if exists('g:pydocstring_templates_dir')
  let s:tmpldir = g:pydocstring_templates_dir
else
  let s:tmpldir = expand('<sfile>:p:h:h') . '/template/pydocstring/'
endif
" Use comment.txt when cursor is not on def|class keyword.
if !exists('g:pydocstring_enable_comment')
  let g:pydocstring_enable_comment = 1
endif
if !exists('g:pydocstring_ignore_args_pattern')
  let g:pydocstring_ignore_args_pattern = 'self\|cls'
endif

function! s:readtmpl(type)
  let path = s:tmpldir . a:type . '.txt'
  if !filereadable(path)
    throw 'Template ' . path . ' is not exists.'
  endif
  let tmpl = readfile(path, 'b')
  return tmpl
endfunction

function! s:parse(line)
  let str = substitute(a:line, '\\', '', 'g')
  let type = ''
  if str =~ '^def\s\|^\s*def\s'
    let str = substitute(str, '^def\s\|^\s*def\s', '', '')
    let type = 'def'
  elseif str =~ '^class\s\|^\s*class\s'
    let str = substitute(str, '^class\s\|^\s*class\s', '', '')
    let type = 'class'
  else
    return 0
  endif
  let str = substitute(str, '\s\|):\|)\s:', '', 'g')

  let strs = split(str, '(')
  let header = strs[0]
  let args = []
  if len(strs) > 1
    let args = split(strs[1], ',')
  end

  let parse = {'type': type, 'header': header, 'args': args}

  return parse
endfunction

" Vim Script does not support lambda function...
function! s:readoneline(indent, prefix)
  let tmpl = join(s:readtmpl('oneline'), "\n")
  let tmpl = a:indent . substitute(tmpl, "\n", '', '')
  let tmpl = substitute(tmpl, '{{_header_}}', a:prefix, 'g')
  return tmpl
endfunction

function! s:builddocstring(strs, indent)
  let type  = a:strs['type']
  let prefix = a:strs['header']
  let args = a:strs['args']
  let tmpl = ''
  if len(args) > 0 && type == 'def'
    let docstrings = []
    let lines = s:readtmpl('multi')
    for line in lines
      if line =~ '{{_header_}}'
        let header = substitute(line, '{{_header_}}', prefix, '')
        call add(docstrings, a:indent . header)
      elseif line =~ '{{_arg_}}'
        if len(args) == 0
          let tmpl = s:readoneline(a:indent, prefix)
          return tmpl
        endif

        if args[0] =~ g:pydocstring_ignore_args_pattern && len(args) == 1
          let tmpl = s:readoneline(a:indent, prefix)
          return tmpl
        endif

        let arglist = []
        for arg in args
          let arg = substitute(arg, '=.*$', '', '')
          if arg =~ g:pydocstring_ignore_args_pattern
            continue
          endif
          let arg = substitute(line, '{{_arg_}}', arg, 'g')
          let arg = substitute(arg, '{{_lf_}}', "\n", '')
          let arg = substitute(arg, '{{_indent_}}', a:indent, 'g')
          call add(docstrings, a:indent . arg)
        endfor
      elseif line =~ '{{_indent_}}'
        let arg = substitute(line, '{{_indent_}}', a:indent, 'g')
        call add(docstrings, arg)
      elseif line =~ '{{_args_}}'
        if len(args) == 0
          let tmpl = s:readoneline(a:indent, prefix)
          return tmpl
        endif

        if args[0] =~ g:pydocstring_ignore_args_pattern && len(args) == 1
          let tmpl = s:readoneline(a:indent, prefix)
          return tmpl
        endif

        let arglist = []
        for arg in args
          let arg = substitute(arg, '=.*$', '', '')
          if arg =~ g:pydocstring_ignore_args_pattern
            continue
          endif
          let arg = substitute(line, '{{_args_}}', arg, '')
          call add(docstrings, a:indent . arg)
        endfor
      elseif line == '"""'
        call add(docstrings, a:indent . line)
      else
        call add(docstrings, line)
      endif
    endfor
    let tmpl = substitute(join(docstrings, "\n"), "\n$", '', '')
  else
    let tmpl = s:readoneline(a:indent, prefix)
  endif

  return tmpl
endfunction

function! pydocstring#insert()
  silent! execute 'normal! 0'
  let line = getline('.')
  let indent = matchstr(line, '^\(\s*\)')

  let startpos = line('.')
  let insertpos = search('\:\+$')
  let lines = join(getline(startpos, insertpos))

  let docstring = s:parse(lines)
  let lastpos = startpos
  if type(docstring) == type(0)
    if g:pydocstring_enable_comment == 1
      let tmpl = join(s:readtmpl('comment'), "\n")
      let tmpl = substitute(tmpl, "\n", '', '')
      call s:insert(startpos, indent . tmpl)
    endif
  else
    if len(indent) == 0
      let indent = repeat(' ', &softtabstop)
    else
      let indent = indent . repeat(' ', &softtabstop)
    endif
    try
      let result = s:builddocstring(docstring, indent)
      call s:insert(insertpos + 1, result)
    catch /^Template/
      echomsg v:exception
    endtry
    let lastpos = lastpos + 1
  endif
  silent! execute 'normal! ' . lastpos . 'G$'

endfunction

function! s:insert(pos, docstring)
  let paste = &g:paste
  let &g:paste = 1
  silent! execute 'normal! ' . a:pos . 'G$'
  let currentpos = line('.')
  " If current position is bottom, add docstring below.
  if a:pos == currentpos
    silent! execute 'normal! O' . a:docstring
  else
    silent! execute 'normal! o' . a:docstring
  endif
  let &g:paste = paste
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
