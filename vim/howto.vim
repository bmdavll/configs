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

