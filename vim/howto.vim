var_foo == var_{"foo"}

command! -nargs=+ -bang Foo call s:Foo('b' or 'g', <bang>0)
fun! s:Foo(scope, bang)
	let var = a:scope.':'.name
	let {var} = []
endfun
