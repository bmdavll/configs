if !exists('loaded_snippet') || &cp
	finish
endif

runtime after/plugin/global_snippets.vim

let st = g:snip_start_tag
let et = g:snip_end_tag
let se = st.et

let s:args = g:snip_args
let s:pargs = g:snip_post_args

function! PyArgList(count, prefix)
	if a:count == 0
		return ''
	endif
	return a:prefix.'('.g:snip_start_tag.g:snip_end_tag.ArgList(a:count-1).')'
endfunction

function! PyGetoptReset()
	let g:snip_py_getopt = 0
	return ''
endfunction

function! PyGetLongOptsList(text)
	let arglist = split(substitute(a:text, "[\"']\\|\\s\\+", '', 'g'), ',')
	call map(arglist, "substitute(v:val, '^--', '', '')")
	return filter(arglist, "v:val !~ '^=\\?$'")
endfunction

function! PyQuoteLongOpts(args)
	return join(map(PyGetLongOptsList(a:args), "\"'\".v:val.\"'\""), ', ')
endfunction

function! PyGetoptSwitchString(optlist, dashes, nl)
	let str = ''
	let indent = ConstructIndent(IndentLevel('.'))
	let len = len(a:optlist)
	for i in range(len)
		let str .= (g:snip_py_getopt==0 ? "" : "el").
					\"if opt == '".a:dashes.a:optlist[i]."':".
					\(a:nl || i < len-1 ? "\n".indent : "")
		let g:snip_py_getopt += 1
	endfor
	return str
endfunction

function! PyProcessShortOpts(opts)
	let optlist = map(MatchList(a:opts, '\w:\?'), 'strpart(v:val, 0, 1)')
	return PyGetoptSwitchString(optlist, '-', 1)
endfunction

function! PyProcessLongOpts(opts)
	let optlist = map(PyGetLongOptsList(a:opts), "substitute(v:val, '=$', '', '')")
	return PyGetoptSwitchString(optlist, '--', 0)
endfunction

function! PyOptparse(opt, type)
	if a:opt == '' | return '' | endif
	let opt = substitute(a:opt, '^-\+', '', '')
	if a:type == '-'
		let opt = strpart(opt, 0, 1)
	endif
	let opt = a:type.opt
	return '"'.opt.'", '
endfunction

" primitives
exec "Snippet T    True".se
exec "Snippet Tr   True".se
exec "Snippet Tru  True".se
exec "Snippet F    False".se
exec "Snippet Fa   False".se
exec "Snippet Fal  False".se
exec "Snippet Fals False".se
exec "Snippet N    None".se
exec "Snippet No   None".se
exec "Snippet Non  None".se
exec "Snippet [    [ ".se." ]"
exec "Snippet doc  \"\"\"<CR>".se."<CR>\"\"\""
exec "Snippet com  \"\"\"<CR>".se."<CR>\"\"\""

" header
exec "Snippet sb  #!/usr/bin/env python<CR>".se
exec "Snippet sbu #!/usr/bin/env python<CR># -*- coding: utf-8 -*-<CR>".se
exec "Snippet sbl #!/usr/bin/env python<CR># -*- coding: latin-1 -*-<CR>".se

exec "Snippet imp  import ".se
exec "Snippet from from ".se." import ".se

" statements
exec "Snippet if     if ".se.":<CR>".se
exec "Snippet eli    elif ".se.":<CR>".se
exec "Snippet elif   elif ".se.":<CR>".se
exec "Snippet el     else:<CR>".se
exec "Snippet els    else:<CR>".se
exec "Snippet else   else:<CR>".se
exec "Snippet wh     while ".se.":<CR>".se
exec "Snippet whi    while ".se.":<CR>".se
exec "Snippet whil   while ".se.":<CR>".se
exec "Snippet while  while ".se.":<CR>".se
exec "Snippet for    for ".se." in ".se.":<CR>".se
exec "Snippet with   with ".se." as ".se.":<CR>".se
exec "Snippet lam    lambda ".s:args.": ".se
exec "Snippet lamb   lambda ".s:args.": ".se
exec "Snippet lambd  lambda ".s:args.": ".se
exec "Snippet lambda lambda ".s:args.": ".se

" keywords
exec "Snippet br   break".se
exec "Snippet con  continue".se
exec "Snippet cont continue".se
exec "Snippet ret  return ".se
exec "Snippet yi   yield ".se
exec "Snippet glob global ".se
exec "Snippet ass  assert ".se

" exceptions
let s:except = "except ".st."Exception".et.
	\st."\"as?\":Decorate(ReplaceIfEqual(@z, 'as?', ''), ' as ', '')".et.
	\":<CR>".se
exec "Snippet try    try:<CR>".se."<CR>".s:except
exec "Snippet tryf   try:<CR>".se."<CR>finally:<CR>".se
exec "Snippet exc    ".s:except
exec "Snippet exce   ".s:except
exec "Snippet excep  ".s:except
exec "Snippet except ".s:except
exec "Snippet fin    finally:<CR>".se
exec "Snippet fina   finally:<CR>".se
exec "Snippet final  finally:<CR>".se
exec "Snippet rai    raise ".st."Exception".et."(".s:args.")".se
exec "Snippet rais   raise ".st."Exception".et."(".s:args.")".se
exec "Snippet raise  raise ".st."Exception".et."(".s:args.")".se

" builtins
exec "Snippet pr  print(".se.")"
exec "Snippet fpr print(".se.", file=".st."\"sys.stderr\"".et.")"
exec "Snippet sep sep='".se."'".se
exec "Snippet end end='".se."'".se
exec "Snippet pf  '".st."\"%s\"".et."'".st."\"%s\":PyArgList(Count(@z, '%[^%]'), ' % ')".et.se

let s:fmt = '{[^{}]\+\%(:\%({[^{}]\+}\|[^{}]\+\)\+\)\?}'
let s:notfmt = '[^{}]\+\|{{\|}}'
exec "Snippet fmt '".st."\"{0}\"".et."'".st.
	\"\"{0}\":PyArgList(CountSkipping(@z, '".s:fmt."', '".s:notfmt."'), '.format')".et

exec "Snippet ran   range(".se.")"
exec "Snippet rang  range(".se.")"
exec "Snippet range range(".se.")"
exec "Snippet enum  enumerate(".se.")"
exec "Snippet rev   reversed(".se.")"
exec "Snippet sort  sorted(".se.")"
exec "Snippet tup   tuple(".se.")"

" classes
exec "Snippet cl class ".st.g:snip_foo.":CapWords()".et.
	\st."\"base?\":Decorate(CapWords(CleanupArgs(ReplaceIfEqual(@z, 'base?', ''))), '(', ')')".et.
	\":<CR><CR>".
	\"def __init__(self".s:pargs."):<CR>".se

" option parsing
exec "Snippet opt from optparse import OptionParser<CR><CR>".
	\st."\"__prog__\"".et." = os.path.basename(".st."\"sys.argv\"".et."[0])<CR>".
	\st."\"__version__\"".et." = \"".st.et."\"<CR>".
	\st."\"__usage__\"".et." = \"Usage: %prog [options]".st.et."\"<CR>".
	\st."parser".et." = OptionParser(prog=".st."\"__prog__\"".et.", version=\"%prog \"+".st."\"__version__\"".et.
	\", usage=".st."\"__usage__\"".et.
	\st."description:Decorate(ReplaceIfEqual(@z, 'description', ''), ', description=', '')".et.")<CR>".
	\"<CR>".st."opts".et.", ".st."args".et." = ".st."parser".et.".parse_args(".st."\"sys.argv\"".et."[1:])<CR>"
exec "Snippet addopt ".st."parser".et.".add_option(".
	\st."\"-\":PyOptparse(ReplaceIfEqual(@z, '-', ''), '-')".et.
	\st."\"--\":PyOptparse(ReplaceIfEqual(@z, '--', ''), '--')".et.
	\st."metavar:Decorate(StripFrom(ReplaceIfEqual(@z, 'metavar', ''), \"\\\\(^[\\\"']\\\\|[\\\"']$\\\\)\"), 'metavar=\"', '\", ')".et.
	\st."dest:Decorate(StripFrom(ReplaceIfEqual(@z, 'dest', ''), \"\\\\(^[\\\"']\\\\|[\\\"']$\\\\)\"), 'dest=\"', '\", ')".et.
	\st."default:Decorate(ReplaceIfEqual(@z, 'default', ''), 'default=', ', ')".et.
	\"<CR><Tab><Tab><Space><Space>help='".st.et."')"
exec "Snippet addgrp group = OptionGroup(".st."parser".et.", \"".st.et."\", \"".st."Description".et."\")<CR>".
	\"<CR>".st."parser".et.".add_option_group(group)"
exec "Snippet action action=\"".st."store".et."\", ".
	\st."type:Decorate(StripFrom(ReplaceIfEqual(@z, 'type', ''), \"\\\\(^[\\\"']\\\\|[\\\"']$\\\\)\"), 'type=\"', '\", ')".et

" if there are no long options, replace "help" with a comma
exec "Snippet getopt import getopt<CR><CR>".
	\"try:<CR>``PyGetoptReset()``".
	\"opts, ".st."args".et." = getopt.getopt(".st."\"sys.argv\"".et."[1:], ".
	\"'".st."\"h?\":ReplaceIfEqual(@z, 'h?', '')".et."', ".
	\"[".st."help:Decorate(PyQuoteLongOpts(@z), ' ', ' ')".et."])<CR>".
	\"for opt, val in opts:<CR>".
	\st."\"h?\":PyProcessShortOpts(ReplaceIfEqual(@z, 'h?', ''))".et.
	\st."help:PyProcessLongOpts(@z)".et."<CR>".
	\"except getopt.GetoptError:<CR>".
	\st."Usage".et."()<CR>".
	\st."\"sys.exit\"".et.st."\"(2)\"".et."<CR><BS>".se

" functions
exec "Snippet def  def ".se."(".s:args."):<CR>".se
exec "Snippet me   def ".se."(self".s:pargs."):<CR>".se
exec "Snippet op   def __".st."eq".et."__(self".s:pargs."):<CR>".se
exec "Snippet clm  @classmethod<CR>def ".se."(cls".s:pargs."):<CR>".se
exec "Snippet stm  @staticmethod<CR>def ".se."(".s:args."):<CR>".se
exec "Snippet main import sys<CR><CR>def main(argv=None):<CR>if argv is None:<CR>argv = sys.argv<CR><BS>".
	\se."<CR><CR><BS>if __name__ == '__main__':<CR>sys.exit(main())"

" custom
exec "Snippet db Debug(".st.et.")"
