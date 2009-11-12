if !exists('loaded_snippet') || &cp
	finish
endif

runtime after/ftplugin/cbase_*snippets.vim

" comments
exec "Snippet jcom /**<CR>".se."<CR><CR>@param<Tab>".se."<CR>@return<Tab>".se.linedown."<BS>*/"

" header
exec "Snippet pac package ".se."\.".se.";"
exec "Snippet imp import ".st."java".et."\.".se."\.".se.";"

" statements
exec "Snippet fore for (".st."Object".et." ".st."o".et." : ".se.")".flexbraces
exec "Snippet foren for (Enumeration ".st."e".et." = ".se.".elements(); ".st."e".et.".hasMoreElements();)".
	\bs.bo.se.st."e".et.".nextElement()".se.bc

" exceptions
exec "Snippet try  ".trycatch." (".st."Exception".et." ".st."e".et.")".bs.bo."}"
exec "Snippet tryc ".trycatch." (".st."Exception".et." ".st."e".et.")".bs.
	\bo.st."e".et.".printStackTrace();".se.bc
exec "Snippet fin finally".bs.braces
exec "Snippet thr throw new ".st."Exception".et."(".se.");"

" lib
exec "Snippet pf  System.out.printf(".pf.");"
exec "Snippet out System.out.println(\"".se."\"".se.");"
exec "Snippet err System.err.println(\"".se."\"".se.");"

" keywords and variables
exec "Snippet bool boolean ".se
exec "Snippet pu public ".se
exec "Snippet pv private ".se
exec "Snippet pr protected ".se
exec "Snippet st static ".se
exec "Snippet cons static final ".st."int".et." ".se." = ".se.";"

" classes
exec "Snippet enum enum ".se.fbs.braces
exec "Snippet cl class ".st.g:snip_foo.":CapWords()".et.
	\st."\"extends?\":PostProcess(CapWords(ReplaceIfEqual(@z, 'extends?', '')), ' extends ', '')".et.
	\st."\"implements?\":PostProcess(CapWords(ReplaceIfEqual(@z, 'implements?', '')), ' implements ', '')".et.
	\fbs.bo.st.g:snip_foo.":CapWords()".et."(".args.")".fbs.bo."}".bc

" methods
exec "Snippet me static ".se.st."void".et." ".se."(".args.")".fbs.braces
exec "Snippet main public static void main(String[] args)".fbs.bo.se.linedown."System.exit(0);".bc
