" =============================================================================
" Filename: autoload/cmdline_ranges.vim
" Author: itchyny
" License: MIT License
" Last Change: 2013/11/12 13:48:04.
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
  let line = max([min([a:line, line('$')]), 1])
  return { 'line': line, 'string': '' . line }
endfunction

function! s:pattern(pat)
  " TODO: calculate line
  return { 'line': line('.'), 'string': a:pat }
endfunction

function! s:strdiff(num)
  return a:num == 0 ? '' : a:num > 0 ? '+' . a:num : '' . a:num
endfunction

function! s:unpattern(pos)
  if a:pos.string =~# '^[/?]'
    let num = s:parsenumber(matchstr(a:pos.string, '[+-]\d\+$'))
    return s:add(s:cursor(), num)
  else
    return a:pos
  endif
endfunction

function! s:range(range)
  let range = [a:range[0].line, a:range[1].line]
  return range[0] >= range[1] ? [range[1], range[0]] : range
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
  elseif pos.string =~# '^[/?]'
    let num = s:parsenumber(matchstr(pos.string, '[+-]\d\+$'))
    let pos.string = substitute(pos.string, '[+-]\d\+$', '', '') . s:strdiff(num + a:diff)
    let pos.line = line('.') " TODO
  endif
  return pos
endfunction

function! s:strrange(range)
  if len(a:range) == 1
    return a:range[0].string
  endif
  let [from, to; rest] = a:range
  if from.line == to.line && from.string !~# '^[/?]' && to.string !~# '^[/?]'
    if from.string ==# '.' && to.string ==# '.'
      return ''
    elseif from.string ==# '.' || to.string ==# '$'
      return from.string . ',' . to.string
    elseif to.string ==# '.' || from.string ==# '$'
      return to.string . ',' . from.string
    endif
  endif
  if from.line <= to.line
    let ret = from.string . ',' . to.string
  else
    let ret = to.string . ',' . from.string
  endif
  return ret ==# '1,$' ? '%' : ret
endfunction

function! s:parsenumber(numstr)
  let numstr = substitute(a:numstr, '\s\+', '', 'g')
  if len(numstr)
    if numstr[0] == '+'
      return 0 + numstr[1:]
    else
      return 0 + numstr
    endif
  else
    return 0
  endif
endfunction

function! s:parserange(string, prev)
  let string = a:string
  let str = matchstr(string, '^[: \t]\+')
  let string = string[len(str):]
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
    elseif string =~# '^\(/\([^/]\|\\/\)\+/\s*\|?\([^?]\|\\?\)\+?\s*\)\+'
      let str = matchstr(string, '^\(/\([^/]\|\\/\)\+/\s*\|?\([^?]\|\\?\)\+?\s*\)\+')
      call add(range, s:pattern(str))
    else
      return []
    endif
    let string = string[len(str):]
    while string =~# '^[+-]\s*\d\+\s*'
      let str = matchstr(string, '^[+-]\s*\d\+\s*')
      if flg
        let num += s:parsenumber(str)
      elseif (range[-1].string ==# '.' || range[-1].string ==# '$') && str =~# '^[+-]\s*0'
        let range[-1].string .= substitute(str, '\s\+', '', 'g')
      else
        let range[-1] = s:add(range[-1], s:parsenumber(str))
      endif
      let string = string[len(str):]
    endwhile
    if i == 0
      if string =~# '^\s*,\s*'
        let str = matchstr(string, '^\s*,\s*')
        let string = string[len(str):]
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

function! s:point(pos)
  return 8 * !(a:pos.string ==# '.') + 4 * (a:pos.string =~# '^\$') + 2 * (a:pos.string =~# '^\.') + !(a:pos.string =~# '^[/?]')
endfunction

function! s:same(range)
  return a:range[0].string =~# '^\d\+$' && a:range[1].string =~# '^\d\+$'
        \ || a:range[0].string =~# '^\..\+$' && a:range[1].string =~# '^\..\+$'
        \ || a:range[0].string =~# '^\$.\+$' && a:range[1].string =~# '^\$.\+$'
endfunction

function! s:addrange(range, diff)
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
function! s:index(range)
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

function! s:paragraph(range, prev, forward)
  let num = len(a:range) > 2 ? a:range[2] : 1
  let line = a:range[s:index(a:range)].line
  let start_line = line
  let last = line('$')
  let diff = a:forward ? 1 : -1
  while num > 0 && 1 <= line && line <= last
    let line += diff
    if getline(line) ==# ''
      let num -= 1
    endif
  endwhile
  return s:addrange(a:range, line - start_line)
endfunction

function! cmdline_ranges#{char2nr('{')}(range, prev)
  return s:paragraph(a:range, a:prev, 0)
endfunction

function! cmdline_ranges#{char2nr('}')}(range, prev)
  return s:paragraph(a:range, a:prev, 1)
endfunction

function! s:jk(range, prev, forward)
  let diff = (len(a:range) == 3 ? a:range[2] : 1) * (a:forward ? 1 : -1)
  return s:addrange(a:range, diff)
endfunction

function! cmdline_ranges#{char2nr('k')}(range, prev)
  return s:jk(a:range, a:prev, 0)
endfunction

function! cmdline_ranges#{char2nr('j')}(range, prev)
  return s:jk(a:range, a:prev, 1)
endfunction

function! cmdline_ranges#{char2nr('%')}(range, prev)
  if substitute(getcmdline(), '\s\+', '', 'g') ==# a:prev || len(a:range) == 1
    return [s:absolute(1), s:last()]
  else
    return [s:add(s:unpattern(a:range[0]), -line('$')), s:add(s:unpattern(a:range[1]), line('$'))]
  endif
endfunction

function! s:gG(range, prev, forward)
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

function! cmdline_ranges#{char2nr('g')}(range, prev)
  return s:gG(a:range, a:prev, 0)
endfunction

function! cmdline_ranges#{char2nr('G')}(range, prev)
  return s:gG(a:range, a:prev, 1)
endfunction

function! cmdline_ranges#range(motion, prev)
  if mode() == 'c' && getcmdtype() == ':'
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
