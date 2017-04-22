let s:suite = themis#suite('paragraph')
let s:assert = themis#helper('assert')

function! s:suite.before_each()
  call Setup("  12345  6\t\t8    12345   ")
endfunction

function! s:suite.paragraph()
  call Test(':}', '.,.+7', [1, 8])
  call Test(':}}', '.,.+13', [1, 14])
  call Test(':}}}', '.,.+22', [1, 23])
  call Test(':}}}}}', '.,.+24', [1, 25])
  call Test(':}}{', '.,.+8', [1, 9])
  call Test(':}}{{', '.,.+1', [1, 2])
  call Test(':{', '', [1, 1])
  5
  call Test(':{', '.-3,.', [2, 5])
  call Test(':{{', '.-4,.', [1, 5])
  call Test(':{{}', '.,.+3', [5, 8])
  call Test(':}}', '.,.+9', [5, 14])
  call Test(':}}{', '.,.+4', [5, 9])
  call Test(':}}}}}}', '.,.+20', [5, 25])
  10
  call Test(':{', '.-1,.', [9, 10])
  call Test(':{}', '.,.+4', [10, 14])
endfunction

function! s:suite.paragraph_count()
  call Test(':0}', '', [1, 1])
  call Test(':3}', '.,.+22', [1, 23])
  call Test(':5}', '.,.+24', [1, 25])
  5
  call Test(':0}', '', [5, 5])
  call Test(':3}', '.,.+18', [5, 23])
  call Test(':5}', '.,.+20', [5, 25])
  call Test(':1{', '.-3,.', [2, 5])
  call Test(':2{', '.-4,.', [1, 5])
  10
  call Test(':10{', '.-9,.', [1, 10])
  call Test(':2}', '.,.+13', [10, 23])
  call Test(':2{', '.-8,.', [2, 10])
endfunction

function! s:suite.paragraph_relative()
  call Test(':.}}}', '.+22', [23, 23])
  call Test(':.{{{', '.', [1, 1])
  8
  call Test(':.}}{{', '.+1', [9, 9])
  call Test(':.{', '.-6', [2, 2])
  call Test(':.+5}}}', '.+17', [25, 25])
  call Test(':.-5{', '.-6', [2, 2])
  call Test(':.-5}', '.', [8, 8])
  call Test(':.+30}', '.+17', [25, 25])
  call Test(':.-30{', '.-7', [1, 1])
  call Test(':.-30}', '.', [8, 8])
endfunction

function! s:suite.paragraph_relative_relative()
  12
  call Test(':.-3,.+3}', '.-3,.+11', [9, 23])
  call Test(':.-3,.+3}{{{', '.-10,.-3', [2, 9])
  call Test(':.+3,.-3}', '.+2,.+3', [14, 15])
  call Test(':.+3,.-3}{{', '.-10,.+3', [2, 15])
  call Test(':.+30,.-30}', '.-4,.+13', [8, 25])
  call Test(':.+30,.-30{', '.-11,.+13', [1, 25])
  call Test(':.+3,.+3{', '.-3,.+3', [9, 15])
endfunction

function! s:suite.paragraph_absolute_absolute()
  call Test(':5,11}', '5,14', [5, 14])
  call Test(':5,11}}', '5,23', [5, 23])
  call Test(':5,11}}{', '5,17', [5, 17])
  call Test(':5,11}}{{{', '2,5', [2, 5])
  call Test(':5,11{{{', '1,5', [1, 5])
  call Test(':8,9{', '2,8', [2, 8])
  call Test(':25,25}', '25,25', [25, 25])
  call Test(':25,25{', '17,25', [17, 25])
  call Test(':12,5}', '8,12', [8, 12])
  call Test(':12,5}}', '12,14', [12, 14])
  call Test(':12,5{', '2,12', [2, 12])
  call Test(':12,5{{', '1,12', [1, 12])
endfunction

function! s:suite.paragraph_last_last()
  call Test(":\<C-v>$-20,$-10}", '$-20,$-2', [5, 23])
  call Test(":\<C-v>$-20,$-10{", '$-20,$-16', [5, 9])
  call Test(":\<C-v>$-20,$-10{}{{", '$-23,$-20', [2, 5])
  call Test(":\<C-v>$-10,$-20}", '$-17,$-10', [8, 15])
  call Test(":\<C-v>$-10,$-20}}", '$-11,$-10', [14, 15])
endfunction

function! s:suite.paragraph_entire()
  call Test(':%}', '%', [1, 25])
  call Test(':%{{', '1,$-16', [1, 9])
  call Test(':%{{{{', '1,$-24', [1, 1])
  call Test(':%{{}}', '1,$-2', [1, 23])
  call Test(':%{{}}}', '%', [1, 25])
endfunction

function! s:suite.paragraph_mixed()
  10
  call Test(':.-1,11}', '11,.+4', [11, 14])
  call Test(':.-1,11}}', '11,.+13', [11, 23])
  call Test(':.-1,11}}}', '11,.+15', [11, 25])
  call Test(':.+3,$-11}', '.+3,$-2', [13, 23])
  call Test(':.+5,$-16{', '$-23,.+5', [2, 15])
  call Test(":\<C-v>$-15,12{{", '$-23,12', [2, 12])
  call Test(":\<C-v>$-15,12}}", '12,$-2', [12, 23])
  call Test(":\<C-v>$-15,12}}}}{{{{", '$-24,12', [1, 12])
endfunction
