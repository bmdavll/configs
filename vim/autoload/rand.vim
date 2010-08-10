" Vim script file
" Maintainer: David Liang <bmdavll@gmail.com>
" License: This file is distributed under the Vim license
"
" External pseudo-random number generator

let s:cpo_save = &cpo
set cpo&vim

let s:seed  = localtime()
let s:cache = []

function! s:fill()
    if !empty(s:cache) | return | endif
    for n in split(system('vim-rng '.s:seed), '\n')
        if n =~ '^\d\+$'
            let s:seed = str2nr(n)
            if s:seed < 0
                let s:seed -= 0x80000000
            endif
            call add(s:cache, s:seed)
        endif
    endfor
    if empty(s:cache)
        for i in range(100)
            let s:seed = s:seed * 1103515245 + 12345
            if s:seed < 0
                let s:seed -= 0x80000000
            endif
            call add(s:cache, (s:seed/65536)%32768)
        endfor
        let s:max = 32767
    else
        let s:max = 2147483647
    endif
endfunction

function! s:srand(int)
    let s:seed = abs(a:int)
    let s:cache = []
    call s:fill()
endfunction

" set the seed
function! rand#srand(int)
    call s:srand(a:int)
endfunction

" return random integer
function! rand#rand()
    call s:fill()
    let n = remove(s:cache, 0)
    for i in range(n % 3)
        call s:fill()
        let n = remove(s:cache, 0)
    endfor
    return n
endfunction

" return random unsigned in [0, |range|)
function! rand#randRange(range)
    let pos = rand#rand() / (s:max+1.0)
    return float2nr(pos * abs(a:range))
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
" vim:ts=4 sw=4 et:
