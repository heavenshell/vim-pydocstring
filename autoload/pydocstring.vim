" Insert Docstring.
" Author:      Shinya Ohyanagi <sohyanagi@gmail.com>
" Version:     0.0.9
" License:     This file is placed in the public domain.
" WebPage:     http://github.com/heavenshell/vim-pydocstriong/
" Description: Generate Python docstring to your Python script file.
" License:     BSD, see LICENSE for more details.
" NOTE:        This module is heavily inspired by php-doc.vim and
"              sonictemplate.vim
let s:save_cpo = &cpo
set cpo&vim

" Path to docstring template.
if !exists('g:pydocstring_templates_dir')
  let g:pydocstring_templates_dir = expand('<sfile>:p:h:h') . '/template/pydocstring/'
endif

" Use comment.txt when cursor is not on def|class keyword.
if !exists('g:pydocstring_enable_comment')
  let g:pydocstring_enable_comment = 1
endif
if !exists('g:pydocstring_ignore_args_pattern')
  let g:pydocstring_ignore_args_pattern = 'self\|cls'
endif

let s:regexs = {
\ 'def': '^def\s\|^\s*def\s',
\ 'class': '^class\s\|^\s*class\s',
\ 'async': '^async\s*def\s\|^\s*async\sdef\s'
\ }

function! s:readtmpl(type)
  let tmpldir = g:pydocstring_templates_dir
  " Append the back slash if needed.
  if g:pydocstring_templates_dir !~ '/$'
    let tmpldir =  tmpldir . '/'
  endif

  let path = expand(tmpldir . a:type . '.txt')
  if !filereadable(path)
    throw 'Template ' . path . ' is not exists.'
  endif
  let tmpl = readfile(path, 'b')
  return tmpl
endfunction

function! s:parse(line)
  let str = substitute(a:line, '\\', '', 'g')
  let type = ''
  if str =~ s:regexs['def']
    let str = substitute(str, s:regexs['def'], '', '')
    let type = 'def'
  elseif str =~ s:regexs['async']
    let str = substitute(str, s:regexs['async'], '', '')
    let type = 'def'
  elseif str =~ s:regexs['class']
    let str = substitute(str, s:regexs['class'], '', '')
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

function! s:builddocstring(strs, indent, nested_indent)
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
          let arg = substitute(arg, '{{_nested_indent_}}', a:nested_indent, 'g')
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
    let space = repeat(' ', &softtabstop)
    let nested_indent = space
    if len(indent) == 0
      let indent = space
    else
      let indent = indent . space
    endif
    try
      let result = s:builddocstring(docstring, indent, nested_indent)
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
