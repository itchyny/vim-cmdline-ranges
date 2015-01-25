" =============================================================================
" Filename: plugin/cmdline_ranges.vim
" Author: itchyny
" License: MIT License
" Last Change: 2015/01/21 11:20:07.
" =============================================================================

if exists('g:loaded_cmdline_ranges') || v:version < 700
  finish
endif
let g:loaded_cmdline_ranges = 1

let s:save_cpo = &cpo
set cpo&vim

cnoremap <expr> <Plug>(cmdline-ranges-j) cmdline_ranges#range('j', '')
cnoremap <expr> <Plug>(cmdline-ranges-k) cmdline_ranges#range('k', '')
cnoremap <expr> <Plug>(cmdline-ranges-}) cmdline_ranges#range('}', '')
cnoremap <expr> <Plug>(cmdline-ranges-{) cmdline_ranges#range('{', '')
cnoremap <expr> <Plug>(cmdline-ranges-g) cmdline_ranges#range('g', 'g')
cnoremap <expr> <Plug>(cmdline-ranges-G) cmdline_ranges#range('G', '')
cnoremap <expr> <Plug>(cmdline-ranges-$) cmdline_ranges#range('$', '')
cnoremap <expr> <Plug>(cmdline-ranges-%) cmdline_ranges#range('%', '')
cnoremap <expr> <Plug>(cmdline-ranges-p) cmdline_ranges#range('p', '')
cnoremap <expr> <Plug>(cmdline-ranges-i) cmdline_ranges#range('i', '')

if get(g:, 'cmdline_ranges_default_mapping', 1)
  cmap j <Plug>(cmdline-ranges-j)
  cmap k <Plug>(cmdline-ranges-k)
  cmap } <Plug>(cmdline-ranges-})
  cmap { <Plug>(cmdline-ranges-{)
  cmap $ <Plug>(cmdline-ranges-$)
  cmap % <Plug>(cmdline-ranges-%)
endif

let &cpo = s:save_cpo
unlet s:save_cpo
