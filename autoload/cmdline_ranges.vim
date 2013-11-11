" =============================================================================
" Filename: autoload/cmdline_ranges.vim
" Author: itchyny
" License: MIT License
" Last Change: 2013/11/12 01:04:48.
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
  if len(a:numstr)
    if a:numstr[0] == '+'
      return 0 + a:numstr[1:]
    else
      return 0 + a:numstr
    endif
  else
    return 0
  endif
endfunction

function! s:parserange(string, prev)
  let string = a:string
  let range = []
  for i in [0, 1]
    let num = 0
    let flg = 0
    if string ==# a:prev && i == 0
      return [s:cursor(), s:cursor()]
    elseif string ==# '%' && i == 0
      return [s:absolute(1), s:last()]
    elseif string =~# '^\d\+'
      let str = matchstr(string, '^\d\+')
      let num = str + 0
      let flg = 1
    elseif string =~# '^\.'
      let str = matchstr(string, '^\.')
      call add(range, s:cursor())
    elseif string =~# '^\$'
      let str = matchstr(string, '^\$')
      call add(range, s:last())
    elseif string =~# '^\(/\([^/]\|\\/\)\+/\|?\([^?]\|\\?\)\+?\)\+'
      let str = matchstr(string, '^\(/\([^/]\|\\/\)\+/\|?\([^?]\|\\?\)\+?\)\+')
      call add(range, s:pattern(str))
    else
      return []
    endif
    let string = string[len(str):]
    while string =~# '^[+-]\d\+'
      let str = matchstr(string, '^[+-]\d\+')
      if flg
        let num += s:parsenumber(str)
      elseif (range[-1].string ==# '.' || range[-1].string ==# '$') && str =~# '^[+-]0$'
        let range[-1].string .= str
      else
        let range[-1] = s:add(range[-1], s:parsenumber(str))
      endif
      let string = string[len(str):]
    endwhile
    if i == 0
      if string =~# '^,'
        let string = string[1:]
        if flg
          call add(range, s:absolute(num))
        endif
      elseif flg && string ==# a:prev
        return [s:cursor(), s:cursor(), num]
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

let s:idx = 1
let s:range = ''
function! s:addrange(range, diff)
  if a:range[0].string =~# '^\d\+$' && a:range[1].string =~# '^\d\+$'
        \ || a:range[0].string =~# '^\..\+$' && a:range[1].string =~# '^\..\+$'
        \ || a:range[0].string =~# '^\$.\+$' && a:range[1].string =~# '^\$.\+$'
    if s:range != a:range[0].string . ',' . a:range[1].string
      let s:idx = 1
    elseif a:range[0].line == a:range[1].line
      let s:idx = !s:idx
    endif
    let ret = [s:add(a:range[s:idx], a:diff), a:range[!s:idx]]
    if ret[0].string ==# '.'
      let ret[0].string .= '+0'
    elseif ret[0].string ==# '$'
      let ret[0].string .= '-0'
    endif
    let s:range = ret[0].string . ',' . ret[1].string
    return ret
  endif
  let idx = s:point(a:range[0]) < s:point(a:range[1])
  let ret = deepcopy(a:range)
  let ret[idx] = s:add(a:range[idx], a:diff)
  if ret[idx].string ==# '.' && ret[!idx].string =~# '^\d\+$'
    let ret[idx].string .= '+0'
  endif
  return ret
endfunction

function! s:index(range)
  return s:addrange(a:range, -line('$'))[1].line == 1
endfunction

function! cmdline_ranges#range_one(motion)
  if mode() == 'c' && getcmdtype() == ':'
    let forward = a:motion == 'j'
    let endcu = "\<End>\<C-u>"
    let range = s:parserange(getcmdline(), '')
    if len(range)
      let diff = (len(range) == 3 ? range[2] : 1) * (forward ? 1 : -1)
      return endcu . s:strrange(s:addrange(range, diff))
    else
      return a:motion
    endif
  else
    return a:motion
  endif
endfunction

function! cmdline_ranges#range_paragraph(motion)
  if mode() == 'c' && getcmdtype() == ':'
    let forward = a:motion == '}'
    let diff = forward ? 1 : -1
    let endcu = "\<End>\<C-u>"
    let range = s:parserange(getcmdline(), '')
    if len(range)
      let num = len(range) > 2 ? range[2] : 1
      let line = range[s:index(range)].line
      let start_line = line
      let last = line('$')
      while num > 0 && 1 <= line && line <= last
        let line += diff
        if getline(line) ==# ''
          let num -= 1
        endif
      endwhile
      return endcu . s:strrange(s:addrange(range, line - start_line))
    else
      return a:motion
    endif
  else
    return a:motion
  endif
endfunction

function! cmdline_ranges#range(motion, prev)
  if mode() == 'c' && getcmdtype() == ':'
    let forward = a:motion ==# 'G'
    let endcu = "\<End>\<C-u>"
    let range = s:parserange(getcmdline(), a:prev)
    if len(range)
      if getcmdline() ==# a:prev
        if a:motion ==# '%'
          return endcu . s:strrange([s:absolute(1), s:last()])
        else
          return endcu . s:strrange([range[0], forward ? s:last() : s:absolute(1)])
        endif
      else
        if a:motion ==# '%'
          return endcu . s:strrange([s:add(s:unpattern(range[0]), -line('$')), s:add(s:unpattern(range[1]), line('$'))])
        elseif len(range) == 3
          let range[s:index(range)] = s:absolute(range[2])
          return endcu . s:strrange(range)
        else
          return endcu . s:strrange(s:addrange(range, (forward ? 1 : -1) * line('$')))
        endif
      endif
    else
      return a:motion
    endif
  else
    return a:motion
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
