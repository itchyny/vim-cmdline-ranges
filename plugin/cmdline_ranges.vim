" =============================================================================
" Filename: plugin/cmdline_ranges.vim
" Author: itchyny
" License: MIT License
" Last Change: 2013/11/07 14:16:47.
" =============================================================================

if exists('g:loaded_cmdline_ranges') && g:loaded_cmdline_ranges
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

cnoremap <expr> <Plug>(cmdline-ranges-j) cmdline_ranges#range_one('j')
cnoremap <expr> <Plug>(cmdline-ranges-k) cmdline_ranges#range_one('k')
cnoremap <expr> <Plug>(cmdline-ranges-}) cmdline_ranges#range_paragraph('}')
cnoremap <expr> <Plug>(cmdline-ranges-{) cmdline_ranges#range_paragraph('{')
cnoremap <expr> <Plug>(cmdline-ranges-g) cmdline_ranges#range('g', 'g', '1,.')
cnoremap <expr> <Plug>(cmdline-ranges-G) cmdline_ranges#range('G', '', '.,$')
cnoremap <expr> <Plug>(cmdline-ranges-%) cmdline_ranges#range('%', '', '1,$')

if get(g:, 'cmdline_ranges_default_mapping', 1)
  for k in split('jk}{gG%', '\zs')
    exec 'cmap ' . k . ' <Plug>(cmdline-ranges-' . k . ')'
  endfor
endif

let g:loaded_cmdline_ranges = 1

let &cpo = s:save_cpo
unlet s:save_cpo
