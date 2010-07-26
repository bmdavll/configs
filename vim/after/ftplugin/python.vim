setl expandtab
setl diffopt-=iwhite

" make
setl makeprg=python\ -c\ \"import\ py_compile;py_compile.compile(r'%')\"\ -t
setl errorformat=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%C^,%C%[%^\ ]%\\@=%m,%Z

" breakpoints
if has('python')

python << EOF
import os
import sys
import vim

# set up path (allowing jumps to library files)
for p in sys.path:
	if os.path.isdir(p):
		vim.command(r"set path+=%s" % p.replace(" ",r"\ "))

# toggle a breakpoint at the current line
def ToggleBreakpoint():
	import re
	strLine = vim.current.line
	if strLine.lstrip()[:15] == 'pdb.set_trace()':
		vim.command('normal dd')
		return
	strWhite = re.search('^(\s*)', strLine).group(1)
	if strWhite == '': return
	nLine = int(vim.eval('line(".")'))
	vim.current.buffer.append(
		"%(space)spdb.set_trace() %(mark)s Breakpoint %(mark)s" %
		{'space':strWhite, 'mark':'#'*20}, nLine-1)
	for strLine in vim.current.buffer:
		if strLine == "import pdb":
			break
	else:
		vim.current.buffer.append('import pdb', 0)
		vim.command('normal j^')

# remove all breakpoints
def RemoveBreakpoints():
	import re
	nCurrentLine = int(vim.eval('line(".")'))
	rmLines = []
	nLine = 0
	for strLine in vim.current.buffer:
		nLine += 1
		if strLine.lstrip().startswith('pdb.set_trace()') or strLine == 'import pdb':
			rmLines.append(nLine)
	rmLines.reverse()
	for nLine in rmLines:
		vim.command('normal %dG' % nLine)
		vim.command('normal dd')
		if nLine < nCurrentLine:
			nCurrentLine -= 1
	vim.command('normal %dG' % nCurrentLine)
EOF

map <buffer> <M-9> <C-\><C-N>:python ToggleBreakpoint()<CR>
map <buffer> <M-0> <C-\><C-N>:python RemoveBreakpoints()<CR>

endif

