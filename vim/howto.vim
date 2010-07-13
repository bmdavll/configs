" dereference variables
let var_foo = 0
echomsg var_foo == var_{'foo'}

" passing scope, bang
command! -bang Foo call s:Foo('b', <bang>0)
fun! s:Foo(scope, bang)
	let name = 'foo'
	let var = a:scope.':'.name
	if a:bang
		let {var} = 1
	else
		let {var} = 0
	endif
	" b:foo is now either 1 or 0, depending on bang
	echo {var}
endfun

" switch key order of .XCompose key binding
xmap<silent><leader>X		:<C-U>let @z=&hls.@/<CR>:set nohls<CR>
							\:'<,'>s/\v^(\<\w+\>)(%(\s*\<\w+\>)*)(\s*\<\w+\>)/\1\3\2/e<CR>
							\:let @/=@z[1:]<CR>:let &hls=@z[0]<CR>

