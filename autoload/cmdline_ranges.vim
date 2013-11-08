" =============================================================================
" Filename: autoload/cmdline_ranges.vim
" Author: itchyny
" License: MIT License
" Last Change: 2013/11/08 11:01:55.
" =============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! s:cursor()
  return { 'line': line('.'), 'string': '.' }
endfunction

function! s:last()
  return { 'line': line('$'), 'string': '$' }
endfunction

function! s:absolute(line)
  return { 'line': a:line, 'string': '' . a:line }
endfunction

function! s:strdiff(num)
  return a:num == 0 ? '' : a:num > 0 ? '+' . a:num : '' . a:num
endfunction

function! s:add(pos, diff)
  let pos = copy(a:pos)
  let pos.line = max([min([a:pos.line + a:diff, line('$')]), 1])
  if pos.string[0] ==# '.'
    let pos.string = '.' . s:strdiff(pos.line - line('.'))
  elseif pos.string[0] ==# '$'
    let pos.string = '$' . s:strdiff(pos.line - line('$'))
  elseif pos.string =~# '^\d\+$'
    let pos.string = '' . pos.line
  endif
  return pos
endfunction

function! s:strrange(range)
  let [from, to] = a:range
  if from.line == to.line
    if from.string ==# '.' && to.string ==# '.'
      return ''
    elseif from.string ==# '.' || to.string ==# '$'
      return from.string . ',' . to.string
    elseif to.string ==# '.' || from.string ==# '$'
      return to.string . ',' . from.string
    endif
  endif
  if from.line < to.line
    return from.string . ',' . to.string
  else
    return to.string . ',' . from.string
  endif
endfunction

function! s:parserange(string)
  if a:string =~# '^\(\d*\|\.,\.\)$'
    return [s:cursor(), s:cursor()]
  elseif a:string =~# '^\(\.,\d\+\|\d\+,\.\)$'
    return [s:cursor(), s:absolute(max([matchstr(a:string, '\d\+'), 1]))]
  elseif a:string =~# '^\(\.,\.[+-]\d\+\|\.[+-]\d\+,\.\)$'
    return [s:cursor(), s:add(s:cursor(), matchstr(a:string, '-\?\d\+'))]
  elseif a:string =~# '^\(\.,\$\([+-]\d\+\)\?\|\$\([+-]\d\+\)\?,\.\)$'
    return [s:cursor(), s:add(s:last(), matchstr(getcmdline(), '-\?\d\+'))]
  else
    return []
  endif
endfunction

function! s:addrange(range, diff)
  if a:range[0].line == line('.') && a:range[0].string ==# '.'
    return [a:range[0], s:add(a:range[1], a:diff)]
  else
    return [s:add(a:range[0], a:diff), a:range[1]]
  endif
endfunction

function! s:deal(cmdline, diff)
  let range = s:parserange(a:cmdline)
  if len(range)
    if a:cmdline =~# '^0\+$'
      let diff = 0
    elseif a:cmdline =~# '^\d\+$'
      let diff = a:diff * max([a:cmdline, 1])
    else
      let diff = a:diff
    endif
    return s:strrange(s:addrange(range, diff))
  else
    return -1
  endif
endfunction

function! cmdline_ranges#range_one(motion)
  if mode() == 'c' && getcmdtype() == ':'
    let forward = a:motion == 'j'
    let endcu = "\<End>\<C-u>"
    let result = s:deal(getcmdline(), forward ? 1 : -1)
    if result != -1
      return endcu . result
    endif
    if getcmdline() =~# '^\.,\(/\([^/]\|\\/\)\+/\|?\([^?]\|\\?\)\+?\)*\([+-]\d\+\)\?$'
      let num = matchstr(getcmdline(), '\(\(+\@<=\|-\)\d\+\)\?$') + (forward ? 1 : -1)
      let numstr = num > 0 ? '+' . num : num == 0 ? '' : '' . num
      let cmd = substitute(getcmdline(), '\([+-]\d\+\)\?$', '', '')
      let range = cmd . numstr
      return endcu . (range == '.,.' ? '' : range)
    elseif getcmdline() =~# '^\(/\([^/]\|\\/\)\+/\|?\([^?]\|\\?\)\+?\)*\([+-]\d\+\)\?,\.$'
      let num = matchstr(getcmdline(), '\(\(+\@<=\|-\)\d\+\)\?\(,\.\)\@=') + (forward ? 1 : -1)
      let numstr = num > 0 ? '+' . num : num == 0 ? '' : '' . num
      let cmd = substitute(getcmdline(), '\([+-]\d\+\)\?,\.$', '', '')
      let range = cmd . numstr . ',.'
      return endcu . (range == '.,.' ? '' : range)
    else
      return a:motion
    endif
  else
    return a:motion
  endif
endfunction

function! cmdline_ranges#range_paragraph(motion)
  if mode() == 'c' && getcmdtype() == ':'
    let pat = a:motion == '}' ? '/^$/' : '?^$?'
    let forward = a:motion == '}'
    let endcu = "\<End>\<C-u>"
    if getcmdline() =~# '^\d*$'
      let reppat = repeat(pat, max([getcmdline(), 1]))
      let range = forward ? '.,' . reppat : reppat . ',.'
      return endcu . range
    elseif getcmdline() =~# '^\.,\(/\^\$/\)\+$'
      let range = forward ? getcmdline() . pat : substitute(getcmdline(), '/\^\$/', '', '')
      return endcu . (range == '.,' ? '' : range)
    elseif getcmdline() =~# '^\(?\^\$?\)\+,\.$'
      let range = !forward ? pat . getcmdline() : substitute(getcmdline(), '?\^\$?', '', '')
      return endcu . (range == ',.' ? '' : range)
    else
      return a:motion
    endif
  else
    return a:motion
  endif
endfunction

function! cmdline_ranges#range(motion, prev, range)
  if mode() == 'c' && getcmdtype() == ':' && getcmdline() ==# a:prev
    return "\<End>\<C-u>" . a:range
  else
    return a:motion
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
