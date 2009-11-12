if !exists('loaded_snippet') || &cp
	finish
endif

" global snippets
let st = g:snip_start_tag
let et = g:snip_end_tag
let se = st.et

exec "Iabbr '' \"".se."\"".se
exec "Iabbr ' '".se."'".se
exec "Iabbr jk (".se.")".se

let g:snip_foo = "Goo"
let g:snip_args = st."\"...\":CleanupArgs(@z)".et
let g:snip_post_args = st."\"...\":PostProcess(CleanupArgs(@z), ', ', '')".et

" common functions "
""""""""""""""""""""
" returns text with all instances of 'pat' removed
function! StripFrom(text, pat)
	return substitute(a:text, a:pat, '', 'g')
endfunction

" returns the number of occurrences of needle in haystack
function! Count(haystack, needle)
	let counter = 0
	let index = match(a:haystack, a:needle)
	while index > -1
		let counter += 1
		let end = matchend(a:haystack, a:needle, index)
		let index = match(a:haystack, a:needle, end)
	endwhile
	return counter
endfunction

" returns the number of contiguous needles in haystack, skipping intermittent poop
" returns 0 unless all of haystack is matched (from start of string to end, by
" either needles or poop)
function! CountSkipping(haystack, needle, poop)
	let counter = 0
	let end = 0
	while 1
		let list = matchlist(a:haystack, '^\('.a:poop.'\)\|^\('.a:needle.'\)', end)
		if empty(list) || list[1].list[2] == '' | break | endif
		if list[1] == ''
			let counter += 1
		endif
		let end = matchend(a:haystack, '^\('.a:poop.'\)\|^\('.a:needle.'\)', end)
	endwhile
	if end != len(a:haystack)
		return 0
	else
		return counter
	endif
endfunction

" returns a list of pat occurrences in str
function! MatchList(str, pat)
	let matches = []
	let end = 0
	while 1
		let mat = matchstr(a:str, a:pat, end)
		if mat == '' | break | endif
		call add(matches, mat)
		let end = matchend(a:str, a:pat, end)
	endwhile
	return matches
endfunction

" returns replacement if text equals match, otherwise returns text
function! ReplaceIfEqual(text, match, replacement)
	if a:text ==# a:match
		return a:replacement
	endif
	return a:text
endfunction

" returns string with all words capitalized
" uses the first argument, or register z if given no arguments
function! CapWords(...)
	if a:0 == 0
		return substitute(@z,  '\w\+', '\u&', 'g')
	else
		return substitute(a:1, '\w\+', '\u&', 'g')
	endif
endfunction

" returns text surrounded by prefix and suffix if it's not empty
function! PostProcess(text, prefix, suffix)
	if a:text != ''
		return a:prefix.a:text.a:suffix
	endif
	return a:text
endfunction

" construct a comma-separated tag list
function! ArgList(count)
	if a:count == 0
		return ''
	endif
	return repeat(', '.g:snip_start_tag.g:snip_end_tag, a:count)
endfunction

" format argument list
function! CleanupArgs(text)
	if a:text == '...'
		return ''
	endif
	let text = substitute(a:text, '\s*,\s*', ', ', 'g')
	let text = substitute(text, '^,*\s*', '', '')
	return     substitute(text, ',*\s\+$', '', '')
endfunction

" get the indent level of a line
function! GetIndentLevel(lnum)
    return indent(a:lnum) / &shiftwidth
endfunction

" given an indent level, return an indent string, taking into account
" 'expandtab', 'shiftwidth', and 'tabstop'
function! ConstructIndent(level)
	if &expandtab
		let tabs   = 0
		let spaces = a:level * &shiftwidth
	else
		let tabs   = a:level * &shiftwidth / &tabstop
		let spaces = a:level * &shiftwidth % &tabstop
	endif
	return repeat('\t', tabs).repeat(' ', spaces)
endfunction

