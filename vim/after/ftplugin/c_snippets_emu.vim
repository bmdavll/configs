if !exists('loaded_snippet') || &cp
	finish
endif

runtime after/plugin/global_snippets.vim
runtime after/ftplugin/cbase_snippets*.vim

function! CMacroName(filename)
	return toupper(substitute(a:filename, '\.', '_', 'g'))
endfunction
let s:macro = "``CMacroName(expand('%'))``_"

" primitives
exec "Snippet N NULL".se

" header
exec "Snippet inc #include <".se.".h>"
exec "Snippet Inc #include \"".se.".h\""
exec "Snippet def #define ".se
exec "Snippet ifn #ifndef ".s:macro."<CR>".
	\"#define ".s:macro."<CR><CR>".se."<CR><CR>".
	\"#endif /* ".s:macro." */"
exec "Snippet incs ".
	\"#include <stdio.h><CR>".
	\"#include <stdlib.h><CR>".
	\"#include <string.h><CR>".
	\se

" lib
exec "Snippet pf  printf(".pf.");"
exec "Snippet fpf fprintf(".st."stderr".et.", ".pf.");"
exec "Snippet spf sprintf(".se.", ".pf.");"

exec "Snippet mal malloc(".se.st."sizeof".et.se.");"

" constants
exec "Snippet cons static const ".st."int".et." ".se." = ".se.";"
exec "Snippet enum enum ".se.fsep.braces.";"

" structures
exec "Snippet stru   struct ".se.fsep.braces.";"
exec "Snippet struc  struct ".se.fsep.braces.";"
exec "Snippet struct struct ".se.fsep.braces.";"
exec "Snippet uni    union ".se.fsep.braces.";"
exec "Snippet unio   union ".se.fsep.braces.";"
exec "Snippet union  union ".se.fsep.braces.";"

" functions
exec "Snippet fun  ".st."int".et." ".se."(".args.")"

let s:exit = "exit(0);"
exec "Snippet main  int main(int argc, char *argv[])".fsep.bro.se.linedown.s:exit.brc
exec "Snippet mainv int main(void)".fsep.bro.se.linedown.s:exit.brc
