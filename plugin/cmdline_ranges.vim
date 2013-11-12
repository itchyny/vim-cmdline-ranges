" =============================================================================
" Filename: plugin/cmdline_ranges.vim
" Author: itchyny
" License: MIT License
" Last Change: 2013/11/12 08:54:50.
" =============================================================================

if exists('g:loaded_cmdline_ranges') && g:loaded_cmdline_ranges
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

cnoremap <expr> <Plug>(cmdline-ranges-j) cmdline_ranges#range('j', '')
cnoremap <expr> <Plug>(cmdline-ranges-k) cmdline_ranges#range('k', '')
cnoremap <expr> <Plug>(cmdline-ranges-}) cmdline_ranges#range('}', '')
cnoremap <expr> <Plug>(cmdline-ranges-{) cmdline_ranges#range('{', '')
cnoremap <expr> <Plug>(cmdline-ranges-g) cmdline_ranges#range('g', 'g')
cnoremap <expr> <Plug>(cmdline-ranges-G) cmdline_ranges#range('G', '')
cnoremap <expr> <Plug>(cmdline-ranges-%) cmdline_ranges#range('%', '')

if get(g:, 'cmdline_ranges_default_mapping', 1)
  for k in split('jk}{gG%', '\zs')
    exec 'cmap ' . k . ' <Plug>(cmdline-ranges-' . k . ')'
  endfor
endif

let g:loaded_cmdline_ranges = 1

let &cpo = s:save_cpo
unlet s:save_cpo
