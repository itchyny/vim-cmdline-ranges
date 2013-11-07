" =============================================================================
" Filename: autoload/cmdline_ranges.vim
" Author: itchyny
" License: MIT License
" Last Change: 2013/11/08 01:02:38.
" =============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! cmdline_ranges#range_one(motion)
  if mode() == 'c' && getcmdtype() == ':'
    let forward = a:motion == 'j'
    let endcu = "\<End>\<C-u>"
    if getcmdline() =~# '^\d*$'
      let num = max([getcmdline(), 1])
      let range = forward ? '.,.+' . num : '.-' . num . ',.'
      return endcu . range
    elseif getcmdline() =~# '^\d\+,\.$'
      let num = max([matchstr(getcmdline(), '\d\+') + (forward ? 1 : -1), 1])
      let range = num . ',.'
      return endcu . range
    elseif getcmdline() =~# '^\.,\(\.\|\$\|/\([^/]\|\\/\)\+/\|?\([^?]\|\\?\)\+?\)*\([+-]\d\+\)\?$'
      let num = matchstr(getcmdline(), '\(\(+\@<=\|-\)\d\+\)\?$') + (forward ? 1 : -1)
      let numstr = num > 0 ? '+' . num : num == 0 ? '' : '' . num
      let cmd = substitute(getcmdline(), '\([+-]\d\+\)\?$', '', '')
      let range = cmd . numstr
      return endcu . (range == '.,.' ? '' : range)
    elseif getcmdline() =~# '^\(\.\|\$\|/\([^/]\|\\/\)\+/\|?\([^?]\|\\?\)\+?\)*\([+-]\d\+\)\?,\.$'
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
