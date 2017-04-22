let s:suite = themis#suite('entire')
let s:assert = themis#helper('assert')

function! s:suite.before_each()
  call Setup('  12345  6789    12345   ')
endfunction

function! s:suite.entire()
  call Test(':%', '%', [1, 25])
  call Test(':%%', '%', [1, 25])
  call Test(':%gg%', '%', [1, 25])
  call Test(':%kk%', '%', [1, 25])
endfunction

function! s:suite.entire_count()
  call Test(':3%', '.,.+24', [1, 25])
  10
  call Test(':  3  %', '.-9,.+15', [1, 25])
endfunction

function! s:suite.entire_relative()
  call Test(':  .  %', '%', [1, 25])
  10
  call Test(':.+5%', '%', [1, 25])
  call Test(':.-5%', '%', [1, 25])
endfunction

function! s:suite.entire_relative_relative()
  10
  call Test(':.-3,.+3%', '.-9,.+15', [1, 25])
  call Test(': . -3 , . +3  %', '.-9,.+15', [1, 25])
  call Test(':.+3,.-3%', '.-9,.+15', [1, 25])
  call Test(':.-30,.+30%', '.-9,.+15', [1, 25])
  call Test(':.+30,.-30%', '.-9,.+15', [1, 25])
endfunction

function! s:suite.entire_absolute_absolute()
  call Test(':5,11%', '1,25', [1, 25])
  call Test(':  5  ,  11  %', '1,25', [1, 25])
  call Test(':25,25%', '1,25', [1, 25])
  call Test(':12,5%', '1,25', [1, 25])
endfunction

function! s:suite.entire_last_last()
  call Test(":\<C-v>$-20,$-10%", '$-24,$', [1, 25])
  call Test(":\<C-v>$-10,$-20%", '$-24,$', [1, 25])
endfunction

function! s:suite.entire_mixed()
  10
  call Test(':.-1,11%', '.-9,25', [1, 25])
  call Test(':.-1,11%gg%', '.-9,25', [1, 25])
  call Test(':.+5,$-21%', '.-9,$', [1, 25])
  call Test(':3,$-21%', '%', [1, 25])
  call Test(":\<C-v>$-15,12%", '$-24,25', [1, 25])
endfunction
