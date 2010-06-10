" Vim script file
" Maintainer: David Liang <bmdavll@gmail.com>
" License: This file is distributed under the Vim license
"
" Implementation of linear congruential pseudo-random number generator

" script variables "{{{
let s:intmax = 2147483647
let s:seed = 1
"}}}

" s:abs(n) - return absolute value of n "{{{
function! s:abs(n)
    if a:n < 0
        return -a:n
    else
        return a:n
    endif
endfunction
"}}}

" s:rand() - return random integer "{{{
function! s:rand()
    let s:seed = 1103515245 * s:seed + 12345
    return s:seed
endfunction
"}}}

" s:srand(int) - seed generator "{{{
function! s:srand(int)
    let s:seed = s:abs(a:int)
    for n in range(1,15)
        call s:rand()
        let n += 1
    endfor
endfunction
"}}}
call s:srand(localtime())

" Srand(int) - set the seed "{{{
function! Srand(int)
    call s:srand(a:int)
endfunction
"}}}

" Random(range) - return random unsigned in [0, abs(range)) "{{{
function! Random(range)
    let pos = s:abs(s:rand() % s:intmax) / (s:intmax+0.0)
    return float2nr(pos * s:abs(a:range))
endfunction
"}}}

" vim:set ts=4 sw=4 et foldmethod=marker: