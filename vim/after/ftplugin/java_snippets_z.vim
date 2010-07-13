if !exists('loaded_snippet') || &cp
	finish
endif

runtime after/plugin/global_snippets.vim
runtime after/ftplugin/cbase_snippets*.vim

" comments
exec "Snippet jcom /**<CR>".se."<CR><CR>@param<Tab>".se."<CR>@return<Tab>".se.linedown."<BS>*/"

" header
exec "Snippet pac package ".se."\.".se.";"
exec "Snippet imp import ".st."java".et."\.".se."\.".se.";"

" statements
exec "Snippet fore  for (".st."Object".et." ".st."o".et." : ".se.")".flexbraces
exec "Snippet foren for (Enumeration ".st."e".et." = ".se.".elements(); ".st."e".et.".hasMoreElements();)".
	\sep.bro.se.st."e".et.".nextElement()".se.brc

" exceptions
exec "Snippet try   ".trycatch." (".st."Exception".et." ".st."e".et.")".sep.bro."}"
exec "Snippet tryc  ".trycatch." (".st."Exception".et." ".st."e".et.")".sep.
	\bro.st."e".et.".printStackTrace();".se.brc
exec "Snippet fin   finally".sep.braces
exec "Snippet fina  finally".sep.braces
exec "Snippet final finally".sep.braces
exec "Snippet thr   throw new ".st."Exception".et."(".se.");"
exec "Snippet thro  throw new ".st."Exception".et."(".se.");"
exec "Snippet throw throw new ".st."Exception".et."(".se.");"

" lib
exec "Snippet pf  System.out.printf(".pf.");"
exec "Snippet out System.out.println(\"".se."\"".se.");"
exec "Snippet err System.err.println(\"".se."\"".se.");"

" keywords and variables
exec "Snippet bool boolean ".se
exec "Snippet pu   public ".se
exec "Snippet pv   private ".se
exec "Snippet pr   protected ".se
exec "Snippet st   static ".se
exec "Snippet cons static final ".st."int".et." ".se." = ".se.";"

" classes
exec "Snippet enum enum ".se.fsep.braces
exec "Snippet cl   class ".st.g:snip_foo.":CapWords()".et.
	\st."\"extends?\":Decorate(CapWords(ReplaceIfEqual(@z, 'extends?', '')), ' extends ', '')".et.
	\st."\"implements?\":Decorate(CapWords(ReplaceIfEqual(@z, 'implements?', '')), ' implements ', '')".et.
	\fsep.bro.st.g:snip_foo.":CapWords()".et."(".args.")".fsep.bro."}".brc

" methods
exec "Snippet me   static ".se.st."void".et." ".se."(".args.")".fsep.braces
exec "Snippet main public static void main(String[] args)".fsep.bro.se.linedown."System.exit(0);".brc
