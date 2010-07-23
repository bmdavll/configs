if !exists('loaded_snippet') || &cp
	finish
endif

" global snippets {{{1
let st = g:snip_start_tag
let et = g:snip_end_tag
let se = st.et

exec "Iabbr '' \"".se."\""
exec "Iabbr '  '".se."'"
exec "Iabbr jk (".se.")"

let g:snip_foo = "Goo"
let g:snip_args = st."\"...\":CleanupArgs(@z)".et
let g:snip_post_args = st."\"...\":Decorate(CleanupArgs(@z), ', ', '')".et

" common functions {{{1
" returns text with all instances of pat removed
function! StripFrom(text, pat) "{{{2
	return substitute(a:text, a:pat, '', 'g')
endfunction "}}}2

" returns the number of occurrences of needle in haystack
function! Count(haystack, needle) "{{{2
	let counter = 0
	let index = match(a:haystack, a:needle)
	while index > -1
		let counter += 1
		let end = matchend(a:haystack, a:needle, index)
		let index = match(a:haystack, a:needle, end)
	endwhile
	return counter
endfunction "}}}2

" returns the number of contiguous needles in haystack, skipping only
" intermittent poop
" returns 0 unless all of haystack is matched, from start to end, by either
" needles or poop
function! CountSkipping(haystack, needle, poop) "{{{2
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
endfunction "}}}2

" returns a list of pat occurrences in str
function! MatchList(str, pat) "{{{2
	let matches = []
	let end = 0
	while 1
		let mat = matchstr(a:str, a:pat, end)
		if mat == '' | break | endif
		call add(matches, mat)
		let end = matchend(a:str, a:pat, end)
	endwhile
	return matches
endfunction "}}}2

" returns replacement if text equals match, otherwise returns text unchanged
function! ReplaceIfEqual(text, match, replacement) "{{{2
	if a:text ==# a:match
		return a:replacement
	endif
	return a:text
endfunction "}}}2

" returns string with all words capitalized
" uses the first argument, or register z if given no arguments
function! CapWords(...) "{{{2
	if a:0 == 0
		return substitute(@z,  '\w\+', '\u&', 'g')
	else
		return substitute(a:1, '\w\+', '\u&', 'g')
	endif
endfunction "}}}2

" returns text bookended by prefix and suffix, but only if it's non-null
function! Decorate(text, prefix, suffix) "{{{2
	if a:text != ''
		return a:prefix.a:text.a:suffix
	endif
	return a:text
endfunction "}}}2

" construct a comma-separated tag list
function! ArgList(count) "{{{2
	if a:count == 0
		return ''
	endif
	return repeat(', '.g:snip_start_tag.g:snip_end_tag, a:count)
endfunction "}}}2

" format argument list
function! CleanupArgs(text) "{{{2
	if a:text == '...'
		return ''
	endif
	let text = substitute(a:text, '\s*,\+\s*', ', ', 'g')
	let text = substitute(text, '^,*\s*', '', '')
	return     substitute(text, ',*\s*$', '', '')
endfunction "}}}2

" get the indent level of a line
function! IndentLevel(lnum) "{{{2
    return indent(a:lnum) / &shiftwidth
endfunction "}}}2

" given an indent level, return an indent string, taking into account current
" &expandtab, &shiftwidth, and &tabstop
function! ConstructIndent(level) "{{{2
	if &expandtab
		let tabs   = 0
		let spaces = a:level * &shiftwidth
	else
		let tabs   = a:level * &shiftwidth / &tabstop
		let spaces = a:level * &shiftwidth % &tabstop
	endif
	return repeat('\t', tabs).repeat(' ', spaces)
endfunction "}}}2

" vim:set ts=4 sw=4 noet fdm=marker:
