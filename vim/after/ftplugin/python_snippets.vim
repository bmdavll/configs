if !exists('loaded_snippet') || &cp
    finish
endif

" Given a string containing a list of arguments (e.g. "one = 'test', *args,
" **kwargs"), this function returns a string containing only the variable
" names, separated by spaces, e.g. "one two".
function! PyGetVarnamesFromArgs(text)
    let text = substitute(a:text, 'self,*\s*', '',  '')
    let text = substitute(text, '\*\*\?\k\+', '',  'g')
    let text = substitute(text,   '=.\{-},',    '',  'g')
    let text = substitute(text,   '=.\{-}$',    '',  'g')
    let text = substitute(text,   '\s*,\s*',    ' ', 'g')
    if text == ' '
        return ''
    endif
    return text
endfunction

" returns the current indent as a string
function! PyGetIndentString()
    if &expandtab
        let tabs   = indent('.')/&shiftwidth
		let extra  = 0
        let tabstr = repeat(' ', &shiftwidth)
    else
        let tabs   = indent('.')/&tabstop
		let extra  = indent('.')%&tabstop
        let tabstr = '\t'
    endif
    return repeat(tabstr, tabs).repeat(' ', extra)
endfunction

" Given a string containing a list of arguments (e.g. "one = 'test', *args,
" **kwargs"), this function returns them formatted correctly for the
" docstring.
function! PyGetDocstringFromArgs(text)
    let text = PyGetVarnamesFromArgs(a:text)
    if a:text == 'args' || text == ''
        return ''
    endif
    let indent  = PyGetIndentString()
    let st      = g:snip_start_tag
    let et      = g:snip_end_tag
    let docvars = map(split(text), 'v:val." -- ".st.et')
    return '\n'.indent.join(docvars, '\n'.indent).'\n'.indent
endfunction

" Given a string containing a list of arguments (e.g. "one = 'test', *args,
" **kwargs"), this function returns them formatted as a variable assignment in
" the form "self._ONE = ONE", as used in class constructors.
function! PyGetVariableInitializationFromVars(text)
    let text = PyGetVarnamesFromArgs(a:text)
    if a:text == 'args' || text == ''
        return ''
    endif
    let indent      = PyGetIndentString()
    let st          = g:snip_start_tag
    let et          = g:snip_end_tag
    let assert_vars = map(split(text), '"assert ".v:val." ".st.et')
    let assign_vars = map(split(text), '"self._".v:val." = ".v:val')
    let assertions  = join(assert_vars, '\n'.indent)
    let assignments = join(assign_vars, '\n'.indent)
    return assertions.'\n'.indent.assignments.'\n'.indent
endfunction

" Given a string containing a list of arguments (e.g. "one = 'test', *args,
" **kwargs"), this function returns them with the default arguments removed.
function! PyStripDefaultValue(text)
    return substitute(a:text, '=.*', '', 'g')
endfunction

let st = g:snip_start_tag
let et = g:snip_end_tag
let cd = g:snip_elem_delim

" Note to users: The following method of defining snippets is to allow for
" changes to the default tags.
" Feel free to define your own as so:
"    Snippet mysnip This is the expansion text.<{}>
" There is no need to use exec if you are happy to hardcode your own start and
" end tags

" Properties, setters and getters.
exec "Snippet prop ".st."attribute".et." = property(get_".st."attribute".et.", set_".st."attribute".et.st.et.")<CR>".st.et
exec "Snippet get def get_".st."name".et."(self):<CR>return self._".st."name".et."<CR>".st.et
exec "Snippet set def set_".st."name".et."(self, ".st."value".et."):
\<CR>self._".st."name".et." = ".st."value:PyStripDefaultValue(@z)".et."
\<CR>".st.et

" Functions and methods.
exec "Snippet defs def ".st."fname".et."(".st."args:CleanupArgs(@z)".et."):
\<CR>\"\"\"
\<CR>".st.et."
\<CR>".st."args:PyGetDocstringFromArgs(@z)".et."\"\"\"
\<CR>".st."pass".et."
\<CR>".st.et

" Class definition.
exec "Snippet cls class ".st."ClassName".et."(".st."object".et."):
\<CR>\"\"\"
\<CR>This class represents ".st.et."
\<CR>\"\"\"
\<CR>
\<CR>def __init__(self, ".st."args:CleanupArgs(@z)".et."):
\<CR>\"\"\"
\<CR>Constructor.
\<CR>".st."args:PyGetDocstringFromArgs(@z)".et."\"\"\"
\<CR>".st."args:PyGetVariableInitializationFromVars(@z)".et.st.et

" Unit tests.
exec "Snippet unittest if __name__ == '__main__':
\<CR>import unittest
\<CR>
\<CR>class ".st."ClassName".et."Test(unittest.TestCase):
\<CR>def setUp(self):
\<CR>".st."pass".et."
\<CR>
\<CR>def runTest(self):
\<CR>".st.et
