" =============================================================================
" Filename: plugin/vim-cmdline-ranges.vim
" Author: itchyny
" License: MIT License
" Last Change: 2013/11/04 23:09:12.
" =============================================================================

if exists('g:loaded_vim_cmdline_ranges') && g:loaded_vim_cmdline_ranges
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

function! s:range_one(motion)
  if mode() == 'c' && getcmdtype() == ':'
    let forward = a:motion == 'j'
    let endcu = "\<End>\<C-u>"
    if getcmdline() =~# '^\d*$'
      let num = max([getcmdline(), 1])
      let range = forward ? '.,.+' . num : '.-' . num . ',.'
      return endcu . range
    elseif getcmdline() =~# '^\(\.\|\d\+\),\(\.\|\$\|/\([^/]\|\\/\)\+/\|?\([^?]\|\\?\)\+?\)*\([+-]\d\+\)\?$'
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

function! s:range_paragraph(motion)
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

function! s:range(motion, prev, range)
  if mode() == 'c' && getcmdtype() == ':' && getcmdline() ==# a:prev
    return "\<End>\<C-u>" . a:range
  else
    return a:motion
  endif
endfunction

cnoremap <expr> <Plug>(cmdline-ranges-j) <SID>range_one('j')
cnoremap <expr> <Plug>(cmdline-ranges-k) <SID>range_one('k')
cnoremap <expr> <Plug>(cmdline-ranges-}) <SID>range_paragraph('}')
cnoremap <expr> <Plug>(cmdline-ranges-{) <SID>range_paragraph('{')
cnoremap <expr> <Plug>(cmdline-ranges-g) <SID>range('g', 'g', '1,.')
cnoremap <expr> <Plug>(cmdline-ranges-G) <SID>range('G', '', '.,$')
cnoremap <expr> <Plug>(cmdline-ranges-%) <SID>range('%', '', '1,$')

if get(g:, 'cmdline_ranges_default_mapping', 1)
  for k in split('jk}{gG%', '\zs')
    exec 'cmap ' . k . ' <Plug>(cmdline-ranges-' . k . ')'
  endfor
endif

let g:loaded_vim_cmdline_ranges = 1

let &cpo = s:save_cpo
unlet s:save_cpo
