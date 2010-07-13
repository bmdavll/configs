if !exists('loaded_snippet') || &cp
	finish
endif

" inherits c_snippets

" header
exec "Snippet inc #include <".se.">"
exec "Snippet incs ".
	\"#include <iostream><CR>".
	\"#include <string><CR>".
	\"#include <vector><CR>".
	\"#include <map><CR>".
	\"#include <algorithm><CR>".
	\se

exec "Snippet ns using namespace ".se.";"

" statements
exec "Snippet fore for (".
			\se.st."i".et." = ".st."v".et.".begin()".
	\"; ".
			\st."i".et." != ".st."v".et.".end()".
	\"; ".
			\"++".st."i".et.
	\")".flexbraces

" exceptions
exec "Snippet try   ".trycatch." (".se.")".sep.bro."}"
exec "Snippet thr   throw ".se."(".se.");"
exec "Snippet thro  throw ".se."(".se.");"
exec "Snippet throw throw ".se."(".se.");"

" operators and keywords
exec "Snippet ,,  << ".se
exec "Snippet ..  >> ".se
exec "Snippet fr  friend ".se
exec "Snippet inl inline ".se
exec "Snippet op  operator".se
exec "Snippet vir virtual ".se

" lib
exec "Snippet ss std::".se
exec "Snippet co cout << ".se
exec "Snippet ce cerr << ".se
exec "Snippet ci cin >> ".se
exec "Snippet en endl;".se

" containers
exec "Snippet st  ".se."::size_type ".se
exec "Snippet it  ".se."::iterator ".se
exec "Snippet cit ".se."::const_iterator ".se
exec "Snippet beg ".st."v".et.".begin(), ".st."v".et.".end()".se

exec "Snippet sort   sort(".se.");"
exec "Snippet vect   vector<".se.">".se
exec "Snippet vecto  vector<".se.">".se
exec "Snippet vector vector<".se.">".se
exec "Snippet ls     list<".se.">".se

" classes
exec "Snippet cl class ".st.g:snip_foo.":CapWords()".et.
	\st."\"base?\":Decorate(substitute(CapWords(CleanupArgs(ReplaceIfEqual(@z, 'base?', ''))), ', ', '\&public ', 'g'), ' : public ', '')".et.
	\fsep.bro."<BS>public:<CR>".st.g:snip_foo.":CapWords()".et."(".args.");".
	\"<CR>~".st.g:snip_foo.":CapWords()".et."();".
	\"<CR>private:<CR>".se.brc.";"
exec "Snippet temp template<class ".se.">".fsep.se

" functions
exec "Snippet outf ostream& operator<<(ostream& out, ".se.")".fsep.bro."return out".se.";".brc
exec "Snippet inf  istream& operator>>(istream& in, ".se.")".fsep.bro."if (in)".sep.braces."<CR>return in;".brc
exec "Snippet me   ".st."int".et." ".se."::".se."(".args.") const".se.fsep.braces
exec "Snippet cr   const ".se."& ".se
