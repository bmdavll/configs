if !exists('snip_c_bracesep')
	if &filetype == "java"
		let g:snip_c_bracesep = " "
	else
		let g:snip_c_bracesep = "<CR>"
	endif
endif

if &filetype == "java"
	let g:snip_c_func_bracesep = "<CR>"
else
	let g:snip_c_func_bracesep = "<CR>"
endif

try
function! s:BraceToggle()
	try
		if g:snip_c_bracesep == " "
			let g:snip_c_bracesep = "<CR>"
			silent edit
			echo "Now using Allman style indents"
		else
			let g:snip_c_bracesep = " "
			silent edit
			echo "Now using K&R style indents"
		endif
	catch /E37/
		echohl WarningMsg | echo "Please save first" | echohl None
	endtry
endfunction
catch /E127/
endtry

nnoremap <silent> <plug>SnippetBraceToggle :call <SID>BraceToggle()<CR>

if !hasmapto('<plug>SnippetBraceToggle', 'n')
	nmap ,b <plug>SnippetBraceToggle
endif

" building blocks
let st = g:snip_start_tag
let et = g:snip_end_tag
let se = st.et

let args = g:snip_args
let bs = g:snip_c_bracesep
let fbs = g:snip_c_func_bracesep
let bo = "{<CR>"
let bc = "<CR>}"
let braces = bo.se.bc
let flexbraces = bs.(bs==" " ? braces : se)
let linedown = "<CR><BS>"
let trycatch = "try".bs.braces.bs."catch"
let pf = "\"".st."\"%s\"".et."\\n".se."\"".st."\"%s\":ArgList(Count(@z, '%[^%]'))".et

" primitives and comments
exec "Snippet [ ".braces
exec "Snippet cc /* ".se." */"
exec "Snippet com /*<CR>".se.linedown."<BS>*/"

" statements
exec "Snippet if if (".se.")".flexbraces
exec "Snippet elif else if (".se.")".flexbraces
exec "Snippet el else".flexbraces
exec "Snippet sw switch (".se.")".bs.bo.(bs==" " ? "<BS>" : "")."case ".se.":<CR>".se.linedown."break;".bc
exec "Snippet for for (".se."; ".se."; ".se.")".flexbraces
exec "Snippet fori for (".
	\(&filetype=="c" ? "" : se).st."i".et." = ".se."; ".
	\st."i".et." < ".se."; ".
	\"++".se.st."i".et.")".flexbraces
exec "Snippet wh while (".se.")".flexbraces

exec "Snippet do do ".braces." while (".se.");"
exec "Snippet case case ".se.":<CR>".se.linedown."break;"
exec "Snippet def default:<CR>".se
exec "Snippet br break".(&filetype=="java" ? se.";" : ";".se)
exec "Snippet con continue".(&filetype=="java" ? se.";" : ";".se)
exec "Snippet ret return".se.";"
