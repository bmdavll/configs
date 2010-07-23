" convert a line such as "ə U+0259 LATIN SMALL LETTER SCHWA" to an XCompose binding
" use bang for canonical bind (<ampersand> <x> <x> <x> <x>)
command! -range -bang -nargs=0 XCompose call s:XCompose(<line1>, <line2>, <bang>0)
function! s:XCompose(line1, line2, bang)
	for line in range(a:line1, a:line2)
		let txt = getline(line)
		let m = matchlist(txt, '\v^(.)\s*(U\+?\x\x\x\x)?\s*#?\s*(.*)')
		if empty(m) | continue | endif
		let m[2] = substitute(m[2], '\vU\+?(\x\x\x\x)', 'U\U\1', '')
		if a:bang && m[2] =~ 'U\x\x\x\x'
			let bind = '<ampersand>'
			for x in split(m[2][1:], '\ze.')
				let bind .= ' <'.tolower(x).'>'
			endfor
		else
			let bind = '<> <>'
		endif
		let txt = "<Multi_key> ".bind."\t\t\t: \"".m[1].'"'.(len(m[2]) ? "\t".m[2] : "").(len(m[3]) ? " # ".m[3] : "")
		call setline(line, txt)
	endfor
endfunction

" switch key order of .XCompose key binding
xmap <silent> <leader>X	:<C-U>let @z=&hls.@/<CR>:set nohls<CR>
						\:'<,'>s/\v^(%(\s*\<\w+\>)+)(\s*\<\w+\>)(\s*\<\w+\>)/\1\3\2/e<CR>
						\:let &hls=@z[0]<CR>:let @/=@z[1:]<CR>:nohlsearch<CR>

