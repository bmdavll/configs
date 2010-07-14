" Vim 7.2 vimrc
" Section: encoding {{{1
scriptencoding utf-8

" global encoding
if has('multi_byte')
	if $LANG !~ '\.' || $LANG =~? '\.UTF-\?8$'
		set encoding=utf-8
	else
		let &encoding = matchstr($LANG, '\.\zs.*')
		let &fileencodings = 'ucs-bom,utf-8,' . &encoding
	endif
endif

" Section: options {{{1
" interface {{{2
set nocompatible		" use vim settings instead of vi settings
set mouse=a				" enable mouse in all modes
set noinsertmode		" enforce in case of EZ-mode
set visualbell t_vb=	" disable bell
" tabs {{{2
set noexpandtab			" whether to expand tabs into spaces
set tabstop=4			" number of spaces for tab character
set shiftwidth=4		" number of spaces for autoindent and soft tab stops
" window {{{2
set scrolloff=3			" minimum lines of buffer when vertically scrolling
set sidescroll=1		" redraw with every column when side scrolling
set winminheight=0		" fully minimize split windows
set winminwidth=0		" fully minimize vertically split windows
set cmdwinheight=12		" set command-line window height
set cmdheight=1			" number of command lines
set showcmd				" display incomplete commands
set ruler				" show the cursor position at all times
set number				" show line numbers by default
set numberwidth=1		" only use as much space as needed for line numbers
set shortmess=atToOI	" abbreviate file messages
" search {{{2
set incsearch			" do incremental searching
set ignorecase			" ignore case for search patterns
						" (override with \C anywhere in a search pattern)
set smartcase			" don't ignore case for patterns with uppercase chars
set hlsearch			" highlight search pattern matches
" display {{{2
set nowrap				" don't wrap lines by default
set listchars=tab:▏\ ,precedes:‹,extends:›
						" display characters for tabs and extended lines
let &showbreak = "\u21aa "
						" display character for wrapped lines
set linebreak			" don't break mid-word when wrapping
" control {{{2
set whichwrap=b,<,>,[,] " move freely between lines
set virtualedit=block	" allow virtual selection in blockwise visual mode
set timeoutlen=666		" milliseconds before mapped key sequences time out
" editing {{{2
set formatoptions+=r	" auto insert comment leader
set formatoptions+=n	" recognize numbered lists when formatting
set backspace=2			" allow backspacing over everything in insert mode
" vim {{{2
set updatetime=1000		" interval for CursorHold updates and swap file writes
set nobackup			" do not keep a backup file
set history=1000		" lines of command line history to keep
set viminfo='50,s100,h	" settings for vim cache
set sessionoptions=curdir,folds,tabpages,winsize,localoptions
						" what to save with mksession
set cpoptions+=>		" put a line break before appending to a register
set diffopt+=iwhite		" ignore whitespace in diff mode
set foldmethod=indent	" define folds automatically based on indent level
" completion {{{2
set complete-=i			" don't scan included files for completion options
set completeopt+=longest
						" complete to the longest common match in insert mode
set wildmenu			" enhanced command-line completion menu
set wildcharm=<C-Z>		" character for command-line completion in mappings
set wildignore+=*.o		" files to ignore for filename completion
set wildignore+=*.class
set wildignore+=*.pyc

" win32 {{{2
if !has('gui_win32')
	" directories for swap files
	set directory=~/tmp//,.,/var/tmp//,/tmp//
	" don't source interactive scripts
	set shell=env\ TERM=dumb\ $SHELL
	" use login shell (read .profile)
	set shellcmdflag=-lc
else
	set directory=~//,.
endif

" Section: gui {{{1
if has('gui_running')
	" options {{{2
	set mousemodel=popup		" use popup menu when right-clicking
	set guicursor=a:blinkon0	" disable cursor blinking
	set guioptions-=m			" disable menu bar and toolbar
	set guioptions-=T
	set guioptions+=c			" use console dialogs

	if hostname() ==# "perro"
		set guioptions-=e		" disable gui tabs
		set guioptions-=L		" disable left scrollbar
	else
		set cursorline			" enable current line highlighting
	endif

	" font {{{2
	function! <SID>SetGUIFont(font)
		if has('gui_win32') || has('gui_mac')
			let sep = ':h'
		else
			let sep = ' '
		endif
		exec 'set guifont='.escape(a:font[0].sep.string(a:font[1]), ' ')
	endfunction

	" display font (:set guifont=* to select interactively)
	if has('gui_win32')
		let g:font_select = [ ['Consolas', 9], ['DejaVu Sans Mono', 8] ]
	else
		let g:font_select = [ ['DejaVu Sans Mono', 9], ['Consolas', 10.5] ]
	endif
	let g:font_index = 0
	call <SID>SetGUIFont(g:font_select[g:font_index])

	" pop-up balloon evaluation {{{2
	function! MyBalloonEval()
		let beval = <SID>PlugBalloonEval()
		if beval != '' | return beval | endif
		" tooltips for spelling suggestions and folds
		let size = 6
		let lines = []
		let foldStart = foldclosed(v:beval_lnum)
		let foldEnd = foldclosedend(v:beval_lnum)
		if foldStart < 0
			" try to find misspelling
			let lines = spellsuggest(spellbadword(v:beval_text)[0], size, 0)
		else
			let numLines = foldEnd - foldStart + 1
			" if too many lines in fold, show only first and last 'size' lines
			if numLines > size*2
				let lines = getline(foldStart, foldStart + (size-1))
				let lines += [ "+----- " . (numLines - size*2) . " lines -----" ]
				let lines += getline(foldEnd - (size-1), foldEnd)
			else
				let lines = getline(foldStart, foldEnd)
			endif
		endif
		return join(lines, has('balloon_multiline') ? "\n" : " ")
	endfunction
	set balloonexpr=MyBalloonEval()
	set balloondelay=250
	set ballooneval
	" }}}
endif

" Section: terminal {{{1
if !has('gui_running')
	set ttimeoutlen=50			" timeout for terminal keycodes (in ms)
	" emenu access
	source $VIMRUNTIME/menu.vim

	" keycodes {{{
	if &term =~ 'xterm'
		" unset vim keycodes
		set <Help>=
		set <Undo>=
		" associate terminal keycodes with vim keycodes
		exec "set <F1>=\eO1;*P"
		exec "set <F2>=\eO1;*Q"
		exec "set <F3>=\eO1;*R"
		exec "set <F4>=\eO1;*S"
		" exec "set <F1>=\e[1;*P"
		" exec "set <F2>=\e[1;*Q"
		" exec "set <F3>=\e[1;*R"
		" exec "set <F4>=\e[1;*S"
		exec "set <F13>=\e[25;*~"
		exec "set <F14>=\e[26;*~"
	endif

	" map <C-Space>
	map  <Nul> <C-Space>
	map! <Nul> <C-Space>

	" fast keycodes for <M-key> {{{
	" http://vim.wikia.com/wiki/Mapping_fast_keycodes_in_terminal_Vim
	" makes use of unused vim keycodes <[S-]F15> to <[S-]F37>.
	let s:i = 0

	" Meta sends <Esc> prefix
	" only catch used Meta combos to prevent breaking macros containing
	" <Esc> followed by a mapped character; i.e. not
	"   let s:keys = []
	"   let s:c = char2nr('a')
	"   for s:n in range(25)
	"   	call add(s:keys, nr2char(s:c+s:n))
	"   endfor
	let s:keys = [ 'a', 'x', 'c', 'v', 'h', 'j', 'k', 'l', 'p', 'n',
				\  'b', 'f', 'd', 'r', 'y',                '/', '?',
				\  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' ]
	for s:k in range(len(s:keys))
		if s:i == 46 | break | endif
		exec "set  <".(s:i/23==0 ? '' : 'S-')."F".(15+s:i%23)."> =\e".s:keys[s:k]
		exec "map  <".(s:i/23==0 ? '' : 'S-')."F".(15+s:i%23)."> <M-".s:keys[s:k].">"
		exec "map! <".(s:i/23==0 ? '' : 'S-')."F".(15+s:i%23)."> <M-".s:keys[s:k].">"
		let s:i += 1
	endfor " }}}
	" }}}
endif

" Section: colors {{{1
if has('gui_running') || &t_Co > 2
	" enable syntax highlighting
	syntax on

	function! <SID>SetColorScheme(color) " {{{
		set background=dark
		try
			exec "colorscheme" a:color
		catch
			return
		endtry
		" custom highlighting for color schemes {{{
		if g:colors_name == 'desert256'
			hi Normal ctermbg=234 guibg=#1c1c1c
			hi Cursor guifg=#222222
			hi LineNr ctermbg=233 guibg=#121212
			hi! link NonText LineNr
			hi SpecialKey ctermfg=240 ctermbg=235 guifg=#585858 guibg=#262626
			hi CursorLine cterm=NONE ctermbg=236 guibg=#303030
			hi! link CursorColumn CursorLine
			hi Search ctermfg=darkcyan ctermbg=18 guifg=#87ceeb guibg=#000087
		elseif g:colors_name == 'zenburn'
			hi Normal ctermbg=237 guibg=#3a3a38
			hi Cursor guifg=#081220 guibg=#ecee90 gui=NONE
			hi MatchParen guifg=#ecee90 guibg=#081220 gui=bold
			hi Statement gui=bold
			hi Todo ctermfg=240 ctermbg=Yellow guifg=#585858 guibg=Yellow
			hi! link NonText LineNr
			hi SpecialKey ctermfg=241 ctermbg=237 guifg=#626262 guibg=#363634
			hi CursorLine cterm=NONE gui=NONE
			hi! link CursorColumn CursorLine
			hi Search ctermbg=22 guifg=#ecee90 guibg=#105f00
		endif " }}}
		" highlighting for ColumnMarker
		hi RightMargin ctermbg=239 guibg=#4e4e4e
	endfunction " }}}

	" hack: assume xterm has 256 colors
	if &term =~ 'xterm' && &t_Co > 2 | set t_Co=256 | endif

	" color schemes from ~/.vim/colors
	let g:colors_select = [ 'wombat256', 'zenburn', 'desert256' ]

	" set the default color scheme
	call <SID>SetColorScheme(g:colors_select[0])
endif

" Section: autocommands {{{1
if !has('autocmd')
	" always set autoindenting on
	set autoindent
else
	" enable file type detection
	" use the default filetype settings, so that mail gets 'tw' set to 72,
	" 'cindent' is on in C files, etc
	" also load indent files for language-dependent indenting
	filetype plugin indent on

	" default group {{{2
	augroup vimrc
		au!
		" don't auto-split lines
		au BufReadPre  * set textwidth=0

		" restore cursor position, except when the position is invalid or
		" when inside an event handler (when dropping a file on gvim)
		au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

		" open all folds
		au BufReadPost * normal! zR

		" enable soft tab stops
		au BufWinEnter * let &softtabstop=&shiftwidth

		" reading Word documents
		" au BufReadPre  *.doc set readonly
		" au BufReadPost *.doc %! antiword "%"
	augroup END

	" automatically enter hex mode and handle file writes properly {{{2
	" see vim -b
	augroup Binary
		au!
		au BufReadPre  *.bin,*.hex setlocal binary
		au BufReadPost * if &binary | Hexmode | endif
		au BufWritePre *
			\	if exists("b:edit_hex") && b:edit_hex && &binary |
			\		let ro_save = &ro | set noreadonly |
			\		let ma_save = &ma | set modifiable |
			\		exec '%!xxd -r' |
			\		let &ro = ro_save | let &ma = ma_save |
			\		unlet ro_save | unlet ma_save |
			\	endif
		au BufWritePost *
			\	if exists("b:edit_hex") && b:edit_hex && &binary |
			\		let ro_save = &ro | set noreadonly |
			\		let ma_save = &ma | set modifiable |
			\		exec '%!xxd' |
			\		exe "set nomod" |
			\		let &ro = ro_save | let &ma = ma_save |
			\		unlet ro_save | unlet ma_save |
			\	endif
	augroup END
	" }}}
endif

" Section: utility functions {{{1
" returns text with all instances of 'pat' removed
function! StripFrom(text, pat)
	return substitute(a:text, a:pat, '', 'g')
endfunction

" returns a new list with duplicate items removed
function! RemoveDuplicates(list)
	let uniq = []
	for i in range(len(a:list))
		if index(uniq, a:list[i]) == -1
			call add(uniq, a:list[i])
		endif
	endfor
	return uniq
endfunction

" returns the number of occurrences of needle in haystack
function! Count(haystack, needle)
	let counter = 0
	let index = match(a:haystack, a:needle)
	while index > -1
		let counter += 1
		let end = matchend(a:haystack, a:needle, index)
		let index = match(a:haystack, a:needle, end)
	endwhile
	return counter
endfunction

" returns most recently selected text
function! <SID>GetSelection()
	if has('x11')
		return @*
	else
		exec 'normal! `<'.visualmode().'`>"zy'
		return @z
	endif
endfunction

" echo a warning message
function! <SID>WarningMsg(msg)
	echohl WarningMsg | echomsg a:msg | echohl None
endfunction

" echo an error message
function! <SID>ErrorMsg(msg)
	echohl ErrorMsg | echomsg a:msg | echohl None
endfunction

" Section: commands {{{1
" diff {{{2
" compare the current buffer and the saved file
command! -nargs=0 DiffOrig	vertical new | set buftype=nofile |
							\ read # | 0 delete _ | diffthis | wincmd p | diffthis

" DiffRegs: diff contents of two registers {{{3
" usage: DiffRegs a z | DiffRegs az
command! -nargs=+ DiffRegs call s:DiffRegs(<f-args>)
function! s:DiffRegs(...)
	if a:0 > 2
		call <SID>ErrorMsg("Diff is between two registers")
		return
	endif
	let reg1 = a:1[0]
	if a:0 == 2
		let reg2 = a:2[0]
	else
		let reg2 = a:1[1]
	endif
	for reg in [ reg1, reg2 ]
		if reg == ''
			call <SID>ErrorMsg("Missing register")
			return
		elseif getregtype(reg) == ''
			call <SID>ErrorMsg("Empty or invalid register ".reg)
			return
		endif
	endfor
	tabnew | set buftype=nofile
	exec "silent put" reg2
	0 delete _ | diffthis
	vertical new | set buftype=nofile
	exec "silent put" reg1
	0 delete _ | diffthis
endfunction " }}}3

" registers {{{2
" Reg: check full contents of registers
command! -nargs=1 Reg call s:Reg(<q-args>)
function! s:Reg(regstr)
	for i in range(len(a:regstr))
		let reg = a:regstr[i]
		let contents = getreg(reg)
		if contents != ''
			echohl Visual | echo '"'.reg | echohl None
			echo contents
		endif
	endfor
endfunction

" ClearRegister: clear a register (@" and @z by default)
command! -nargs=0 -register ClearRegister
	\	if "<reg>" != ''     |
	\		let @<reg> = @_  |
	\	else                 |
	\		let @" = @_      |
	\		let @z = @_      |
	\	endif                |

" files {{{2
" TabOpen: open files in new tabs {{{3
command! -nargs=* -complete=file TabOpen call s:TabOpen(<f-args>)
function! s:TabOpen(...)
	if a:0 == 0
		tabnew | return
	endif
	let error = 0
	let wd = fnameescape(getcwd())
	for arg in a:000
		for file in split(glob(arg),'\n')
			exec "cd" wd
			if !filereadable(file)
				let error = 1
				call <SID>ErrorMsg("Can't read ".file)
				continue
			endif
			if error | echo '' | endif
			if @% != ''
				exec "tabedit" file
			else | exec "edit" file
			endif
		endfor
	endfor
endfunction " }}}3

" change the working directory to the current file's directory
command! -nargs=0 CD exec 'cd' expand('%:h')

" delete current file from disk
command! -nargs=0 RmFile echo "rm" @% "(".delete(@%).")"

" delete all buffers
command! -nargs=0 BD bufdo bdelete

" settings and views {{{2
" highlight with RightMargin beyond a column number
command! -nargs=? ColumnMarker	if "<args>" != '' | try |
								\	match RightMargin /\%><args>v.\+/ |
								\	catch | endtry |
								\else | match |
								\endif

" view/set the number of text columns
command! -nargs=? Columns	if "<args>" != '' | try |
							\	if &number | exec 'set columns='.(len(line('$'))+1+<args>) |
							\	else | set columns=<args> |
							\	endif | endtry |
							\else |
							\	if &number | echo &columns-len(line('$'))-1 |
							\	else | echo &columns |
							\	endif |
							\endif

" view/set textwidth
command! -nargs=? TextWidth	if "<args>" != '' | setlocal textwidth=<args> |
							\ else | set tw? | endif

" FontSize: change the current font size {{{3
command! -nargs=1 FontSize call s:FontSize(<q-args>)
function! s:FontSize(op)
	if !exists("g:font_increment")
		let g:font_increment = 0.5
	endif
	let curfont =   escape(StripFrom(&guifont, '\d\+\(\.\d\)\?$'), ' ')
	let cursize = str2float(matchstr(&guifont, '\d\+\(\.\d\)\?$'))
	if cursize == 0
		let newsize = ''
	elseif a:op == '+'
		let newsize = string(cursize + g:font_increment)
	elseif a:op == '-'
		let newsize = string(cursize - g:font_increment)
	else
		let newsize = a:op
	endif
	exec 'set guifont='.curfont.StripFrom(newsize, '\.0$')
endfunction " }}}3

" editing {{{2
" CopyMatches: copy matches of the last search to a register (default is ") {{{3
" only works for single-line searches
" accepts a range (default is the whole file)
" matches are appended to the register and each match is terminated by \n
command! -range=% -nargs=0 -register CopyMatches
	\	call s:CopyMatches(<line1>, <line2>, "<reg>")
function! s:CopyMatches(line1, line2, reg)
	let ic_save = &ignorecase
	set noignorecase
	let reg = a:reg != '' ? a:reg : '"'
	exec "let @".reg." = @_"
	for line in range(a:line1, a:line2)
		let txt = getline(line)
		let idx = match(txt, @/)
		while idx > -1
			exec "let @".reg." .= matchstr(txt, @/, idx) . \"\n\""
			let end = matchend(txt, @/, idx)
			let idx = match(txt, @/, end)
		endwhile
	endfor
	let &ic = ic_save
endfunction

" CutMatches: cut matches of the last search to a register (default is ") {{{3
" matches are appended to the register and each match is terminated by \n
command! -nargs=0 -register CutMatches
	\	call s:CutMatches("<reg>")
function! s:CutMatches(reg)
	let ic_save = &ignorecase
	set noignorecase
	let reg = a:reg != '' ? a:reg : '"'
	exec "let @".reg." = @_"
	%s//\=s:CutMatchesSave(reg, submatch(0))/ge
	let &ic = ic_save
endfunction
function! s:CutMatchesSave(reg, txt)
	exec "let @".a:reg." .= a:txt . \"\n\""
	return ''
endfunction

" Reverse: reverse lines in range {{{3
command! -range -nargs=0 Reverse
	\	let @z = @/<bar>
	\	<line2>mark a<bar>
	\	<line1>,<line2>g/^/m'a<bar>
	\	let @/ = @z

" LeadingSpacesToTabs: convert as many leading spaces to tabs as possible {{{3
command! -range=% -nargs=0 LeadingSpacesToTabs
	\	call s:LeadingSpacesToTabs(<line1>, <line2>)
function! s:LeadingSpacesToTabs(line1, line2)
	for line in range(a:line1, a:line2)
		while len(matchstr(getline(line), '^\t*\zs \+')) >= &tabstop
			exec line.'s/^\(\t*\) \{'.&tabstop.'}/\1\t/'
		endwhile
	endfor
endfunction

" InternalTabsToSpaces: convert tabs inside lines (used for alignment) to spaces {{{3
command! -range=% -nargs=0 InternalTabsToSpaces
	\	call s:InternalTabsToSpaces(<line1>, <line2>)
function! s:InternalTabsToSpaces(line1, line2)
	let tabpat = '^\t*\([^\t]\+\)\(\t\+\)'
	for line in range(a:line1, a:line2)
		while Count(getline(line), tabpat)
			let list = matchlist(getline(line), tabpat)
			exec line.'s/^\t*[^\t]\+\zs\t\+/'.
				\ repeat(' ', len(list[2]) * &tabstop - len(list[1]) % &tabstop).'/'
		endwhile
	endfor
endfunction

" CodeReadability: insert whitespace in code for readability {{{3
command! -range=% -nargs=0 CodeReadability call s:CodeReadability(<line1>, <line2>)
function! s:CodeReadability(line1, line2)
	try | for line in range(a:line1, a:line2)
		exec line.'s/\([^-+*/%&^|=!<>[:space:]]\)\(\%([-+*/%&^|=!<>]\|<<\|>>\)\?=\)\([^=[:space:]]\)/\1 \2 \3/ge'
		exec line.'s/\(\w\|)\)\([<>]\)\(\w\|(\)/\1 \2 \3/ge'
		exec line.'s/\(\%(el\|els\|else\)if\|for\|while\|until\)(/\1 (/ge'
		exec line.'s/){/) {/ge'
		exec line.'s/}\(else\|\%(el\|els\|else\)if\)/} \1/ge'
		exec line.'s/\(else\|\%(el\|els\|else\)if\){/\1 {/ge'
		exec line.'s/\<return\>\([^;[:space:]]\)/return \1/ge'
		" user confirm:
		exec line.'s/\(\w\|[]})"'."'".']\)\zs,\ze\(\w\|[[{("'."'".']\)/, /gec'
	endfor
	catch /^Interrupted$/ | endtry
endfunction

" Hexmode: toggle for hex mode {{{3
command! -nargs=0 -bar Hexmode call s:ToggleHex()
function! s:ToggleHex()
	let mod_save = &modified
	let ro_save = &readonly | set noreadonly
	let ma_save = &modifiable | set modifiable
	if !exists("b:edit_hex") || !b:edit_hex
		let b:ft_save = &filetype
		let b:bin_save = &binary
		setlocal binary
		set ft=xxd
		let b:edit_hex = 1
		%!xxd
	else
		let &ft = b:ft_save
		if !b:bin_save
			setlocal nobinary
		endif
		let b:edit_hex = 0
		%!xxd -r
	endif
	let &mod = mod_save
	let &ro = ro_save
	let &ma = ma_save
endfunction

" WordProcess and Ascii: character conversion {{{3
" convert quotes, apostrophes, and dashes into their unicode counterparts
command! -range=% -nargs=0 WordProcess call s:WordProcess(<line1>, <line2>)
function! s:WordProcess(line1, line2)
	let w = '[0-9A-Za-z]'
	let W = '[^0-9A-Za-z]'
	let punct = '[.,!?]'
	for line in range(a:line1, a:line2)
		exec line.'s/\('.w.'\|\s\|"\|^\)\zs--\ze\('.w.'\|\s\|'.punct.'\|"\|$\)/—/ge'
		exec line.'s/'.punct.'\zs"\ze\('.W.'\|$\)/”/ge'
		exec line.'s/\('.W.'\|^\)\zs"\ze\S/“/ge'
		exec line.'s/\S\zs"\ze\('.W.'\|$\)/”/ge'
		exec line.'s/\('.W.'\|^\)\zs'."'".'\ze\S/‘/ge'
		exec line.'s/\S\zs'."'".'\ze\('.W.'\|$\)/’/ge'
		exec line.'s/'.w.'\zs'."'".'\ze\a/’/ge'
	endfor
endfunction

" enforce ASCII-ness
command! -range=% -nargs=0 Ascii call s:Ascii(<line1>, <line2>)
function! s:Ascii(line1, line2)
	for line in range(a:line1, a:line2)
		exec line.'s/“/"/ge'
		exec line.'s/”/"/ge'
		exec line.'s/‘‘/"/ge'
		exec line.'s/’’/"/ge'
		exec line."s/‘/'/ge"
		exec line."s/’/'/ge"
		exec line.'s/—/--/ge'
	endfor
endfunction

" XCompose {{{3
" convert a line such as "ə U+0259 LATIN SMALL LETTER SCHWA"
" use bang for canonical bind (<ampersand> <x> <x> <x> <x>)
command! -range -bang -nargs=0 XCompose call s:XCompose(<line1>, <line2>, <bang>0)
function! s:XCompose(line1, line2, bang)
	for line in range(a:line1, a:line2)
		let txt = getline(line)
		let m = matchlist(txt, '\v^(.)\s*(U\+?\x\x\x\x)?\s*#?\s*(.*)')
		if empty(m) | continue | endif
		let m[2] = substitute(m[2], '\vU\+?(\x\x\x\x)', 'U\U\1', '')
		if a:bang && m[2] =~ 'U\x\x\x\x'
			let bind = '<ampersand>'
			for x in split(m[2][1:], '\ze.')
				let bind .= ' <'.tolower(x).'>'
			endfor
		else
			let bind = '<> <>'
		endif
		let txt = "<Multi_key> ".bind."\t\t\t: \"".m[1].'"'.(len(m[2]) ? "\t".m[2] : "").(len(m[3]) ? " # ".m[3] : "")
		call setline(line, txt)
	endfor
endfunction

" }}}1 commands
" Section: mappings {{{1
" see :help map-modes
" temp marks: 'a, 'z
" temp registers: @z
" general {{{2
" externally map CapsLock to Control
" basic {{{3
" no-ops
noremap			K			<Nop>

" make <Enter> more useful: enter command line or cancel pending operation
noremap			<CR>		:
onoremap		<CR>		<C-C>

" set <Space> to toggle a fold
noremap<silent><Space>		:<C-U>exec 'silent! normal! za'.(foldlevel('.')?'':'')<CR>

" use <C-Space> as <Esc>
noremap			<C-Space>	<Esc>
inoremap		<C-Space>	<Esc>
cnoremap		<C-Space>	<C-\><C-N>

" use <BackSpace> for deleting visual selections
xnoremap		<BS>		d
snoremap		<BS>		<BS>i

" make Y consistent with D and C
nnoremap		Y			y$

" don't clobber registers when doing character deletes
nnoremap		x			"_x
nnoremap		X			"_X
nnoremap		s			"_s

" <C-[HLJK]> {{{3
" first remap <C-K> (digraphs) to <C-B>
noremap!		<C-B>		<C-K>
" and <C-L> (redraw) to <C-Y>
noremap			<C-Y>		<C-L>
noremap			<C-E>		<Nop>
" anchor the cursor and scroll
noremap			<C-H>		zh
noremap			<C-L>		zl
noremap			<C-J>		<C-E>
noremap			<C-K>		<C-Y>
inoremap		<C-J>		<C-X><C-E>
inoremap		<C-K>		<C-X><C-Y>
" kill line
cnoremap		<C-K>		<C-F>D<C-C><End>
" <C-H> remains <BS> by default; use <C-L> to go right
noremap!		<C-L>		<Right>
" in command-line mode, use <C-T> for partial completion and listing matches
cnoremap		<C-T>		<C-L><C-D>

" <M-[hljk]> {{{3
" use as movement keys
noremap!		<M-h>		<Left>
noremap!		<M-l>		<Right>
inoremap		<M-j>		<C-O>gj
inoremap		<M-k>		<C-O>gk
" recall command history, matching current command line
cnoremap		<M-j>		<Down>
cnoremap		<M-k>		<Up>
" switch between windows in normal mode
nnoremap		<M-h>		<C-W>h
nnoremap		<M-l>		<C-W>l
nnoremap		<M-j>		<C-W>j
nnoremap		<M-k>		<C-W>k
" go from select mode to insert mode
snoremap		<M-h>		<C-\><C-N>`<i
snoremap		<M-l>		<C-\><C-N>`>a

" move in virtual lines {{{3
nnoremap		j			gj
xnoremap		j			gj
nnoremap		k			gk
xnoremap		k			gk
noremap			<Up>		gk
inoremap		<Up>		<C-O>gk
noremap			<Down>		gj
inoremap		<Down>		<C-O>gj

" emacs-style bindings for word movement and deletion {{{3
noremap			<M-b>		b
noremap			<M-f>		w
noremap!		<M-b>		<S-Left>
noremap!		<M-f>		<S-Right>

function! <SID>KillWord()
	return (col('.')==col('$') ? "\<Del>" : "\<C-O>de")
endfunction
inoremap<silent><M-d>		<C-R>=<SID>KillWord()<CR>
noremap!		<M-BS>		<C-W>

" use <C-O>D for <C-K>
inoremap		<C-A>		<C-O>^
cnoremap		<C-A>		<Home>
noremap!		<C-E>		<End>
cnoremap		<C-D>		<Del>
" in insert mode:
" use <C-F> as the default <C-A> (insert previously inserted text),
" and <C-G> as the default <C-E> (insert the char below cursor)
inoremap		<C-F>		<C-A>
inoremap		<C-G>		<C-E>

" register yank, delete, and paste with Meta {{{3
vnoremap<silent><M-y>		:<C-U>exec 'normal gv"'.nr2char(getchar()).'y'<CR>
vnoremap<silent><M-d>		:<C-U>exec 'normal gv"'.nr2char(getchar()).'d'<CR>

function! <SID>PasteRegister(visual)
	exec 'normal '.(a:visual ? 'gv' : '').'"'.nr2char(getchar()).'p'
endfunction
noremap	<silent><M-r>		:<C-U>call <SID>PasteRegister(0)<CR>
vnoremap<silent><M-r>		:<C-U>call <SID>PasteRegister(1)<CR>

" paste most recently used register
nnoremap		<M-p>		o<C-R>"<C-C>
nnoremap		<M-S-p>		O<C-R>"<C-C>
inoremap		<M-p>		<C-R>"

" increment/decrement all characters with <C-A> and <C-X> {{{3
function! <SID>OffsetCharacter(offset)
	normal! "zyl
	if @z =~ '\d\|\a' || &nrformats !~# '\<alpha\>'
		exec 'normal! '.(a:offset==1 ? "\<C-A>" : "\<C-X>")
	else
		let @z = nr2char(char2nr(@z) + a:offset)
		normal! v"zp
	endif
endfunction
nnoremap<silent><C-A>		:call <SID>OffsetCharacter(1)<CR>
nnoremap<silent><C-X>		:call <SID>OffsetCharacter(-1)<CR>
" works only if incrementing alphabetic chars is allowed

" windows-style clipboard shortcuts emulated with Meta {{{3
" select all
noremap			<M-a>		<C-\><C-N>ggVG
" cut
vnoremap		<M-x>		"+x
" copy
vnoremap		<M-c>		"+y
" paste
noremap			<M-v>		<C-\><C-N>"+gP
exec 'vnoremap <script> <M-v>' paste#paste_cmd['v']
exec 'inoremap <script> <M-v>' paste#paste_cmd['i']
cnoremap		<M-v>		<C-R>+

" misc {{{3
" re-enable 'hlsearch' with each search
nnoremap<silent>n			:set hlsearch<CR>n
nnoremap<silent>N			:set hlsearch<CR>N

" tab switching
noremap			<C-Tab>		:<C-U>tabnext<CR>
noremap			<C-S-Tab>	:<C-U>tabprevious<CR>

" visual mode indenting
xnoremap		<Tab>		>gv
xnoremap		<S-Tab>		<gv

" save shortcut
nnoremap		<C-S>		:w<CR>
xnoremap		<C-S>		:<C-U>w<CR>gv
inoremap		<C-S>		<C-O>:w<CR>

" paste X selection register
noremap!		<S-Insert>	<C-R>*

" nothing to see here; move along {{{3
if !has('gui_running') && &term =~ 'xterm' && &t_Co == 256
fun! Rave(time)
	let ravers = [ 'Number', 'String', 'Comment', 'Statement', 'Function', 'Special' ]
	let len = len(ravers)
	if !exists("g:wtf")
		let g:wtf = []
		let rand = localtime()
		for i in range(len)
			let rand += 232 / len
			let g:wtf += [ rand ]
		endfor
	endif
	for i in range(len)
		let g:wtf[i] = (g:wtf[i]+a:time) % 232
		if g:wtf[i] == 0
			let g:wtf[i] = 1
		elseif g:wtf[i] == 7  || g:wtf[i] == 8
			let g:wtf[i] = 9
		elseif g:wtf[i] == 15 || g:wtf[i] == 16
			let g:wtf[i] = 17
		endif
		exec "hi ".ravers[i]." ctermfg=".g:wtf[i]
	endfor
	hi! link Constant Number
	hi! link PreProc Number
	hi! link Identifier Function
	hi! link Type Function
	hi! link Keyword Statement
endfun
fun! Raveon(auto)
	if !exists("g:bpm")
		let g:bpm = 240
	endif
	while 1
		call Rave(a:auto) | redraw
		exec "sleep" float2nr(60000/g:bpm) "m"
	endwhile
endfun
silent! unlet g:wtf
map	<silent>	<M-F14>		:call Rave(1)<CR>
map	<silent>	<M-F13>		:call Rave(64)<CR>
map	<silent>	<M-F12>		:call Raveon(1)<CR>
endif " }}}3

" function keys {{{2
" (clear mappings) {{{3
function! <SID>ClearMapsF(key1, key2)
	for fkey in range(a:key1, a:key2)
		for modifier in [ '', 'C-', 'S-', 'C-S-' ]
			exec 'noremap <silent> <'.modifier.'F'.fkey.'> '.
				\':<C-U>call <SID>WarningMsg("Unmapped")<CR>'
			exec 'silent! unmap! <'.modifier.'F'.fkey.'>'
			exec 'inoremap <'.modifier.'F'.fkey.'> <Nop>'
		endfor
	endfor
endfunction
call <SID>ClearMapsF(1,14)

" plugins <F1> to <F3> {{{3
" toggle taglist
map				<F1>		:<C-U>TlistToggle<CR>
vmap			<F1>		:<C-U>TlistToggle<CR>gv
" toggle NERD Tree
map				<F2>		:<C-U>NERDTreeToggle<CR>
" toggle yank ring
map				<F3>		:<C-U>YRShow<CR>
" toggle clipboard <C-F3> {{{4
function! <SID>ToggleClipBrd()
	let clipnr = bufnr('*\[Clip Board\]$')
	if bufwinnr(clipnr) == winnr()
		exit!
	else
		let reg = input(":ClipBrd ", g:clipbrdDefaultReg)
		try
			if reg != ''
				exec "ClipBrd" reg
			endif
		catch | endtry
	endif
endfunction
map	<silent>	<C-F3>		:<C-U>call <SID>ToggleClipBrd()<CR>
" }}}

" trim trailing whitespace <F4> {{{3
function! <SID>Trim()
	try " snippetsEmu housekeeping
		if expand('%:t') !~ '\.XCompose' && exists("*CleanupArgs") &&
			\ g:snip_start_tag != '' && g:snip_end_tag != ''
			exec '%s/('.g:snip_start_tag.'\(.*\))/\="(".CleanupArgs(submatch(1)).")"/e'
			exec '%s/'.g:snip_start_tag.g:snip_end_tag.'//eg'
		endif
	catch | endtry
	%s/\s\+$//e
endfunction
map	<silent>	<F4>		:<C-U>let @z=@/<CR>maHmz:call <SID>Trim()<CR>:let @/=@z<CR>`zzt`a
vmap<silent>	<F4>		:<C-U>let @z=@/<CR>maHmz:call <SID>Trim()<CR>:let @/=@z<CR>`zzt`agv
imap<silent>	<F4>		<C-C>:let @z=@/<CR>maHmz:call <SID>Trim()<CR>:let @/=@z<CR>`zzt`agi

" autoindent entire file <C-F4> {{{3
map				<C-F4>		<C-\><C-N>maHmzgg=G`zzt`a
vmap			<C-F4>		<C-\><C-N>maHmzgg=G`zzt`agv

" remove search highlighting <F5> {{{3
" let @/=@_
map	<silent>	<F5>		:<C-U>nohlsearch<CR>
vmap<silent>	<F5>		:<C-U>nohlsearch<CR>gv
imap<silent>	<F5>		<C-O>:nohlsearch<CR>

" toggle scrollbind <C-F5> {{{3
map	<silent>	<C-F5>		:<C-U>setlocal scrollbind! scb?<CR>
vmap<silent>	<C-F5>		:<C-U>setlocal scrollbind! scb?<CR>gv
imap<silent>	<C-F5>		<C-O>:setlocal scrollbind! scb?<CR>

" toggle list mode (show tabs) <F6> {{{3
map	<silent>	<F6>		:<C-U>setlocal list! list?<CR>
vmap<silent>	<F6>		:<C-U>setlocal list! list?<CR>gv
imap<silent>	<F6>		<C-O>:setlocal list! list?<CR>

" highlight characters beyond column … <C-F6> {{{3
map				<C-F6>		:<C-U>ColumnMarker<Space>
imap			<C-F6>		<C-O>:ColumnMarker<Space>

" toggle tabstop <F7> {{{3
function! <SID>ToggleTabstop()
	if &tabstop == 4
		setlocal tabstop=8
	elseif &tabstop == 8
		setlocal tabstop=4
	endif
	set ts?
endfunction
map	<silent>	<F7>		:<C-U>call <SID>ToggleTabstop()<CR>
vmap<silent>	<F7>		:<C-U>call <SID>ToggleTabstop()<CR>gv
imap<silent>	<F7>		<C-O>:call <SID>ToggleTabstop()<CR>

" toggle expandtab <C-F7> {{{3
map	<silent>	<C-F7>		:<C-U>setlocal expandtab! et?<CR>
vmap<silent>	<C-F7>		:<C-U>setlocal expandtab! et?<CR>gv
imap<silent>	<C-F7>		<C-O>:setlocal expandtab! et?<CR>

" toggle line wrapping <F8> {{{3
map	<silent>	<F8>		:<C-U>setlocal wrap! wrap?<CR>
vmap<silent>	<F8>		:<C-U>setlocal wrap! wrap?<CR>gv
imap<silent>	<F8>		<C-O>:setlocal wrap! wrap?<CR>

" view/set maximum line length to … <C-F8> {{{3
" (set to 0 to disable auto-truncation)
map				<C-F8>		:<C-U>TextWidth<Space>
imap			<C-F8>		<C-O>:TextWidth<Space>

" cycle color schemes <F9> {{{3
function! <SID>NextColorScheme()
	if !exists("g:colors_select")
		let g:colors_name = "nocolors"
		return
	endif
	let idx = 0
	if exists("g:colors_name")
		for name in g:colors_select
			if g:colors_name == name | break | endif
			let idx += 1
		endfor
	endif
	let next = (idx+1) % len(g:colors_select)
	call <SID>SetColorScheme(g:colors_select[next])
endfunction
map	<silent>	<F9>		:<C-U>call <SID>NextColorScheme()<CR>:echo g:colors_name<CR>
vmap<silent>	<F9>		:<C-U>call <SID>NextColorScheme()<CR>:echo g:colors_name<CR>gv
imap<silent>	<F9>		<C-C>:call <SID>NextColorScheme()<CR>:echo g:colors_name<CR>gi

" cycle fonts <C-F9> {{{3
function! <SID>NextFont()
	if !exists("g:font_select") || !exists("g:font_index")
		return
	endif
	let g:font_index = (g:font_index+1) % len(g:font_select)
	call <SID>SetGUIFont(g:font_select[g:font_index])
endfunction
map	<silent>	<C-F9>		:<C-U>call <SID>NextFont()<CR>:echo &guifont<CR>
vmap<silent>	<C-F9>		:<C-U>call <SID>NextFont()<CR>:echo &guifont<CR>gv
imap<silent>	<C-F9>		<C-C>:call <SID>NextFont()<CR>:echo &guifont<CR>gi

" toggle line numbers <S-F9> {{{3
map	<silent>	<S-F9>		:<C-U>setlocal number! nu?<CR>
vmap<silent>	<S-F9>		:<C-U>setlocal number! nu?<CR>gv
imap<silent>	<S-F9>		<C-O>:setlocal number! nu?<CR>

" toggle menu bar and toolbar <F10> {{{3
function! <SID>ToggleBars()
	if &guioptions =~# 'm'
		set guioptions-=m
		set guioptions-=T
	else
		set guioptions+=m
		set guioptions+=T
	endif
	set go?
endfunction
map	<silent>	<F10>		:<C-U>call <SID>ToggleBars()<CR>
vmap<silent>	<F10>		:<C-U>call <SID>ToggleBars()<CR>gv

" maximize current window <F11> {{{3
map				<F11>		<C-\><C-N><C-W>_<C-W>\|
vmap			<F11>		<C-\><C-N><C-W>_<C-W>\|gv

" change window width <C-F(10|11)>, height <S-F(10|11)> {{{3
map				<C-F10>		<C-\><C-N>3<C-W><
vmap			<C-F10>		<C-\><C-N>3<C-W><gv
map				<C-F11>		<C-\><C-N>3<C-W>>
vmap			<C-F11>		<C-\><C-N>3<C-W>>gv
map				<S-F10>		<C-\><C-N>3<C-W>-
vmap			<S-F10>		<C-\><C-N>3<C-W>-gv
map				<S-F11>		<C-\><C-N>3<C-W>+
vmap			<S-F11>		<C-\><C-N>3<C-W>+gv

" toggle spellcheck and autocorrect <F12> {{{3
function! <SID>ToggleSpellCorrect()
	if &spell
		iabclear
	else
		runtime autocorrect.vim
	endif
	setlocal spell! spell?
endfunction
map	<silent>	<F12>		:<C-U>call <SID>ToggleSpellCorrect()<CR>
vmap<silent>	<F12>		:<C-U>call <SID>ToggleSpellCorrect()<CR>gv
imap<silent>	<F12>		<C-O>:call <SID>ToggleSpellCorrect()<CR>

" toggle cursorline <C-F12> {{{3
map	<silent>	<C-F12>		:<C-U>setlocal cursorline! cul?<CR>
vmap<silent>	<C-F12>		:<C-U>setlocal cursorline! cul?<CR>gv
imap<silent>	<C-F12>		<C-O>:setlocal cursorline! cul?<CR>

" switch buffers <F13> <F14> {{{3
map				<F13>		:<C-U>bprevious<CR>
map				<F14>		:<C-U>bnext<CR>

" choose buffer <C-F13>; split all buffers <C-F14> {{{3
map				<C-F13>		:<C-U>ls<CR>:buffer<Space>
map				<C-F14>		:<C-U>tab ball<CR>

" redirect command-line output to @z <S-F13>; end redirect <S-F14> {{{3
map				<S-F13>		:<C-U>let @z=@_<CR>:redir @z><CR>
vmap			<S-F13>		:<C-U>let @z=@_<CR>:redir @z><CR>gv
nmap			<S-F14>		:<C-U>redir END<CR>
vmap			<S-F14>		:<C-U>redir END<CR>gv
" }}}

" macros {{{2
" misc {{{3
" surround selected area (obsoleted by surround.vim)
xnoremap		'			<C-C>`>a'<C-C>`<i'<C-C>
xnoremap		(			<C-C>`>a)<C-C>`<i(<C-C>

" close all folds except this
nnoremap<silent>zT			:exec 'normal zM'.foldlevel('.').'zo'<CR>

" display current file in two columns
noremap	<silent>ZC			:<C-U>let @z=&so<CR>:set so=0<CR>maHmz:set noscb<CR>
							\:vs<CR><C-W>wLzt:set scb<CR><C-W>p:set scb<CR>
							\`zzt`a:let &so=@z<CR>

" diff mode
noremap			du			:<C-U>diffupdate<CR>
" jump between diffs
noremap			dN			<C-\><C-N>[czz
noremap			dn			<C-\><C-N>]czz

" <M-0> to <M-9> {{{3
function! <SID>ClearMapsM(key1, key2)
	for mkey in range(a:key1, a:key2)
		exec 'noremap <silent> <M-'.mkey.'> '.
			\':<C-U>call <SID>WarningMsg("Unmapped")<CR>'
		exec 'silent! unmap! <M-'.mkey.'>'
	endfor
endfunction
call <SID>ClearMapsM(0,9)

" quickfix {{{4
map				<M-1>		<C-\><C-N>:cprevious<CR>
map				<M-2>		<C-\><C-N>:cnext<CR>
map				<M-3>		<C-\><C-N>:clist<CR>
map				<M-4>		<C-\><C-N>:make<Space><Up><CR>
cmap<silent>	<M-4>		<C-R>=expand('%:t:r')<CR>
" fold one level
map				<M-5>		<C-\><C-N>:%foldclose<CR>
" highlight without jumping
xmap<silent>	<M-8>		:<C-U>let @/="\\V<C-R>=escape(<SID>FidgetWhitespace(escape(<SID>GetSelection(),'\')),'\"')<CR>"<CR>
"							exec "let @/='\\<".expand("<cword>")."\\>'"
nmap<silent>	<M-8>		:<C-U>normal! #*<CR>
imap<silent>	<M-8>		<C-O>:normal! #*<CR>

" change font size {{{4
map	<silent>	<M-0>		:<C-U>call <SID>NextFont(0)<CR>
vmap<silent>	<M-0>		:<C-U>call <SID>NextFont(0)<CR>
map	<silent>	<M-->		:<C-U>FontSize -<CR>:set guifont?<CR>
vmap<silent>	<M-->		:<C-U>FontSize -<CR>:set guifont?<CR>gv
map	<silent>	<M-=>		:<C-U>FontSize +<CR>:set guifont?<CR>
vmap<silent>	<M-=>		:<C-U>FontSize +<CR>:set guifont?<CR>gv

" <leader> {{{3
let mapleader = '\'

" replace last search pattern
map				<leader>s		:%s///gc<Left><Left><Left>
xmap			<leader>s		:s///gc<Left><Left><Left>
" execute command on lines matching last search pattern
map				<leader>g		:g//

" files {{{4
" load this file for editing and re-source
map				<leader>v		:<C-U>TabOpen $MYVIMRC<CR>
map				<leader>u		:<C-U>source $MYVIMRC<CR>
" load config files for editing
map	<silent>	<leader>b		:<C-U>TabOpen ~/.bash{rc,_aliases,_hacks}<CR>:tabnext 2<CR>
map	<silent>	<leader>f		:<C-U>TabOpen ~/.mozilla/firefox/*.default/chrome/user{Content,Chrome}.css
										\ ~/Application\ Data/Mozilla/Firefox/Profiles/*.default/chrome/userChrome.css<CR>

" tabs {{{4
" expand tabs in selected lines to spaces
xmap<silent>	<leader>e		:<C-U>let @z=&et<CR>:set et<CR>gv:retab<CR>:let &et=@z<CR>
" convert spaces to tabs
xmap<silent>	<leader>t		:retab!<CR>

" insert expanded tabs (tabs as spaces)
imap<silent>	<leader><TAB>	<C-R>=repeat(' ', &tabstop - (virtcol('.')-1) % &tabstop)<CR>

" deletion {{{4
" delete into the null register
map				<leader>d		"_d
map				<leader>D		"_D
map				<leader>c		"_c
map				<leader>C		"_C
" delete the stretch of whitespace at or before the cursor
nmap<silent>	<leader><BS>	:normal! gE<CR>
								\:exec(getline('.')[col('.')-1]=~'\S' ? "normal! \<lt>Right>":"")<CR>
								\:exec(getline('.')[col('.')-1]=~'\s' ? 'normal! dw':'')<CR>

" text insertion {{{4
" append modeline
nmap<silent>	<leader>m		ovim:set ts=4 sw=4 noet:<C-C>^

" date
imap<silent>	<leader>d		<C-R>=strftime('%Y-%m-%d')<CR>
imap<silent>	<leader>l		<C-v>u25d81 <C-R>=strftime('%m/%d %a \| [] ')<CR><Left><Left>

" encryption {{{4
function! <SID>R()
	if !exists("*Random") || !exists("*Srand")
		call <SID>ErrorMsg("Random function not defined")
		return
	endif
	let key = str2nr(input('# '))
	if key < 1000
		call <SID>ErrorMsg("Invalid key")
		return
	endif
	call Srand(key)
	let ascii = split("!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~", '\zs')
	let alpha1 = ''
	let alpha2 = ''
	while !empty(ascii)
		let c1 = remove(ascii, Random(len(ascii)))
		let c2 = remove(ascii, Random(len(ascii)))
		let alpha1 .= c1.c2
		let alpha2 .= c2.c1
	endwhile
	let @z = tr(<SID>GetSelection(), alpha1, alpha2)
	exec 'normal! gv"zp'
endfunction
xmap<silent>	<leader>r		:<C-U>call <SID>R()<CR>

" spellchecking {{{4
nmap			<leader>[		[s
nmap			<leader>]		]s
nmap			<leader>=		z=

" search {{{3
" search for a word
map				<leader>w		<C-\><C-N>/\<\><Left><Left>
cmap			<leader>W		\<\><Left><Left>

" search for visually selected text {{{4
function! <SID>FidgetWhitespace(pat)
	let pat = substitute(a:pat,'\_s\+$','\\s\\*', '')
	let pat = substitute(pat, '^\_s\+', '\\s\\*', '')
	return    substitute(pat,  '\_s\+', '\\_s\\+','g')
endfunction
" fuzzy whitespace
xmap<silent>	*				<C-C>/\V<C-R>=<SID>FidgetWhitespace(escape(<SID>GetSelection(),'/\'))<CR><CR>
xmap<silent>	#				<C-C>?\V<C-R>=<SID>FidgetWhitespace(escape(<SID>GetSelection(),'?\'))<CR><CR>
" exact match
xmap<silent>	<leader>*		<C-C>/\V<C-R>=substitute(escape(<SID>GetSelection(),'/\'),'\n','\\n','g')<CR><CR>
xmap<silent>	<leader>#		<C-C>?\V<C-R>=substitute(escape(<SID>GetSelection(),'?\'),'\n','\\n','g')<CR><CR>

" regex shortcuts {{{4
" brace multi, non-greedy multi
cnoremap		<leader>{		\{}<Left>
cnoremap		<leader>-		\{-}

" }}}1 mappings
" Section: plugins {{{1
" external balloon evaluation
function! <SID>PlugBalloonEval()
	if exists("*BalloonDeclaration")
		" echofunc
		return BalloonDeclaration()
	else | return '' | endif
endfunction

" ClipBrd {{{2
let g:clipbrdDefaultReg = '+'

" echofunc {{{2
let g:EchoFuncKeyPrev = '<M-p>'
let g:EchoFuncKeyNext = '<M-n>'
let g:EchoFuncMaxBalloonDeclarations = 6

" NERD Commenter {{{2
let g:NERDBlockComIgnoreEmpty = 1
let g:NERDCommentWholeLinesInVMode = 2
let g:NERDDefaultNesting = 0
let g:NERDMenuMode = 0
let g:NERDSpaceDelims = 1
let g:NERDSexyComs = 0
let g:NERDCompactSexyComs = 0
let g:NERDShutUp = 1

" NERD Tree {{{2
let g:NERDTreeWinPos = "right"

" session_dialog {{{2
let g:SessionSaveDirectory = "~"
let g:SessionPath = ".,~"
" let g:SessionFilePrefix = ""
" let g:SessionFileSuffix = ""
let g:SessionDefault = ""
let g:SessionConfirmOverwrite = 0
let g:SessionQuitAfterSave = 0
let g:SessionCreateDefaultMaps = 1

" snippetsEmu {{{2
let g:snip_start_tag = "\u2039"
let g:snip_end_tag = "\u203a"

" edit snippets for the current or given filetype
command! -nargs=* -complete=custom,EditSnippetsComplete EditSnippets
	\	call s:EditSnippets(<f-args>)
function! s:EditSnippets(...)
	let args = (a:0==0 ? [&filetype] : a:000)
	for type in args
		if type == '' | continue | endif
		let snips = split(globpath(&rtp, "after/*/".type."_snippets".(type=='*'? '_*' : '*').".vim"))
		if len(snips) == 0
			call <SID>ErrorMsg("No snippets found for filetype ".type)
			continue
		endif
		for file in snips | exec "TabOpen" file | endfor
	endfor
endfunction
function! EditSnippetsComplete(a,l,p)
	let types = split(globpath(&rtp, "after/*/*_snippets*.vim"))
	for i in range(len(types))
		let types[i] = StripFrom(fnamemodify(types[i], ':t'), '_snippets.*\.vim$')
	endfor
	return join(RemoveDuplicates(types), "\n")
endfunction

" highlight snippets
command! -nargs=0 HighlightSnippets exec 'silent! normal! /\<Snippet\s\+\zs\S\+<CR>'

" speeddating {{{2
let g:speeddating_no_mappings = 0

function! <SID>ToggleNrFormats() " {{{3
	if &nrformats =~# '\<alpha\>'
		set nrformats-=alpha
	else
		set nrformats+=alpha
	endif
	set nf?
endfunction
function! <SID>ToggleCtrlAX() " {{{3
if hasmapto('<Plug>SpeedDatingUp')
	unmap		<C-A>
	unmap		<C-X>
	unmap		d<C-A>
	unmap		d<C-X>
	nmap<silent><C-A>		:call <SID>OffsetCharacter(1)<CR>
	nmap<silent><C-X>		:call <SID>OffsetCharacter(-1)<CR>
	echo "  normal"
else
	nmap		<C-A>		<Plug>SpeedDatingUp
	nmap		<C-X>		<Plug>SpeedDatingDown
	xmap		<C-A>		<Plug>SpeedDatingUp
	xmap		<C-X>		<Plug>SpeedDatingDown
	nmap		d<C-A>		<Plug>SpeedDatingNowUTC
	nmap		d<C-X>		<Plug>SpeedDatingNowLocal
	echo "  speeddating"
endif
endfunction " }}}3
map	<silent>	<leader><C-A>	:<C-U>call <SID>ToggleNrFormats()<CR>
map	<silent>	<leader><C-X>	:<C-U>call <SID>ToggleCtrlAX()<CR>

" taglist {{{2
let g:Tlist_Show_One_File = 1

" YankRing {{{2
if !has('gui_win32')
	let g:yankring_history_file = ".yankring_history"
else
	let g:yankring_history_file = "_yankring_history"
endif
" custom maps: extend to or exclude from YankRing
function! YRRunAfterMaps()
nnoremap<silent>Y			:<C-U>YRYankCount 'y$'<CR>
nnoremap		x			"_x
nnoremap		X			"_X
nnoremap		s			"_s
endfunction
if exists("loaded_yankring") | call YRRunAfterMaps() | endif

" }}}1 plugins
" Section: development {{{1
if !has('autocmd')
	finish
endif

" C/C++ {{{2
augroup cpp
	au!
	" use syntax folding
	au FileType c,cpp setl foldmethod=syntax
augroup END

" java {{{2
augroup java
	au!
	" use syntax folding
	au FileType java setl foldmethod=syntax
	" make
	au FileType java setl mp=javac\ -g\ $*\ %
	au FileType java setl efm=%A%f:%l:\ %m,%-Z%p^,%-C%.%#,%-G%.%#
augroup END

" python {{{2
if has('python')
python << EOF
# script {{{
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
# }}}
EOF
endif

augroup python
	au!
	au FileType python setl expandtab
	au FileType python setl diffopt-=iwhite
	" make
	au FileType python setl mp=python\ -c\ \"import\ py_compile;py_compile.compile(r'%')\"\ -t
	au FileType python setl efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%C^,%C%[%^\ ]%\\@=%m,%Z
	" breakpoints
	au FileType python map <buffer> <M-9> <C-\><C-N>:python ToggleBreakpoint()<CR>
	au FileType python map <buffer> <M-0> <C-\><C-N>:python RemoveBreakpoints()<CR>
augroup END

" git {{{2
augroup git
	au!
	au FileType git* setl textwidth=72
augroup END

" }}}1 development
" vim:set ts=4 sw=4 noet fdl=0 fdm=marker:
