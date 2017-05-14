" =============================================================================
" Filename: autoload/cmdline_ranges.vim
" Author: itchyny
" License: MIT License
" Last Change: 2017/05/15 00:50:17.
" =============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! s:cursor() abort
  return s:relative(0)
endfunction

function! s:relative(num) abort
  let line = max([min([line('.') + a:num, line('$')]), 1])
  return { 'line': line, 'string': '.' . s:strdiff(line - line('.')) }
endfunction

function! s:last() abort
  return { 'line': line('$'), 'string': '$' }
endfunction

function! s:absolute(line) abort
  let line = max([min([a:line, line('$')]), 1])
  return { 'line': line, 'string': '' . line }
endfunction

function! s:mark(mark) abort
  let line = line(a:mark) ? line(a:mark) : line('.')
  return { 'line': line, 'string': a:mark, 'markline': line }
endfunction

function! s:pattern(pat) abort
  " TODO: calculate line
  return { 'line': line('.'), 'string': a:pat }
endfunction

function! s:strdiff(num) abort
  return a:num == 0 ? '' : a:num > 0 ? '+' . a:num : '' . a:num
endfunction

function! s:unpattern(pos) abort
  if a:pos.string =~# '^[/?]'
    let num = s:parsenumber(matchstr(a:pos.string, '[+-]\d\+$'))
    return s:relative(num)
  else
    return a:pos
  endif
endfunction

function! s:range(range) abort
  let range = [a:range[0].line, a:range[1].line]
  return range[0] >= range[1] ? [range[1], range[0]] : range
endfunction

function! s:add(pos, diff) abort
  let pos = copy(a:pos)
  let pos.line = max([min([a:pos.line + a:diff, line('$')]), 1])
  if pos.string =~# '^\.'
    let pos.string = '.' . s:strdiff(pos.line - line('.'))
  elseif pos.string =~# '^\$'
    let pos.string = '$' . s:strdiff(pos.line - line('$'))
  elseif pos.string =~# '^\d\+$'
    let pos.string = '' . pos.line
  elseif pos.string =~# '^'''
    let pos.string = pos.string[:1] . s:strdiff(pos.line - pos.markline)
  elseif pos.string =~# '^[/?]'
    let num = s:parsenumber(matchstr(pos.string, '[+-]\d\+$'))
    let pos.string = substitute(pos.string, '[+-]\d\+$', '', '') . s:strdiff(num + a:diff)
    let pos.line = line('.') " TODO
  endif
  return pos
endfunction

function! s:strrange(range) abort
  if len(a:range) == 1
    return a:range[0].string
  endif
  let [from, to; rest] = a:range
  let separator = s:semicolon ? ';' : ','
  if from.line == to.line
    if from.string ==# '.' && to.string ==# '.'
      let ret = ''
    elseif s:point(from) <= s:point(to)
      let ret = from.string . separator . to.string
    else
      let ret = to.string . separator . from.string
    endif
  elseif from.line <= to.line
    let ret = from.string . separator . to.string
  else
    let ret = to.string . separator . from.string
  endif
  return ret ==# '1,$' ? '%' : ret
endfunction

function! s:parsenumber(numstr) abort
  let numstr = substitute(a:numstr, '\s\+', '', 'g')
  if len(numstr)
    if numstr[0] ==# '+'
      return 0 + numstr[1:]
    else
      return 0 + numstr
    endif
  else
    return 0
  endif
endfunction

let s:semicolon = 0
function! s:parserange(string, prev) abort
  let string = a:string
  let [str, string] = s:getmatchstr(string, '^[: \t]\+')
  let range = []
  for i in [0, 1]
    let num = 0
    let flg = 0
    if string ==# a:prev && i == 0
      return [s:cursor(), s:cursor()]
    elseif string =~# '^\s*%\s*' . a:prev . '$' && i == 0
      return [s:absolute(1), s:last()]
    elseif string =~# '^\d\+\s*'
      let str = matchstr(string, '^\d\+\s*')
      let num = str + 0
      let flg = 1
    elseif string =~# '^\.\s*'
      let str = matchstr(string, '^\.\s*')
      call add(range, s:cursor())
    elseif string =~# '^\$'
      let str = matchstr(string, '^\$\s*')
      call add(range, s:last())
    elseif string =~# '^''[a-zA-Z()<>{}"''.[\]\^]'
      let str = matchstr(string, '^''[a-zA-Z()<>{}"''.[\]\^]')
      call add(range, s:mark(str))
    elseif string =~# '^\(/\([^/]\|\\/\)\+/\s*\|?\([^?]\|\\?\)\+?\s*\)\+'
      let str = matchstr(string, '^\(/\([^/]\|\\/\)\+/\s*\|?\([^?]\|\\?\)\+?\s*\)\+')
      call add(range, s:pattern(str))
    else
      return []
    endif
    let string = string[len(str):]
    while string =~# '^[+-]\s*\d\+\s*'
      let [str, string] = s:getmatchstr(string, '^[+-]\s*\d\+\s*')
      if flg
        let num += s:parsenumber(str)
      elseif (range[-1].string ==# '.' || range[-1].string ==# '$') && str =~# '^[+-]\s*0'
        let range[-1].string .= substitute(str, '\s\+', '', 'g')
      else
        let range[-1] = s:add(range[-1], s:parsenumber(str))
      endif
    endwhile
    if i == 0
      if string =~# '^\s*[,;]\s*'
        let [str, string] = s:getmatchstr(string, '^\s*[,;]\s*')
        let s:semicolon = str =~# ';'
        if flg
          call add(range, s:absolute(num))
        endif
      elseif flg && string ==# a:prev
        return [s:cursor(), s:cursor(), num]
      elseif string ==# a:prev
        return range
      else
        return []
      endif
    else
      if string ==# a:prev
        if flg
          call add(range, s:absolute(num))
        endif
        return len(range) == 2 ? range : []
      else
        return []
      endif
    endif
  endfor
  return []
endfunction

function! s:getmatchstr(str, pat) abort
  let str = matchstr(a:str, a:pat)
  return [str, a:str[len(str):]]
endfunction

function! s:point(pos) abort
  return   16 * (a:pos.string !=# '.')
        \ + 8 * (a:pos.string =~# '^\$')
        \ + 4 * (a:pos.string =~# '^\''')
        \ + 2 * (a:pos.string =~# '^\.')
        \ +     (a:pos.string !~# '^[/?]')
endfunction

function! s:same(range) abort
  return     a:range[0].string =~# '^\d\+$'  && a:range[1].string =~# '^\d\+$'
        \ || a:range[0].string =~# '^\..\+$' && a:range[1].string =~# '^\..\+$'
        \ || a:range[0].string =~# '^\$.\+$' && a:range[1].string =~# '^\$.\+$'
        \ || a:range[0].string =~# '^'''     && a:range[1].string =~# '^'''
endfunction

function! s:addrange(range, diff) abort
  if len(a:range) == 1
    return [s:add(a:range[0], a:diff)]
  endif
  if s:same(a:range)
    let idx = s:index(a:range)
    let ret = [s:add(a:range[idx], a:diff), a:range[!idx]]
    if ret[0].string ==# '.'
      let ret[0].string .= '+0'
    elseif ret[0].string ==# '$'
      let ret[0].string .= '-0'
    endif
    let s:prevrange = s:range(ret)
    let s:curpos = ret[0].line
    return ret
  endif
  let idx = s:index(a:range)
  let ret = deepcopy(a:range)
  let ret[idx] = s:add(a:range[idx], a:diff)
  if ret[idx].string ==# '.' && ret[!idx].string =~# '^\d\+$'
    let ret[idx].string .= '+0'
  endif
  return ret
endfunction

let s:prevrange = []
let s:curpos = 0
function! s:index(range) abort
  if len(a:range) == 1
    return 0
  endif
  if s:same(a:range)
    if s:prevrange != s:range(a:range)
      return 1
    endif
    return index(s:prevrange, s:curpos)
  endif
  let idx = s:point(a:range[0]) < s:point(a:range[1])
  return idx
endfunction

function! s:paragraph(range, prev, forward) abort
  let line = a:range[s:index(a:range)].line
  let start_line = line
  let diff = a:forward ? 1 : -1
  let cnt = len(a:range) == 3 ? a:range[2] : 1
  while cnt > 0
    while 1 <= line && line <= line('$') && getline(line) ==# ''
      let line += diff
    endwhile
    while 1 <= line && line <= line('$') && getline(line) !=# ''
      let line += diff
    endwhile
    let cnt -= 1
  endwhile
  return s:addrange(a:range, line - start_line)
endfunction

function! cmdline_ranges#{char2nr('{')}(range, prev) abort
  return s:paragraph(a:range, a:prev, 0)
endfunction

function! cmdline_ranges#{char2nr('}')}(range, prev) abort
  return s:paragraph(a:range, a:prev, 1)
endfunction

function! s:jk(range, prev, forward) abort
  let diff = (len(a:range) == 3 ? a:range[2] : 1) * (a:forward ? 1 : -1)
  return s:addrange(a:range, diff)
endfunction

function! cmdline_ranges#{char2nr('k')}(range, prev) abort
  return s:jk(a:range, a:prev, 0)
endfunction

function! cmdline_ranges#{char2nr('j')}(range, prev) abort
  return s:jk(a:range, a:prev, 1)
endfunction

function! cmdline_ranges#{char2nr('%')}(range, prev) abort
  if substitute(getcmdline(), '\s\+', '', 'g') ==# a:prev || len(a:range) == 1
    return [s:absolute(1), s:last()]
  else
    return [s:add(s:unpattern(a:range[0]), -line('$')), s:add(s:unpattern(a:range[1]), line('$'))]
  endif
endfunction

function! s:gG(range, prev, forward) abort
  let range = deepcopy(a:range)
  if substitute(getcmdline(), '\s\+', '', 'g') ==# a:prev
    return [range[0], a:forward ? s:last() : s:absolute(1)]
  else
    if len(range) == 3
      let range[s:index(range)] = s:absolute(range[2])
      return range
    else
      return s:addrange(range, (a:forward ? 1 : -1) * line('$'))
    endif
  endif
endfunction

function! cmdline_ranges#{char2nr('g')}(range, prev) abort
  return s:gG(a:range, a:prev, 0)
endfunction

function! cmdline_ranges#{char2nr('$')}(range, prev) abort
  return s:gG(a:range, a:prev, 1)
endfunction

function! s:p(range, prev) abort
  let start_line = line('.')
  while start_line > 0 && getline(start_line - 1) !~# '^\s*$'
    let start_line -= 1
  endwhile
  let end_line = line('.')
  while end_line < line('$') && getline(end_line) !~# '^\s*$'
    let end_line += 1
  endwhile
  if substitute(getcmdline(), '\s\+', '', 'g') ==# a:prev || len(a:range) == 1
    return [s:relative(start_line - line('.')), s:relative(end_line - line('.'))]
  else
    let [start, end] = [s:unpattern(a:range[0]), s:unpattern(a:range[1])]
    return [s:add(start, start_line - start.line), s:add(end, end_line - end.line)]
  endif
endfunction

function! cmdline_ranges#{char2nr('p')}(range, prev) abort
  return s:p(a:range, a:prev)
endfunction

function! s:i(range, prev) abort
  let indent = indent(line('.'))
  let start_line = line('.')
  let end_line = line('.')
  if getline('.') !=# ''
    while start_line > 0 && indent(start_line - 1) >= indent && getline(start_line - 1) !=# ''
      let start_line -= 1
    endwhile
    while end_line < line('$') && indent(end_line + 1) >= indent && getline(end_line + 1) !=# ''
      let end_line += 1
    endwhile
  endif
  if substitute(getcmdline(), '\s\+', '', 'g') ==# a:prev || len(a:range) == 1
    return [s:relative(start_line - line('.')), s:relative(end_line - line('.'))]
  else
    let [start, end] = [s:unpattern(a:range[0]), s:unpattern(a:range[1])]
    return [s:add(start, start_line - start.line), s:add(end, end_line - end.line)]
  endif
endfunction

function! cmdline_ranges#{char2nr('i')}(range, prev) abort
  return s:i(a:range, a:prev)
endfunction

function! cmdline_ranges#range(motion, prev) abort
  if mode() ==# 'c' && getcmdtype() ==# ':'
    let endcu = "\<End>\<C-u>"
    let range = s:parserange(getcmdline(), a:prev)
    if len(range)
      return endcu . s:strrange(cmdline_ranges#{char2nr(a:motion)}(range, a:prev))
    else
      return a:motion
    endif
  else
    return a:motion
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
