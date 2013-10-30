" =============================================================================
" Filename: plugin/vim-cmdline-ranges.vim
" Author: itchyny
" License: MIT License
" Last Change: 2013/10/30 22:35:58.
" =============================================================================

if exists('g:loaded_vim_cmdline_ranges') && g:loaded_vim_cmdline_ranges
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

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

cnoremap <expr> <Plug>(cmdline-ranges-}) <SID>range_paragraph('}')
cnoremap <expr> <Plug>(cmdline-ranges-{) <SID>range_paragraph('{')
cnoremap <expr> <Plug>(cmdline-ranges-g) <SID>range('g', 'g', '1,.')
cnoremap <expr> <Plug>(cmdline-ranges-G) <SID>range('G', '', '.,$')

let g:loaded_vim_cmdline_ranges = 1

let &cpo = s:save_cpo
unlet s:save_cpo
