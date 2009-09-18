if !exists('loaded_snippet') || &cp
	finish
endif

runtime after/ftplugin/cbase_*snippets.vim

function! CMacroName(filename)
	return toupper(substitute(a:filename, '\.', '_', 'g'))
endfunction
let macro = "``CMacroName(expand('%'))``_"

" primitives
exec "Snippet N NULL".se

" header
exec "Snippet inc #include <".se.".h>"
exec "Snippet incs ".
	\"#include <stdio.h><CR>".
	\"#include <stdlib.h><CR>".
	\"#include <string.h><CR>".
	\se
exec "Snippet Inc #include \"".se.".h\""
exec "Snippet de #define ".se
exec "Snippet ifn #ifndef ".macro."<CR>".
	\"#define ".macro."<CR><CR>".se."<CR><CR>".
	\"#endif /* ".macro." */"

" lib
exec "Snippet  pf  printf(".                    pf.");"
exec "Snippet fpf fprintf(".st."stderr".et.", ".pf.");"
exec "Snippet spf sprintf(".se.            ", ".pf.");"

exec "Snippet mal malloc(".se.st."sizeof".et.se.");"

" constants
exec "Snippet cons static const ".st."int".et." ".se." = ".se.";"
exec "Snippet enum enum ".se.fbs.braces.";"

" structures
exec "Snippet struc struct ".se.fbs.braces.";"
exec "Snippet type typedef ".se
exec "Snippet union union ".se.fbs.braces.";"

" functions
exec "Snippet fde ".st."int".et." ".se."(".args.");"
exec "Snippet fun ".st."int".et." ".se."(".args.")".fbs.braces

let mainexit = "exit(0);"
exec "Snippet main int main(int argc, char *argv[])".fbs.bo.se.linedown.mainexit.bc
exec "Snippet mainv int main(void)".fbs.bo.se.linedown.mainexit.bc
