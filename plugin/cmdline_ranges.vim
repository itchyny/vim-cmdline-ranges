" =============================================================================
" Filename: plugin/cmdline_ranges.vim
" Author: itchyny
" License: MIT License
" Last Change: 2014/12/05 15:45:44.
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
cnoremap <expr> <Plug>(cmdline-ranges-$) cmdline_ranges#range('$', '')
cnoremap <expr> <Plug>(cmdline-ranges-%) cmdline_ranges#range('%', '')
cnoremap <expr> <Plug>(cmdline-ranges-p) cmdline_ranges#range('p', '')
cnoremap <expr> <Plug>(cmdline-ranges-i) cmdline_ranges#range('i', '')

if get(g:, 'cmdline_ranges_default_mapping', 1)
  cmap j <Plug>(cmdline-ranges-j)
  cmap k <Plug>(cmdline-ranges-k)
  cmap } <Plug>(cmdline-ranges-})
  cmap { <Plug>(cmdline-ranges-{)
  " cmap g <Plug>(cmdline-ranges-g)
  cmap $ <Plug>(cmdline-ranges-$)
  cmap % <Plug>(cmdline-ranges-%)
  cmap p <Plug>(cmdline-ranges-p)
  cmap i <Plug>(cmdline-ranges-i)
endif

let g:loaded_cmdline_ranges = 1

let &cpo = s:save_cpo
unlet s:save_cpo
