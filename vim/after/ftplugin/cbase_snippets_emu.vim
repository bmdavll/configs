let g:snip_c_func_bracesep = "<CR>"

if &filetype == "java"
	let g:snip_c_bracesep = " "
else
	let g:snip_c_bracesep = "<CR>"
endif

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

nnoremap <silent> <plug>SnippetBraceToggle :call <SID>BraceToggle()<CR>

if !hasmapto('<plug>SnippetBraceToggle', 'n')
	nmap ,b <plug>SnippetBraceToggle
endif

" building blocks
let st = g:snip_start_tag
let et = g:snip_end_tag
let se = st.et

let args = g:snip_args
let sep = g:snip_c_bracesep
let fsep = g:snip_c_func_bracesep
let bro = "{<CR>"
let brc = "<CR>}"
let braces = bro.se.brc
let flexbraces = sep.(sep==" " ? braces : se)
let linedown = "<CR><BS>"
let trycatch = "try".sep.braces.sep."catch"
let pf = "\"".st."\"%s\"".et."\\n".se."\"".st."\"%s\":ArgList(Count(@z, '%[^%]'))".et

" primitives and comments
exec "Snippet [   ".braces
exec "Snippet cc  /* ".se." */"
exec "Snippet com /*<CR>".se.linedown."<BS>*/"

" statements
exec "Snippet if   if (".se.")".flexbraces
exec "Snippet eli  else if (".se.")".flexbraces
exec "Snippet elif else if (".se.")".flexbraces
exec "Snippet el   else".flexbraces
exec "Snippet els  else".flexbraces
exec "Snippet else else".flexbraces

let s:switch = "switch (".se.")".sep.bro.(sep==" " ? "<BS>" : "")."case ".se.":<CR>".se.linedown."break;".linedown."default:".brc
exec "Snippet sw     ".s:switch
exec "Snippet swi    ".s:switch
exec "Snippet swit   ".s:switch
exec "Snippet switc  ".s:switch
exec "Snippet switch ".s:switch
exec "Snippet wh     while (".se.")".flexbraces
exec "Snippet whi    while (".se.")".flexbraces
exec "Snippet whil   while (".se.")".flexbraces
exec "Snippet while  while (".se.")".flexbraces
exec "Snippet for    for (".se."; ".se."; ".se.")".flexbraces
exec "Snippet fori   for (".
			\(&filetype=="c" ? "" : se).st."i".et." = ".se.
	\"; ".
			\st."i".et." < ".se.
	\"; ".
			\"++".se.st."i".et.
	\")".flexbraces

if &filetype == "java"
	let s:break_arg = 1
else
	let s:break_arg = 0
endif
exec "Snippet do   do ".braces." while (".se.");"
exec "Snippet case case ".se.":<CR>".se.linedown."break;"
exec "Snippet br   break".(s:break_arg ? se.";" : ";".se)
exec "Snippet con  continue".(s:break_arg ? se.";" : ";".se)
exec "Snippet cont continue".(s:break_arg ? se.";" : ";".se)
exec "Snippet ret  return".se.";"
