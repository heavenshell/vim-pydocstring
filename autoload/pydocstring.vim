" Insert Docstring.
" Author:      Shinya Ohyanagi <sohyanagi@gmail.com>
" Version:     0.6.0
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
      \ 'async': '^async\s*def\s\|^\s*async\sdef\s',
      \ 'typed_args': '\([0-9A-Za-z_.]\+:[0-9A-Za-z_.]\+\|[0-9A-Za-z_.]\+\)\(,\|$\)',
      \ 'typed_bracket': '\(\w\+\s*:\s*\w\+\[.*\],\|\w\+\s*:\s*\w\+\[.*\]\)',
      \ 'typed_primitive': '\(\w\+:\s*\w\+,\|\w\+:\s*\w\+\)',
      \ 'none_typed': '\w\+,',
      \ }

function! s:readtmpl(type)
  let tmpldir = g:pydocstring_templates_dir
  " Append the back slash if needed.
  if g:pydocstring_templates_dir !~ '/$'
    let tmpldir =  tmpldir . '/'
  endif

  let path = expand(tmpldir) . a:type . '.txt'
  if !filereadable(path)
    throw 'Template ' . path . ' does not exist.'
  endif
  let tmpl = readfile(path, 'b')
  return tmpl
endfunction

function! s:parse_class(line)
  " For class definition, we just simply need to extract the class name.  We can
  " do that by just delete every white spaces and the whole parenthesics if
  " existed.
  let header = substitute(a:line, '\s\|(.*\|:', '', 'g')
  let parse = {'type': 'class', 'header': header, 'args': '', 'return_type': ''}
  return parse
endfunction

function! s:compare(lhs, rhs)
  return a:lhs['start'] - a:rhs['start']
endfunction

function! s:parse_args(args_str)
  " FIXME Very very work around.
  " If Python2 is dead, consider to use Python interface
  let args_str = copy(a:args_str)
  let args = []
  let pos = len(args_str)

  " If last argument is none-typed or bracket typed(e.g. List[int]),
  " Add to args first.
  while 1
    let comma_idx = strridx(args_str, ',', pos)
    if comma_idx == -1
      " No multipul args left.
      break
    end
    let idx = stridx(args_str, ':', comma_idx)
    if idx == -1
      let last_arg = args_str[comma_idx + 1 :]
      if last_arg =~ ']'
        let sep_pos = strridx(args_str, ':', pos)
        let comma_idx = strridx(args_str, ',', sep_pos)
        if comma_idx == -1
          " One argument left
          break
        endif
        " Last argument is typed and have `[]`.
        let last_arg = args_str[comma_idx + 1 :]
        let last_arg = substitute(last_arg, ',\s*$', '', '')

        call add(args, {'val': last_arg, 'start': comma_idx})
        let args_str = args_str[ : comma_idx]

        break
      else
        " Last argument is not none-typed.
        let last_arg = substitute(last_arg, ',\s*$', '', '')
        call add(args, {'val': last_arg, 'start': comma_idx})
        let arg_length = len(last_arg)
        let args_str = args_str[ : comma_idx]
      endif
      let pos = comma_idx - 1
    else
      break
    endif
  endwhile

  while 1
    "" Parse like `arg: List[str]`
    let bracket_match = match(args_str, s:regexs['typed_bracket'])
    if bracket_match != -1
      let ret = matchstrpos(args_str, s:regexs['typed_bracket'])
      let arg_length = len(ret[0])
      let pos = printf('@%s%s,', ret[1], repeat(' ', arg_length - len(arg_length) - 1))

      let args_str = substitute(args_str, s:regexs['typed_bracket'], pos, '')
      let arg = substitute(ret[0], ',$', '', '')
      call add(args, {'val': arg, 'start': ret[1]})
    endif

    " Parse like `arg1: str`
    let primitive_match = match(args_str, s:regexs['typed_primitive'])
    if primitive_match != -1
      let ret = matchstrpos(args_str, s:regexs['typed_primitive'])
      let arg_length = len(ret[0])
      let pos = printf('@%s%s,', ret[1], repeat(' ', arg_length - len(arg_length) - 2))
      let args_str = substitute(args_str, s:regexs['typed_primitive'], pos, '')
      let arg = substitute(ret[0], ',$', '', '')
      call add(args, {'val': arg, 'start': ret[1]})
    endif

    " Parse like `arg`
    let none_typed_match = match(args_str, s:regexs['none_typed'])
    if none_typed_match != -1
      if match(args_str, '[A-Za-z]') == -1
        break
      endif

      let ret = matchstrpos(args_str, s:regexs['none_typed'])
      let arg_length = len(ret[0])
      let pos = printf('@%s%s,', ret[1], repeat(' ', arg_length - len(arg_length) - 1))
      let args_str = substitute(args_str, s:regexs['none_typed'], pos, '')
      let arg = substitute(ret[0], ',$', '', '')
      call add(args, {'val': arg, 'start': ret[1]})
    endif

    if bracket_match == -1 && primitive_match == -1 && none_typed_match == -1
      break
    endif
  endwhile

  call sort(args, 's:compare')
  return map(args, {i, v -> substitute(v['val'], ',', ', ', 'g')})
endfunction

function! s:parse_func(type, line)
  let header = substitute(a:line, '\s\|(.*\|:', '', 'g')

  let args_str = substitute(a:line, '\s\|.*(\|).*', '', 'g')
  if args_str =~ ':' && args_str =~ '['
    let args = s:parse_args(args_str)
  elseif args_str =~ ':'
    let args = split(args_str, ',')
  else
    " No typed args.
    let args = split(args_str, ',')
  endif

  let arrow_index = match(a:line, '->')
  let return_type = ''
  if arrow_index != -1
    let substring = strpart(a:line, arrow_index + 2)
    " issue #28 `\W*` would deleted `.`.
    let return_type = substitute(substring, '[^0-9A-Za-z_.,\[\]]*', '', 'g')
    " Add space after `,` such as `List[int, str]`.
    let return_type = substitute(return_type, ',', ', ', '')
  endif

  let parse = {
        \ 'type': a:type,
        \ 'header': header,
        \ 'args': args,
        \ 'return_type': return_type
        \ }
  return parse
endfunction

function! s:parse(line)
  let str = substitute(a:line, '#.*$', '', 'g')
  let type = ''

  if str =~ s:regexs['class']
    let str = substitute(str, s:regexs['class'], '', '')
    return s:parse_class(str)
  endif

  if str =~ s:regexs['def']
    let str = substitute(str, s:regexs['def'], '', '')
    let type = 'def'
  elseif str =~ s:regexs['async']
    let str = substitute(str, s:regexs['async'], '', '')
    let type = 'def'
  else
    return 0
  endif

  return s:parse_func(type, str)
endfunction

" Vim Script does not support lambda function...
function! s:readoneline(indent, prefix)
  let tmpl = join(s:readtmpl('oneline'), "\n")
  let tmpl = a:indent . substitute(tmpl, "\n", '', '')
  let tmpl = substitute(tmpl, '{{_header_}}', a:prefix, 'g')
  return tmpl
endfunction

" Check if we should show args in the docstring. We won't do that in  case:
" - There's no args.
" - There's only one arg that match with g:pydocstring_ignore_args_pattern
function! s:should_include_args(args)
  if len(a:args) == 0
    return 0
  endif

  if len(a:args) == 1 && a:args[0] =~ g:pydocstring_ignore_args_pattern
    return 0
  endif

  return 1
endfunction

" Check if we should use one line docstring.
" There's several cases:
" - Type is `class`
" - No return type and no args.
" - No return type and the only one args is `self` or `cls` (defined by
"   g:pydocstring_ignore_args_pattern
"
" Return 1 for True, and 0 for False
function! s:should_use_one_line_docstring(type, args, return_type)
  if a:type != 'def'
    return 1
  endif

  if a:return_type != ''
    return 0
  endif

  return !s:should_include_args(a:args)
endfunction

function! s:build_docstring(strs, indent, nested_indent)
  let type  = a:strs['type']
  let prefix = a:strs['header']
  let args = a:strs['args']
  let return_type = a:strs['return_type']

  if s:should_use_one_line_docstring(type, args, return_type)
    return s:readoneline(a:indent, prefix)
  endif

  let tmpl = ''
  let docstrings = []
  let lines = s:readtmpl('multi')
  for line in lines
    if line =~ '{{_header_}}'
      let header = substitute(line, '{{_header_}}', prefix, '')
      call add(docstrings, a:indent . header)
    elseif line =~ '{{_args_}}'
      if len(args) != 0
        for arg in args
          let arg = substitute(arg, '=.*$', '', '')
          if arg =~ g:pydocstring_ignore_args_pattern
            continue
          endif
          let template = line
          let typed = 0
          if match(arg, ':') != -1
            let arg_template = join(s:readtmpl('arg'), '')
            let arg_parts = split(arg, ':')
            let arg_template = substitute(arg_template, '{{_name_}}', arg_parts[0], 'g')
            let arg = substitute(arg_template, '{{_type_}}', arg_parts[1], 'g')
            let typed = 1
          endif
          let template = substitute(template, '{{_args_}}', arg, 'g')
          if typed == 1
            " Fix following bugs.
            "   `def foo(arg: str):` generates like followings
            "   ```
            "   :param arg:
            "   :type arg: str:
            "   ```
            " Template file describes as followings
            "   ```
            "   '''
            "   {{_header_}}
            "   :param {{_args_}}:
            "   :rtype: {{_return_type_}}
            "   '''
            let template = substitute(template, ':$', '', 'g')
          endif
          let template = substitute(template, '{{_lf_}}', '\n', 'g')
          let template = substitute(template, '{{_indent_}}', a:indent, 'g')
          let template = substitute(template, '{{_nested_indent_}}', a:nested_indent, 'g')
          let template = substitute(template, '\s$', '', '')
          call add(docstrings, a:indent . template)
        endfor
      endif
    elseif match(line, '{{_returnType_}}\|{{_return_type_}}') != -1
      if strlen(return_type) != 0
        let line = substitute(line, '{{_indent_}}', a:indent, 'g')
        let line = substitute(line, '{{_nested_indent_}}', a:nested_indent, 'g')
        let rt = substitute(line, '{{_returnType_}}\|{{_return_type_}}', return_type, '')
        call add(docstrings, a:indent . rt)
      else
        if docstrings[-1] == ''
          call remove(docstrings, -1)
        endif
      endif
    elseif line =~ '{{_indent_}}'
      let arg = substitute(line, '{{_indent_}}', a:indent, 'g')
      call add(docstrings, arg)
    elseif line == '"""' || line == "'''"
      call add(docstrings, a:indent . line)
    else
      call add(docstrings, line)
    endif
  endfor
  let tmpl = substitute(join(docstrings, "\n"), "\n$", '', '')

  return tmpl
endfunction

function! pydocstring#insert()
  silent! execute 'normal! 0'
  let line = getline('.')
  let indent = matchstr(line, '^\(\s*\)')

  let startpos = line('.')
  let insertpos = search('\:\(\s*#.*\)*$')
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
      let result = s:build_docstring(docstring, indent, nested_indent)
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
  let current_pos = line('.')
  " If current position is bottom, add docstring below.
  if a:pos == current_pos
    silent! execute 'normal! O' . a:docstring
  else
    silent! execute 'normal! o' . a:docstring
  endif
  let &g:paste = paste
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
