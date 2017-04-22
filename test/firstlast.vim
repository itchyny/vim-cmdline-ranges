let s:suite = themis#suite('firstlast')
let s:assert = themis#helper('assert')

function! s:suite.before_each()
  call Setup('  12345  6789    12345   ')
endfunction

function! s:suite.firstlast()
  call Test(':$', '.,$', [1, 25])
  call Test(':$$', '.,$', [1, 25])
  call Test(':$gg', '.,$-24', [1, 1])
  call Test(':gg', '.,1', [1, 1])
  5
  call Test(':gg', '1,.', [1, 5])
  call Test(':gg$', '.,25', [5, 25])
  call Test(':$', '.,$', [5, 25])
  call Test(':$gg', '$-24,.', [1, 5])
endfunction

function! s:suite.firstlast_count()
  call Test(':0$', '.,1', [1, 1])
  call Test(':3$', '.,3', [1, 3])
  5
  call Test(':3$', '3,.', [3, 5])
  call Test(':5$', '.,5', [5, 5])
  call Test(':7$', '.,7', [5, 7])
  call Test(':1gg', '1,.', [1, 5])
  call Test(':5gg', '.,5', [5, 5])
  call Test(':  10  gg', '.,10', [5, 10])
endfunction

function! s:suite.firstlast_relative()
  call Test(':  .  $', '.+24', [25, 25])
  call Test(':  .  gg', '.', [1, 1])
  10
  call Test(':.$gg', '.-9', [1, 1])
  call Test(':.+5$', '.+15', [25, 25])
  call Test(':.-5gg', '.-9', [1, 1])
endfunction

function! s:suite.firstlast_relative_relative()
  10
  call Test(':.-3,.+3$', '.-3,.+15', [7, 25])
  call Test(': . -3 , . +3  gg', '.-9,.-3', [1, 7])
  call Test(':.+3,.-3$', '.+3,.+15', [13, 25])
  call Test(':.+3,.-3$gggg', '.-9,.+3', [1, 13])
  call Test(':.-30,.+30$', '.-9,.+15', [1, 25])
  call Test(':.-30,.+30$gg', '.-9,.-9', [1, 1])
  call Test(':.+30,.-30$', '.+15,.+15', [25, 25])
  call Test(':.+30,.-30gg', '.-9,.+15', [1, 25])
endfunction

function! s:suite.firstlast_absolute_absolute()
  call Test(':5,11$', '5,25', [5, 25])
  call Test(':  5  ,  11  $  gg', '1,5', [1, 5])
  call Test(':5,11$gg$', '5,25', [5, 25])
  call Test(':5,11gg', '1,5', [1, 5])
  call Test(':8,9gg', '1,8', [1, 8])
  call Test(':25,25$', '25,25', [25, 25])
  call Test(':25,25gg', '1,25', [1, 25])
  call Test(':12,5$', '12,25', [12, 25])
  call Test(':12,5gg', '1,12', [1, 12])
  call Test(':12,5gg$', '12,25', [12, 25])
endfunction

function! s:suite.firstlast_last_last()
  call Test(":\<C-v>$-20,$-10$", '$-20,$-0', [5, 25])
  call Test(":\<C-v>$-20,$-10gg", '$-24,$-20', [1, 5])
  call Test(":\<C-v>$-20,$-10gg$gg", '$-24,$-20', [1, 5])
  call Test(":\<C-v>$-10,$-20$", '$-10,$-0', [15, 25])
endfunction

function! s:suite.firstlast_entire()
  call Test(':%$', '%', [1, 25])
  call Test(':%gg', '1,$-24', [1, 1])
  call Test(':%  gg  $', '%', [1, 25])
endfunction

function! s:suite.firstlast_mixed()
  10
  call Test(':.-1,11$', '11,.+15', [11, 25])
  call Test(':.-1,11gg', '.-9,11', [1, 11])
  call Test(':.-1,11$gg$', '11,.+15', [11, 25])
  call Test(':.+3,$-11$', '.+3,$', [13, 25])
  call Test(':.+5,$-16gg', '$-24,.+5', [1, 15])
  call Test(":\<C-v>$-15,12gggg", '$-24,12', [1, 12])
  call Test(":\<C-v>$-15,12$$", '12,$', [12, 25])
  call Test(":\<C-v>$-15,12$gg$", '12,$', [12, 25])
endfunction
