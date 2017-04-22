let s:suite = themis#suite('updown')
let s:assert = themis#helper('assert')

function! s:suite.before_each()
  call Setup('  12345  6789    12345   ')
endfunction

function! s:suite.updown()
  call Test(':kkk', '', [1, 1])
  call Test(':jjj', '.,.+3', [1, 4])
  8
  call Test(':jjj', '.,.+3', [8, 11])
  call Test(':jjkk', '', [8, 8])
  call Test(':kkk', '.-3,.', [5, 8])
  25
  call Test(':  :  jjj', '', [25, 25])
  call Test(':  :  kkk', '.-3,.', [22, 25])
  -3
  call Test(':jjjjj', '.,.+3', [22, 25])
endfunction

function! s:suite.updown_count()
  call Test(':5k', '', [1, 1])
  call Test(':5j', '.,.+5', [1, 6])
  8
  call Test(':5j', '.,.+5', [8, 13])
  call Test(':5k', '.-5,.', [3, 8])
  call Test(':30j', '.,.+17', [8, 25])
  call Test(':30k', '.-7,.', [1, 8])
  25
  call Test(':30k', '.-24,.', [1, 25])
  call Test(':30j', '', [25, 25])
endfunction

function! s:suite.updown_relative()
  call Test(':.jjj', '.+3', [4, 4])
  call Test(':.kkk', '.', [1, 1])
  8
  call Test(':.jjkk', '.', [8, 8])
  call Test(':.kkk', '.-3', [5, 5])
  call Test(':.+5jjj', '.+8', [16, 16])
  call Test(':.-5kkk', '.-7', [1, 1])
  call Test(':.+30j', '.+17', [25, 25])
  call Test(':.-30k', '.-7', [1, 1])
  call Test(':.-30j', '.-6', [2, 2])
endfunction

function! s:suite.updown_last()
  call Test(":\<C-v>$jjj", '$', [25, 25])
  call Test(":\<C-v>$kkk", '$-3', [22, 22])
  call Test(":\<C-v>$+3j", '$', [25, 25])
  call Test(":\<C-v>$+3k", '$-1', [24, 24])
  call Test(":\<C-v>$-3k", '$-4', [21, 21])
endfunction

function! s:suite.updown_multiple_count()
  8
  call Test(': . + 3 + 3 + 3 j', '.+10', [18, 18])
  call Test(': . + 3 - 3 - 3 kkk', '.-6', [2, 2])
  call Test(': 3 + 3 - 3 j', '.,.+3', [8, 11])
  call Test(': 3 + 3 - 3 - 6 j', '.-3,.', [5, 8])
  call Test(":\<C-v>$ + 3 + 3 - 3 jjj", '$', [25, 25])
  call Test(":\<C-v>$ + 3 - 3 - 3 kkk", '$-9', [16, 16])
endfunction

function! s:suite.updown_relative_relative()
  10
  call Test(':.-2,.+2', '.-2,.+2', [8, 12])
  call Test(':.-2,.+2jj', '.-2,.+4', [8, 14])
  call Test(':.-2,.+2jjkkkk', '.-2,.+0', [8, 10])
  call Test(':.-2,.+2jjkkkkkkk', '.-3,.-2', [7, 8])
  call Test(':.-2,.+2jjkkkkkkkjjj', '.-2,.+0', [8, 10])
  call Test(':.-30,.+30j', '.-9,.+15', [1, 25])
  call Test(':.-30,.+30kk', '.-9,.+13', [1, 23])
endfunction

function! s:suite.updown_absolute_absolute()
  call Test(':10,10jjj', '10,13', [10, 13])
  call Test(':10,13kkk', '10,10', [10, 10])
  call Test(':10,13kkkkkk', '7,10', [7, 10])
  call Test(':13,10kkk', '7,13', [7, 13])
  call Test(':13,10jjj', '13,13', [13, 13])
endfunction

function! s:suite.updown_last_last()
  call Test(":\<C-v>$-20,$-10", '$-20,$-10', [5, 15])
  call Test(":\<C-v>$-20,$-10kkkkk", '$-20,$-15', [5, 10])
  call Test(":\<C-v>$-20,$-17kkkkk", '$-22,$-20', [3, 5])
  call Test(":\<C-v>$-20,$-3jjj", '$-20,$-0', [5, 25])
  call Test(":\<C-v>$-20,$-3jjjkkk", '$-20,$-3', [5, 22])
endfunction

function! s:suite.updown_entire()
  call Test(':%jj', '%', [1, 25])
  call Test(':%kkk', '1,$-3', [1, 22])
  call Test(':%kkkjjj', '%', [1, 25])
endfunction

function! s:suite.updown_mixed()
  10
  call Test(':.-1,11j', '.+0,11', [10, 11])
  call Test(':.-1,11jj', '11,.+1', [11, 11])
  call Test(':.-1,11jjj', '11,.+2', [11, 12])
  call Test(':.+3,$-11j', '.+3,$-10', [13, 15])
  call Test(':.+5,$-15k', '$-16,.+5', [9, 15])
  call Test(":\<C-v>$-15,12kk", '$-17,12', [8, 12])
  call Test(":\<C-v>$-15,12jj", '12,$-13', [12, 12])
  call Test(":\<C-v>$-15,12jjjjkkkk", '$-15,12', [10, 12])
endfunction
