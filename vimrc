" Vim 7.2 vimrc
" Author:		David Liang
" Soure:		http://github.com/bmdavll/configs/blob/master/vimrc
" Last Change:	2010-08-04
" Section: encoding {{1
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

" Section: utility functions {{1
" global {{2
" returns text with all instances of pat removed
function! StripFrom(text, pat)
	return substitute(a:text, a:pat, '', 'g')
endfunction

" returns the length of str, counting each multi-byte character as 1
function! Strlen(str)
	return strlen(substitute(a:str, '.', 'x', 'g'))
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

" returns a list of pat occurrences in str -- cf. matchlist()
function! MatchList(str, pat)
	let matches = []
	let end = 0
	while 1
		let mat = matchstr(a:str, a:pat, end)
		if mat == '' | break | endif
		call add(matches, mat)
		let end = matchend(a:str, a:pat, end)
	endwhile
	return matches
endfunction

" local to script {{2
" returns a new list with duplicate items removed
function! <SID>RemoveDuplicates(list)
	let uniq = []
	for i in range(len(a:list))
		if index(uniq, a:list[i]) == -1
			call add(uniq, a:list[i])
		endif
	endfor
	return uniq
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
" }}

" Section: options {{1
" interface {{2
set nocompatible		" use vim settings instead of vi settings
set mouse=a				" enable mouse in all modes
set noinsertmode		" enforce in case of EZ-mode
set visualbell t_vb=	" disable bell
" whitespace {{2
set noexpandtab			" whether to expand tabs into spaces
set tabstop=4			" number of spaces for tab character
set shiftwidth=4		" number of spaces for autoindent and soft tab stops
" search {{2
set incsearch			" do incremental searching
set ignorecase			" ignore case for search patterns
						" (override with \C anywhere in a search pattern)
set smartcase			" don't ignore case for patterns with uppercase chars
set hlsearch			" highlight search pattern matches
" editing {{2
set formatoptions+=r	" auto insert comment leader
set formatoptions+=n	" recognize numbered lists when formatting
set formatoptions+=l	" don't break pre-existing long lines in insert mode
set formatoptions+=1	" don't break after a one-letter word
set backspace=2			" allow backspacing over everything in insert mode
set delcombine			" delete combining characters separately
" window {{2
set scrolloff=3			" minimum lines of padding when vertically scrolling
set sidescrolloff=4		" minimum columns of padding when horizontally scrolling
set sidescroll=2		" redraw with every column when side scrolling
set winminheight=0		" fully minimize split windows
set winminwidth=0		" fully minimize vertically split windows
set cmdwinheight=12		" set command-line window height
set cmdheight=1			" number of command lines
set showcmd				" display incomplete commands
set ruler				" show the cursor position at all times
set number				" show line numbers by default
set numberwidth=1		" only use as much space as needed for line numbers
set shortmess=atToOI	" abbreviate file messages
" text display {{2
set nowrap				" don't wrap lines by default
set listchars=tab:▏\ ,precedes:‹,extends:›
						" display characters for tabs and extended lines
let &showbreak = "\u21aa "
						" display character for wrapped lines
let &fillchars = "vert:|"
						" don't use fill character '-' for folds
set linebreak			" don't break mid-word when wrapping
set display+=lastline	" show as much of the last (long) line as possible
" folding {{2
set foldmethod=indent	" define folds automatically based on indent level
function! MyFoldText()	" custom fold text function
	let d1 = get([ '─', '─', '╌' ], v:foldlevel-2, '-')
	let d2 = get([ '─', '╌', '╌' ], v:foldlevel-2, '-')
	let indent = repeat(d1.d2, &sw/2).(&sw%2 ? d2 : '')
	let leader = repeat(indent, v:foldlevel-1).tr(v:foldlevel, '0123456789', '₀₁₂₃₄₅₆₇₈₉')
	let fdtext = split(substitute(foldtext(), '\v^\+--+\s*(\d+) lines:\s*(.*)', '\1\n\2', ''), '\n', 1)
	let cols = winwidth(winnr())-(&number ? len(line('$'))+1 : 0)
	let fill = cols - Strlen(leader) - strlen(fdtext[0]) - 2 - cols/7
	let fdtext[1] = substitute(fdtext[1], '^.\{'.fill.'}\zs.*', '', '')
	return leader.' '.fdtext[1].repeat('-', fill - Strlen(fdtext[1])).' '.fdtext[0]
endfunction
set foldtext=MyFoldText()
" control {{2
set whichwrap=b,<,>,[,] " move freely between lines
set virtualedit=block	" allow virtual selection in blockwise visual mode
set timeoutlen=666		" milliseconds before mapped key sequences time out
" vim {{2
set updatetime=1000		" interval for CursorHold updates and swap file writes
set nobackup			" do not keep a backup file
set history=1000		" lines of command line history to keep
set viminfo='50,s100,h	" settings for vim cache
set sessionoptions=curdir,folds,localoptions,tabpages,winsize
						" what to save with mksession
set cpoptions+=>		" put a line break before appending to a register
set diffopt+=iwhite		" ignore whitespace in diff mode
set diffopt+=foldcolumn:1
						" use narrow fold column
" completion {{2
set complete-=i			" don't scan included files for completion options
set completeopt+=longest
						" complete to the longest common match in insert mode
set wildmenu			" enhanced command-line completion menu
set wildcharm=<C-Z>		" character for command-line completion in mappings
set wildignore+=*.o		" files to ignore for filename completion
set wildignore+=*.class
set wildignore+=*.pyc

" win32 {{2
if !has('gui_win32')
	" directories for swap files
	set directory=~/tmp//,.,/var/tmp//,/tmp//
else
	set directory=~//,.
endif
" }}

" Section: gui {{1
if has('gui_running')
	" options {{2
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

	" font {{2
	function! <SID>SetGUIFont(font)
		if has('gui_win32') || has('gui_mac')
			let sep = ':h'
		else
			let sep = ' '
		endif
		exec 'set guifont='.escape(a:font[0].sep.string(a:font[1]), ' ')
	endfunction
	function! <SID>AdvanceFont(incr)
		if !exists("s:font_select")
			return
		elseif !exists("s:font_index")
			let s:font_index = 0
		else
			let s:font_index = (s:font_index+a:incr) % len(s:font_select)
		endif
		call <SID>SetGUIFont(s:font_select[s:font_index])
	endfunction

	" display fonts (:set guifont=* to select interactively)
	if has('gui_win32')
		let s:font_select = [ ['Consolas', 9], ['DejaVu Sans Mono', 8] ]
	else
		let s:font_select = [ ['DejaVu Sans Mono', 9], ['Consolas', 10.5] ]
	endif
	call <SID>AdvanceFont(0)
	" }}
endif

" Section: terminal {{1
if !has('gui_running')
	set ttimeoutlen=50			" timeout for terminal keycodes (in ms)
	if &term =~ 'screen'
		set showtabline=2		" always show tab line
	endif

	source $VIMRUNTIME/menu.vim	" emenu access

	" keycodes {{2
	" map <C-Space>
	map  <Nul> <C-Space>
	map! <Nul> <C-Space>

	" unset vim keycodes
	set <Help>=
	set <Undo>=

	" Meta sends <Esc> {{3
	set <M-1>=1 | set <M-2>=2 | set <M-3>=3 | set <M-4>=4 | set <M-5>=5
	set <M-6>=6 | set <M-7>=7 | set <M-8>=8 | set <M-9>=9 | set <M-0>=0
	set <M-a>=a | set <M-x>=x | set <M-c>=c | set <M-v>=v
	set <M-h>=h | set <M-j>=j | set <M-k>=k | set <M-l>=l
	set <M-p>=p | set <M-n>=n | set <M-b>=b | set <M-f>=f
	set <M-d>=d | set <M-r>=r | set <M-y>=y
	set <M-/>=/ | set <M-?>=? | set <M-->=- | set <M-=>==

	" MapFastKeycode: helper for fast keycode mappings {{3
	" http://vim.wikia.com/wiki/Mapping_fast_keycodes_in_terminal_Vim
	" makes use of unused vim keycodes <[S-]F15> to <[S-]F37>
	function! <SID>MapFastKeycode(key, keycode)
		if s:fast_i == 46
			call <SID>WarningMsg("Unable to map ".a:key.": out of spare keycodes")
			return
		endif
		let vkeycode = '<'.(s:fast_i/23==0 ? '' : 'S-').'F'.(15+s:fast_i%23).'>'
		exec 'set '.vkeycode.'='.a:keycode
		exec 'map '.vkeycode.' '.a:key
		let s:fast_i += 1
	endfunction
	let s:fast_i = 0
	" associate terminal keycodes with vim keycodes {{3
	if     &term =~ 'xterm' || $COLORTERM =~ 'Terminal' " {{4
		set <F1>=O1;*P
		set <F2>=O1;*Q
		set <F3>=O1;*R
		set <F4>=O1;*S
		set <xF1>=OP
		set <xF2>=OQ
		set <xF3>=OR
		set <xF4>=OS
		set <F5>=[15;*~
		set <F6>=[17;*~
		set <F7>=[18;*~
		set <F8>=[19;*~
		set <F9>=[20;*~
		set <F10>=[21;*~
		set <F11>=[23;*~
		set <F12>=[24;*~
		set <F13>=[25;*~
		set <F14>=[26;*~
	elseif &term =~ 'rxvt'  || $COLORTERM =~ 'rxvt' " {{4
		function! <SID>RxvtFMap(from, to, codenums, ...) " {{
			if a:0 == 0 | return | endif
			for bind in a:000
				if bind[0] =~ 'C-'
					let needs_fast = 1
				else
					let needs_fast = 0
				endif
				let i = 0
				for n in range(a:from, a:to)
					let keycode = "\e[".a:codenums[i].bind[1]
					if needs_fast
						call <SID>MapFastKeycode('<'.bind[0].'F'.n.'>', keycode)
					else
						exec 'set <'.bind[0].'F'.n.'>='.keycode
					endif
					let i += 1
				endfor
			endfor
		endfunction " }}
		call <SID>RxvtFMap(11, 14, range(23,26),    ['','~'], ['C-','^'], ['S-','$'], ['C-S-','@'])
		call <SID>RxvtFMap( 1, 10, range(11,15)+range(17,21), ['C-','^'])
		call <SID>RxvtFMap( 5, 10, range(28,29)+range(31,34),             ['S-','~'], ['C-S-','^'])
	endif
	" }}2
endif

" Section: colors {{1
if has('gui_running') || &t_Co > 2
	" enable syntax highlighting
	syntax on

	" color scheme
	function! <SID>SetColorScheme(color) " {{2
		set background=dark
		try
			exec "colorscheme" a:color
		catch
			return
		endtry
		" custom highlighting for color schemes {{3
		if g:colors_name == 'desert256'
			hi Normal						ctermbg=234								guibg=#1c1c1c
			hi Search		ctermfg=6		ctermbg=18				guifg=#87ceeb	guibg=#000087
			hi Folded		ctermfg=103		ctermbg=237				guifg=#a0a8b0	guibg=#3a4046
			hi LineNr		ctermfg=241		ctermbg=232				guifg=#857b6f	guibg=#080808
			hi SpecialKey	ctermfg=240		ctermbg=235				guifg=#585858	guibg=#262626
			hi Cursor												guifg=#1c1c1c
			hi CursorLine					ctermbg=236	cterm=none					guibg=#32322f
			hi Pmenu		ctermfg=230		ctermbg=238				guifg=#ffffd7	guibg=#444444
			hi PmenuSel		ctermfg=232		ctermbg=192				guifg=#080808	guibg=#cae982
			hi Comment		ctermfg=103								guifg=#8787af					gui=italic
			hi! link NonText LineNr
			hi! link CursorColumn CursorLine
		endif
		" global highlighting {{3
		" Marker
		hi RightMargin						ctermbg=239								guibg=#4e4e4e
		" diff
		hi DiffAdd			ctermfg=none	ctermbg=17	cterm=none	guifg=NONE		guibg=#2a0d6a	gui=none
		hi DiffDelete		ctermfg=234		ctermbg=60	cterm=none	guifg=#242424	guibg=#3e3969	gui=none
		hi DiffText			ctermfg=none	ctermbg=53	cterm=none	guifg=NONE		guibg=#73186e	gui=none
		hi DiffChange		ctermfg=none	ctermbg=237	cterm=none	guifg=NONE		guibg=#382a37	gui=none
		" }}
	endfunction

	function! <SID>AdvanceColorScheme(incr) " {{2
		if !exists("g:colors_select")
			let g:colors_select = split(globpath(StripFrom(&rtp, ',.*'), 'colors/*.vim'))
			call map(g:colors_select, 'fnamemodify(v:val, ":t:r")')
			let g:colors_select = <SID>RemoveDuplicates(g:colors_select)
			let s:colors_index = 0
		elseif !exists("s:colors_index")
			let s:colors_index = 0
		else
			let s:colors_index = (s:colors_index+a:incr) % len(g:colors_select)
		endif
		call <SID>SetColorScheme(g:colors_select[s:colors_index])
	endfunction " }}

	" list of color schemes to select from
	let g:colors_select = [ 'wombat256mod', 'zenburn', 'desert256' ]

	" select the color scheme
	unlet! s:colors_index
	call <SID>AdvanceColorScheme(1)
endif

" Section: autocommands {{1
if !has('autocmd')
	" always set autoindenting on
	set autoindent
else
	" enable file type detection
	" also load indent files for language-dependent indenting
	filetype plugin indent on

	" default group {{2
	augroup vimrc
		au!
		" don't auto-split lines
		au BufReadPre  * set textwidth=0

		" restore cursor position, except when the position is invalid or
		" when inside an event handler (when dropping a file on gvim)
		au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

		" open all folds by default
		au BufReadPost * normal! zR

		" enable soft tab stops
		au BufWinEnter * let &softtabstop=&shiftwidth

		" reading Word documents
		au BufReadPre  *.doc set readonly
		au BufReadPost *.doc %! antiword "%"
	augroup END

	" binary mode and hex editing {{2
	" see vim -b
	augroup Binary
		au!
		au BufReadPre  *.bin,*.hex setlocal binary
		" handle file writes properly
		au BufWritePre *
			\	if exists("b:edit_hex") && b:edit_hex && &binary
			\|		let ro_save = &ro | set noreadonly
			\|		let ma_save = &ma | set modifiable
			\|		exec '%!xxd -r'
			\|		let &ro = ro_save | let &ma = ma_save
			\|		unlet ro_save | unlet ma_save
			\|	endif
		au BufWritePost *
			\	if exists("b:edit_hex") && b:edit_hex && &binary
			\|		let ro_save = &ro | set noreadonly
			\|		let ma_save = &ma | set modifiable
			\|		exec '%!xxd'
			\|		exe "set nomod"
			\|		let &ro = ro_save | let &ma = ma_save
			\|		unlet ro_save | unlet ma_save
			\|	endif
	augroup END
	" }}
endif

" Section: commands {{1
" diff {{2
" DiffOrig: compare the current buffer and the saved file
command! -nargs=0 DiffOrig
	\	vertical new
	\|	set buftype=nofile
	\|	read #
	\|	0 delete _
	\|	diffthis
	\|	wincmd p
	\|	diffthis

" DiffRegs: diff contents of two registers {{3
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
endfunction " }}

" registers {{2
" Reg: check full contents of registers (@", @*, and @+ by default)
" usage: Reg abc to see registers a, b, c
command! -nargs=? Reg call s:Reg(<q-args>)
function! s:Reg(regstr)
	if a:regstr == ''
		let regs = '"*+'
	else
		let regs = a:regstr
	endif
	for i in range(len(regs))
		let reg = regs[i]
		let contents = getreg(reg)
		if contents != ''
			echohl Visual | echo '"'.reg | echohl None
			echo contents
		endif
	endfor
endfunction

" ClearRegister: clear a register (@" and @z by default)
command! -nargs=0 -register ClearRegister
	\	if '<reg>' != ''
	\|		let @<reg> = @_
	\|	else
	\|		let @" = @_
	\|		let @z = @_
	\|	endif

" files {{2
" TabOpen: open files in new tabs, with globbing {{3
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
endfunction " }}

" CD: change the working directory to the current file's directory
command! -nargs=0 CD exec 'cd' expand('%:h')

" BD: delete all buffers
command! -nargs=0 BD bufdo bdelete

" RmFile: delete current file from disk
command! -nargs=0 RmFile echo "rm" @% "(".delete(@%).")"

" settings and views {{2
" Marker: highlight with RightMargin beyond a column number
command! -nargs=? Marker
	\	if <q-args> != ''
	\|		try
	\|			match RightMargin /\%><args>v.\+/
	\|		catch | endtry
	\|	else
	\|			match
	\|	endif

" TextWidth: check/set textwidth
command! -nargs=? TextWidth
	\	if <q-args> != ''
	\|		setlocal textwidth=<args>
	\|	else
	\|		set tw?
	\|	endif

" FontSize: change the current font size {{3
command! -nargs=? FontSize call s:FontSize(<q-args>)
function! s:FontSize(op)
	if !has('gui_running')
		call <SID>WarningMsg("Not available in terminal")
	elseif a:op == ''
		echo &guifont
	else
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
	endif
endfunction

" BigFont: embiggen font
command! -nargs=? BigFont
	\	if <q-args> != ''
	\|		call s:FontSize(<args>)
	\|	else
	\|		call s:FontSize(24)
	\|	endif
	\|	set lines=13 columns=47

" Lines Columns: check/set the number of usable lines/columns {{3
command! -nargs=? Lines call s:Lines(<q-args>)
function! s:Lines(arg)
	let extra = &cmdheight
	if &showtabline
		if &showtabline == 2 || tabpagenr('$') > 1
			let extra += 1
		endif
	endif
	if a:arg != ''
		exec 'set lines='.(a:arg+extra)
	else
		echo winheight(winnr())
	endif
endfunction
command! -nargs=? Columns
	\	if <q-args> != ''
	\|		try
	\|			if &number	| exec 'set columns='.(len(line('$'))+1+<args>)
	\|			else		| set columns=<args>
	\|			endif
	\|		catch | endtry
	\|	else
	\|			if &number	| echo winwidth(winnr())-len(line('$'))-1
	\|			else		| echo winwidth(winnr())
	\|			endif
	\|	endif

" editing {{2
" CopyMatches CutMatches: copy/cut matches of the last search to a register (default is ") {{3
" only works for single-line searches
" accepts a range (default is the whole file)
" matches are appended to the register and each match is terminated by \n
command! -range=% -nargs=0 -register CopyMatches
	\ call s:GetMatches(<line1>, <line2>, "<reg>", 1)
command! -range=% -nargs=0 -register CutMatches
	\ call s:GetMatches(<line1>, <line2>, "<reg>", 0)

function! s:GetMatches(line1, line2, reg, copy)
	let ic_save = &ignorecase
	set noignorecase
	let reg = a:reg != '' ? a:reg : '"'
	call setreg(reg, @_, '')
	if a:copy
		try
			exec 'silent' a:line1.','.a:line2.'s//\=(setreg(reg, submatch(0), "al")?"":submatch(0))/g'
			silent undo
		catch /E486/
		endtry
	else
		exec a:line1.','.a:line2.'s//\=(setreg(reg, submatch(0), "al")?"":"")/ge'
	endif
	let &ic = ic_save
endfunction

" Reverse: reverse lines in range {{3
command! -range -nargs=0 Reverse
	\	let @z = @/
	\|	<line2>mark a
	\|	<line1>,<line2>g/^/m'a
	\|	let @/ = @z

" LeadingSpacesToTabs: convert as many leading spaces to tabs as possible {{3
command! -range=% -nargs=? LeadingSpacesToTabs
	\ call s:LeadingSpacesToTabs(<line1>, <line2>, <q-args>)
function! s:LeadingSpacesToTabs(line1, line2, arg)
	let ts = str2nr(a:arg)
	if ts <= 0
		let ts = &tabstop
	endif
	for line in range(a:line1, a:line2)
		while len(matchstr(getline(line), '^\t*\zs \+')) >= ts
			exec line.'s/^\(\t*\) \{'.ts.'}/\1\t/'
		endwhile
	endfor
endfunction

" ExpandTabs: expand all tabs to spaces, or to the argument given {{3
command! -range=% -nargs=? ExpandTabs call s:ExpandTabs(<line1>, <line2>, <q-args>)
function! s:ExpandTabs(line1, line2, arg)
	if a:arg == ''
		let fill = ' '
	else
		let fill = a:arg
	endif
	let fill_len = Strlen(fill)
	let last = matchstr(fill, '.$')
	let tabpat = '\v^([^\t]*)(\t+)'
	for line in range(a:line1, a:line2)
		while match(getline(line), tabpat) != -1
			let list = matchlist(getline(line), tabpat)
			let len = len(list[2])*&tabstop - Strlen(list[1])%&tabstop
			exec line.'s/^[^\t]*\zs\t\+/'.
				\repeat(fill, len/fill_len).repeat(last, len%fill_len).'/'
		endwhile
	endfor
endfunction

" InternalTabsToSpaces: expand tabs within lines (used for alignment) to spaces {{3
command! -range=% -nargs=0 InternalTabsToSpaces
	\ call s:InternalTabsToSpaces(<line1>, <line2>)
function! s:InternalTabsToSpaces(line1, line2)
	let tabpat = '\v^\t*([^\t]+)(\t+)'
	for line in range(a:line1, a:line2)
		while match(getline(line), tabpat) != -1
			let list = matchlist(getline(line), tabpat)
			exec line.'s/^\t*[^\t]\+\zs\t\+/'.
				\repeat(' ', len(list[2])*&tabstop - Strlen(list[1])%&tabstop).'/'
		endwhile
	endfor
endfunction

" Overline Underline DoubleUnderline Strikethrough: modify selected text using combining diacritics {{3
command! -range -nargs=0 Overline        call s:CombineSelection(<line1>, <line2>, '0305')
command! -range -nargs=0 Underline       call s:CombineSelection(<line1>, <line2>, '0332')
command! -range -nargs=0 DoubleUnderline call s:CombineSelection(<line1>, <line2>, '0333')
command! -range -nargs=0 Strikethrough   call s:CombineSelection(<line1>, <line2>, '0336')
function! s:CombineSelection(line1, line2, cp)
	exec 'let char = "\u'.a:cp.'"'
	exec a:line1.','.a:line2.'s/\%V[^[:cntrl:]]\%V/&'.char.'/ge'
endfunction

" CodeReadability: insert whitespace, and other mods for readability {{3
command! -range=% -nargs=0 CodeReadability call s:CodeReadability(<line1>, <line2>)
function! s:CodeReadability(line1, line2)
try
	let range = a:line1.','.a:line2
	exec range.'s/\([^-+*/%&^|=!<>[:space:]]\)\(\%([-+*/%&^|=!<>]\|<<\|>>\)\?=\)\([^=[:space:]]\)/\1 \2 \3/ge'
	exec range.'s/\(\w\|)\)\([<>]\)\(\w\|(\)/\1 \2 \3/ge'
	exec range.'s/\(\%(el\|els\|else\)if\|for\|while\|until\)(/\1 (/ge'
	exec range.'s/){/) {/ge'
	exec range.'s/}\(else\|\%(el\|els\|else\)if\)/} \1/ge'
	exec range.'s/\(else\|\%(el\|els\|else\)if\){/\1 {/ge'
	exec range.'s/\<return\>\([^;[:space:]]\)/return \1/ge'
	" user confirm:
	exec range.'s/\(\w\|[]})"'."'".']\)\zs,\ze\(\w\|[[{("'."'".']\)/, /gec'
catch /^Interrupted$/ | endtry
endfunction

" Hexmode: toggle for hex mode {{3
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

" WordProcess Ascii: character conversion {{3
" convert quotes, apostrophes, and dashes into their unicode counterparts
command! -range=% -nargs=0 WordProcess call s:WordProcess(<line1>, <line2>)
function! s:WordProcess(line1, line2)
	let w = '[0-9A-Za-z]'
	let W = '[^0-9A-Za-z]'
	let punct = '[.,!?]'
	let range = a:line1.','.a:line2
	exec range.'s/\('.w.'\|\s\|"\|^\)\zs--\ze\('.w.'\|\s\|'.punct.'\|"\|$\)/—/ge'
	exec range.'s/'.punct.'\zs"\ze\('.W.'\|$\)/”/ge'
	exec range.'s/\('.W.'\|^\)\zs"\ze\S/“/ge'
	exec range.'s/\S\zs"\ze\('.W.'\|$\)/”/ge'
	exec range.'s/\('.W.'\|^\)\zs'."'".'\ze\S/‘/ge'
	exec range.'s/\S\zs'."'".'\ze\('.W.'\|$\)/’/ge'
	exec range.'s/'.w.'\zs'."'".'\ze\a/’/ge'
endfunction

" Ascii: enforce ASCII-ness
command! -range=% -nargs=0 Ascii call s:Ascii(<line1>, <line2>)
function! s:Ascii(line1, line2)
	let range = a:line1.','.a:line2
	exec range.'s/“/"/ge'
	exec range.'s/”/"/ge'
	exec range.'s/‘‘/"/ge'
	exec range.'s/’’/"/ge'
	exec range."s/‘/'/ge"
	exec range."s/’/'/ge"
	exec range.'s/—/--/ge'
endfunction
" }}2

" Section: mappings {{1
" see :help map-modes
" temp marks: 'a, 'z
" temp registers: @z
" basic {{2
" externally map CapsLock to Control
" <Nop> {{3
noremap			K			<Nop>
noremap			<C-E>		<Nop>
inoremap		<F1>		<Nop>
cnoremap		<C-K>		<Nop>

" common operations {{3
" use <Enter> to enter cmdline mode
noremap			<CR>		:
" disable in command-line window
au vimrc CmdwinEnter * unmap   <CR>
au vimrc CmdwinLeave * noremap <CR> :

" set <Space> to toggle a fold
noremap<silent><Space>		:<C-U>exec 'silent! normal! za'<CR>

" use <C-Space> as <Esc>
noremap			<C-Space>	<Esc>
inoremap		<C-Space>	<Esc>
cnoremap		<C-Space>	<C-\><C-N>

" deleting visual selections
xnoremap		<BS>		d
snoremap		<BS>		<BS>i

" save shortcut
nnoremap		<C-S>		:w<CR>
xnoremap		<C-S>		:<C-U>w<CR>gv
inoremap		<C-S>		<C-O>:w<CR>

" force 'hlsearch'
nnoremap<silent>n			:set hlsearch<CR>n
nnoremap<silent>N			:set hlsearch<CR>N

" "fix" Vim behavior {{3
" make Y consistent with D and C
nnoremap		Y			y$

" don't clobber registers when doing character deletes
nnoremap		x			"_x
nnoremap		X			"_X
nnoremap		s			"_s

" paste X selection register
noremap!		<S-Insert>	<C-R>*

" motions {{3
" scrolling {{4
noremap			<C-J>		<C-E>
noremap			<C-K>		<C-Y>
noremap			<C-H>		3zh
noremap			<C-L>		3zl
" insert mode
inoremap		<C-J>		<C-X><C-E>
inoremap		<C-K>		<C-X><C-Y>

" move in virtual lines {{4
nnoremap		j			gj
xnoremap		j			gj
nnoremap		k			gk
xnoremap		k			gk
noremap			<Up>		gk
noremap			<Down>		gj

" cursor movment in insert and cmdline modes {{4
inoremap		<M-j>		<C-O>gj
inoremap		<M-k>		<C-O>gk
inoremap		<Down>		<C-O>gj
inoremap		<Up>		<C-O>gk

noremap!		<M-h>		<Left>
noremap!		<M-l>		<Right>
noremap!		<C-L>		<Right>

" emulate bash/emacs-like word movement and deletion {{4
noremap			<M-b>		b
noremap			<M-f>		w
noremap!		<M-b>		<S-Left>
noremap!		<M-f>		<S-Right>

" kill word
function! <SID>KillWord()
	return (col('.')==col('$') ? "\<Del>" : "\<C-O>de")
endfunction
inoremap<silent><M-d>		<C-R>=<SID>KillWord()<CR>
cnoremap		<M-d>		<Space><S-Right><C-W><BS>

" beginning/end of line
inoremap		<C-A>		<C-O>^
cnoremap		<C-A>		<Home>
noremap!		<C-E>		<End>

" delete char
cnoremap		<C-D>		<Del>

" remap original key functionality {{4
" insert previously inserted text
inoremap		<C-F>		<C-A>
" insert the character below the cursor
inoremap		<C-G>		<C-E>

" digraphs
noremap!		<C-B>		<C-K>

" redraw
noremap			<C-Y>		<C-L>
" }}

" text editing {{3
" wordwise yank from line above
inoremap<silent><M-y>		<C-C>:let @z = @"<CR>mz
							\:exec 'normal!' (col('.')==1 && col('$')==1 ? 'k' : 'kl')<CR>
							\:exec (col('.')==col('$')-1 ? 'let @" = @_' : 'normal! ye')<CR>
							\`zp:let @" = @z<CR>a

" do the opposite of the 'auto-insert comment leader' format option {{4
function! <SID>ToggleCommentLeader()
	if &formatoptions =~ 'r'
		set formatoptions-=r
	else
		set formatoptions+=r
	endif
endfunction
inoremap<silent><C-CR>		 <C-O>:call <SID>ToggleCommentLeader()<CR><CR>
							\<C-O>:call <SID>ToggleCommentLeader()<CR>

" yank, delete, paste with Meta {{4
" working with registers {{5

" yank/delete into register
vnoremap<silent><M-y>		:<C-U>exec 'normal gv"'.nr2char(getchar()).'y'<CR>
vnoremap<silent><M-d>		:<C-U>exec 'normal gv"'.nr2char(getchar()).'d'<CR>

" paste from register
function! <SID>PasteRegister(visual)
	exec 'normal '.(a:visual ? 'gv' : '').'"'.nr2char(getchar()).'p'
endfunction
noremap	<silent><M-r>		:<C-U>call <SID>PasteRegister(0)<CR>
vnoremap<silent><M-r>		:<C-U>call <SID>PasteRegister(1)<CR>
inoremap		<M-r>		<C-R>
" paste most recently used register
inoremap		<M-r><M-r>	<C-R>"

" windows-like shortcuts {{5
" select all
noremap			<M-a>		<C-\><C-N>ggVG
" cut
vnoremap		<M-x>		"+x
" yank
vnoremap		<M-c>		"+y
" paste
noremap			<M-v>		<C-\><C-N>"+gP
exec 'vnoremap <script> <M-v>' paste#paste_cmd['v']
exec 'inoremap <script> <M-v>' paste#paste_cmd['i']
cnoremap		<M-v>		<C-R>+
" }}

" increment/decrement all characters with <C-A> and <C-X> {{4
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
" works only if incrementing alphabetic chars is allowed ('nrformats')
" }}

" command line {{3
" recall command history, matching current line
cnoremap		<M-j>		<Down>
cnoremap		<M-k>		<Up>

" partial completion and list matches
cnoremap		<C-T>		<C-L><C-D>

" visual {{3
" indenting
xnoremap		<Tab>		>gv
xnoremap		<S-Tab>		<gv

" go from select mode to insert mode
snoremap		<M-h>		<C-\><C-N>`<i
snoremap		<M-l>		<C-\><C-N>`>a

" windows and tabs {{3
" switch between windows
nnoremap		<M-h>		<C-W>h
nnoremap		<M-l>		<C-W>l
nnoremap		<M-j>		<C-W>j
nnoremap		<M-k>		<C-W>k

" cycle tabs
noremap			<C-Tab>		:<C-U>tabnext<CR>
noremap			<C-S-Tab>	:<C-U>tabprevious<CR>

" misc {{3
if !has('gui_running') && &t_Co == 256

fun! Rave(time)
	let ravers = [ 'Number', 'String', 'Comment', 'Statement', 'Function', 'Special' ]
	let len = len(ravers)
	if !exists("s:wtf")
		let s:wtf = []
		let rand = localtime()
		for i in range(len)
			let rand += 232 / len
			let s:wtf += [ rand ]
		endfor
	endif
	for i in range(len)
		let s:wtf[i] = (s:wtf[i]+a:time) % 232
		if s:wtf[i] == 0
			let s:wtf[i] = 1
		elseif s:wtf[i] == 7  || s:wtf[i] == 8
			let s:wtf[i] = 9
		elseif s:wtf[i] == 15 || s:wtf[i] == 16
			let s:wtf[i] = 17
		endif
		exec "hi ".ravers[i]." ctermfg=".s:wtf[i]
	endfor
	hi! link Constant	Number
	hi! link PreProc	Number
	hi! link Identifier	Function
	hi! link Type		Function
	hi! link Keyword	Statement
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
silent! unlet s:wtf
map	<silent>	<M-->		:call Rave(1)<CR>
map	<silent>	<M-=>		:call Rave(64)<CR>

endif
" }}

" function keys {{2
" clear function and meta key mappings {{3
function! <SID>ClearMaps(modifiers, from, to)
	for n in range(a:from, a:to)
		for mod in a:modifiers
			exec 'noremap <silent> <'.mod.n.'> :<C-U>call <SID>WarningMsg("Unmapped")<CR>'
			exec 'silent! unmap! <'.mod.n.'>'
		endfor
	endfor
endfunction
call <SID>ClearMaps([ 'F', 'C-F', 'S-F', 'C-S-F' ], 1, 14)
call <SID>ClearMaps([ 'M-' ], 0, 9)

" <F1> to <F3>      plugins {{3
" toggle taglist
map				<F1>		:<C-U>TlistToggle<CR>
vmap			<F1>		:<C-U>TlistToggle<CR>gv
" toggle NERD Tree
map				<F2>		:<C-U>NERDTreeToggle<CR>
" toggle MRU
map				<C-F2>		:<C-U>MRU<CR>
" toggle yank ring
map				<F3>		:<C-U>YRShow<CR>
" toggle clipboard <C-F3> {{4
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
" }}

" <F4>              remove trailing whitespace {{3
function! <SID>Trim()
	%s/\s\+$//e
endfunction
noremap	<silent><F4>		:<C-U>let @z=@/<CR>maHmz:call <SID>Trim()<CR>:let @/=@z<CR>`zzt`a
vnoremap<silent><F4>		:<C-U>let @z=@/<CR>maHmz:call <SID>Trim()<CR>:let @/=@z<CR>`zzt`agv
inoremap<silent><F4>		<C-C>:let @z=@/<CR>maHmz:call <SID>Trim()<CR>:let @/=@z<CR>`zzt`agi

" <C-F4>            highlight characters beyond column ... {{3
map				<C-F4>		:<C-U>Marker<Space>
imap			<C-F4>		<C-O>:Marker<Space>

" <F5>              remove search highlighting {{3
map	<silent>	<F5>		:<C-U>nohlsearch<CR>
vmap<silent>	<F5>		:<C-U>nohlsearch<CR>gv
imap<silent>	<F5>		<C-O>:nohlsearch<CR>

" <C-F5>            toggle diff {{3
function! <SID>ToggleDiff()
	if &diff
		diffoff
		setlocal nowrap
		if exists("w:fdm_save")
			exec 'setlocal foldmethod='.w:fdm_save
		else
			setlocal foldmethod=indent
		endif
	else
		let w:fdm_save = &foldmethod
		diffthis
	endif
endfunction
map	<silent>	<C-F5>		:<C-U>call <SID>ToggleDiff()<CR>
vmap<silent>	<C-F5>		:<C-U>call <SID>ToggleDiff()<CR>gv
imap<silent>	<C-F5>		<C-O>:call <SID>ToggleDiff()<CR>

" <F6>              toggle list mode (show tabs) {{3
map	<silent>	<F6>		:<C-U>setlocal list! list?<CR>
vmap<silent>	<F6>		:<C-U>setlocal list! list?<CR>gv
imap<silent>	<F6>		<C-O>:setlocal list! list?<CR>

" <F7>              change tabstop {{3
function! <SID>NextTabstop()
	let stops = [ 2, 4, 8 ]
	for i in range(len(stops))
		if &tabstop == stops[i]
			exec 'setlocal tabstop='.stops[(i+1)%len(stops)]
			break
		endif
	endfor
	set ts?
endfunction
map	<silent>	<F7>		:<C-U>call <SID>NextTabstop()<CR>
vmap<silent>	<F7>		:<C-U>call <SID>NextTabstop()<CR>gv
imap<silent>	<F7>		<C-O>:call <SID>NextTabstop()<CR>

" <F8>              toggle line wrapping {{3
map	<silent>	<F8>		:<C-U>setlocal wrap! wrap?<CR>
vmap<silent>	<F8>		:<C-U>setlocal wrap! wrap?<CR>gv
imap<silent>	<F8>		<C-O>:setlocal wrap! wrap?<CR>

" <C-F8>            view textwidth/set maximum line length to ... {{3
" (set to 0 to disable auto-truncation)
map				<C-F8>		:<C-U>TextWidth<Space>
imap			<C-F8>		<C-O>:TextWidth<Space>

" <F9> <C-F9>       cycle color schemes {{3
map	<silent>	<F9>		:<C-U>call <SID>AdvanceColorScheme( 1)<CR>:echo g:colors_name<CR>
vmap<silent>	<F9>		:<C-U>call <SID>AdvanceColorScheme( 1)<CR>:echo g:colors_name<CR>gv
imap<silent>	<F9>		<C-C>:call <SID>AdvanceColorScheme( 1)<CR>:echo g:colors_name<CR>gi
map	<silent>	<C-F9>		:<C-U>call <SID>AdvanceColorScheme(-1)<CR>:echo g:colors_name<CR>
vmap<silent>	<C-F9>		:<C-U>call <SID>AdvanceColorScheme(-1)<CR>:echo g:colors_name<CR>gv
imap<silent>	<C-F9>		<C-C>:call <SID>AdvanceColorScheme(-1)<CR>:echo g:colors_name<CR>gi

" <S-F9>            cycle fonts {{3
map	<silent>	<S-F9>		:<C-U>call <SID>AdvanceFont(1)<CR>:echo &guifont<CR>
vmap<silent>	<S-F9>		:<C-U>call <SID>AdvanceFont(1)<CR>:echo &guifont<CR>gv
imap<silent>	<S-F9>		<C-C>:call <SID>AdvanceFont(1)<CR>:echo &guifont<CR>gi

" <F11>             maximize current window {{3
noremap			<F11>		<C-\><C-N><C-W>_<C-W>\|
vnoremap		<F11>		<C-\><C-N><C-W>_<C-W>\|gv

" <C-F10> <S-F10>   change window width, height {{3
noremap			<C-F10>		<C-\><C-N>3<C-W><
vnoremap		<C-F10>		<C-\><C-N>3<C-W><gv
noremap			<C-F11>		<C-\><C-N>3<C-W>>
vnoremap		<C-F11>		<C-\><C-N>3<C-W>>gv
noremap			<S-F10>		<C-\><C-N>3<C-W>-
vnoremap		<S-F10>		<C-\><C-N>3<C-W>-gv
noremap			<S-F11>		<C-\><C-N>3<C-W>+
vnoremap		<S-F11>		<C-\><C-N>3<C-W>+gv

" <F12>             toggle spellcheck and autocorrect {{3
function! <SID>ToggleSpellCorrect()
	if &spell
		iabclear
	else
		runtime spell/autocorrect.vim
	endif
	setlocal spell! spell?
endfunction
map	<silent>	<F12>		:<C-U>call <SID>ToggleSpellCorrect()<CR>
vmap<silent>	<F12>		:<C-U>call <SID>ToggleSpellCorrect()<CR>gv
imap<silent>	<F12>		<C-O>:call <SID>ToggleSpellCorrect()<CR>

" <C-F12>           toggle cursorline {{3
map	<silent>	<C-F12>		:<C-U>setlocal cursorline! cul?<CR>
vmap<silent>	<C-F12>		:<C-U>setlocal cursorline! cul?<CR>gv
imap<silent>	<C-F12>		<C-O>:setlocal cursorline! cul?<CR>

" <F13> <F14>       switch buffers {{3
map				<F13>		:<C-U>bprevious<CR>
map				<F14>		:<C-U>bnext<CR>

" <C-F13> <C-F14>   choose buffer; split all buffers into tabs {{3
map				<C-F13>		:<C-U>ls<CR>:buffer<Space>
map				<C-F14>		:<C-U>tab ball<CR>

" <S-F13> <S-F14>   redirect command-line output to @z; end redirect {{3
map				<S-F13>		:<C-U>let @z=@_<CR>:redir @z><CR>
vmap			<S-F13>		:<C-U>let @z=@_<CR>:redir @z><CR>gv
nmap			<S-F14>		:<C-U>redir END<CR>
vmap			<S-F14>		:<C-U>redir END<CR>gv
" }}

" macros {{2
let mapleader = '\'
" folding {{3
" close all folds except this
nnoremap<silent>ZZ			:exec 'silent! normal! zM'.foldlevel('.').'zozz'<CR>

" fold top level
noremap			zT			<C-\><C-N>:%foldclose<CR>

" font size {{3
if has('gui_running')
map	<silent>	<M-0>		:<C-U>call <SID>AdvanceFont(0)<CR>
vmap<silent>	<M-0>		:<C-U>call <SID>AdvanceFont(0)<CR>
map	<silent>	<M-->		:<C-U>FontSize -<CR>:set guifont?<CR>
vmap<silent>	<M-->		:<C-U>FontSize -<CR>:set guifont?<CR>gv
map	<silent>	<M-=>		:<C-U>FontSize +<CR>:set guifont?<CR>
vmap<silent>	<M-=>		:<C-U>FontSize +<CR>:set guifont?<CR>gv
endif

" files {{3
" load this file for editing and re-source
map	<silent>	<leader>v		:<C-U>TabOpen $MYVIMRC<CR>:if has('gui_running') \| exec 'set columns='.max([&columns,100]) \| endif<CR>
map				<leader>u		:<C-U>source  $MYVIMRC<CR>
" load config files for editing
map	<silent>	<leader>b		:<C-U>TabOpen ~/.bash{rc,_aliases,_hacks}<CR>:tabnext 2<CR>
map	<silent>	<leader>f		:<C-U>TabOpen ~/.mozilla/firefox/*.default/chrome/user{Content,Chrome}.css
											\ ~/Application\ Data/Mozilla/Firefox/Profiles/*.default/chrome/userChrome.css<CR>

" changing text {{3
" surround selected area (obsoleted by surround.vim)
xnoremap		'			<C-C>`>a'<C-C>`<i'<C-C>
xnoremap		(			<C-C>`>a)<C-C>`<i(<C-C>

" substitution cipher {{4
function! <SID>Scramble(str)
	let indexes = range(Strlen(a:str))
	let pairs = []
	while !empty(indexes)
		let i1 = remove(indexes, rand#randRange(len(indexes)))
		if empty(indexes) | break | endif
		let i2 = remove(indexes, rand#randRange(len(indexes)))
		call add(pairs, [i1, i2])
	endwhile
	let chars = split(a:str, '\zs')
	for pair in pairs
		if rand#randRange(10) > 2
			let c = chars[pair[0]]
			let chars[pair[0]] = chars[pair[1]]
			let chars[pair[1]] = c
		endif
	endfor
	return join(chars, '')
endfunction
function! <SID>R()
	if !exists("*rand#randRange") || !exists("*rand#srand")
		call <SID>ErrorMsg("rand.vim is not loaded")
		return
	endif
	let input = inputsecret('> ')
	if input !~ '^.\{4,}$'
		call <SID>ErrorMsg("Invalid key")
		return
	endif
	let key = str2nr(StripFrom(input, '\D'))
	for char in reverse(split(input, '\zs'))
		let key = key*((char2nr(char)-32)%95) + 11
		let key = key*1664525 + 1013904223
		if key < 0 | let key -= 0x80000000 | endif
	endfor
	let @z = <SID>GetSelection()
	if has('x11')
		let @* = @_
	else
		let @0 = @_
	endif
	let hash = str2nr(system('vim-cipher-hash '.key, @z))
	call rand#srand(key+hash)
	let ascii = range(33,126)
	let alpha1 = ''
	let alpha2 = ''
	while !empty(ascii)
		let c1 = nr2char(remove(ascii, rand#randRange(len(ascii))))
		let c2 = nr2char(remove(ascii, rand#randRange(len(ascii))))
		let alpha1 .= c1.c2
		let alpha2 .= c2.c1
	endwhile
	let @z = tr(@z, alpha1, alpha2)
	let @z = substitute(@z, '[^[:space:]]\+', '\=<SID>Scramble(submatch(0))', 'g')
	exec 'normal! gv"zp'
	let @1 = @_
	let @- = @_
	let @z = @_
	let @" = @_
endfunction
call exists("*rand#srand")
call exists("*rand#randRange")
xmap<silent>	<leader>r		:<C-U>call <SID>R()<CR>
" }}

" whitespace {{3
" expand tabs in selected lines to spaces
xmap<silent>	<leader>e		:<C-U>let @z=&et<CR>:set et<CR>gv:retab<CR>:let &et=@z<CR>
" convert spaces to tabs
xmap<silent>	<leader>t		:retab!<CR>

" insert expanded tabs (tabs as spaces)
inoremap<silent><leader><TAB>	<C-R>=repeat(' ', &tabstop - (virtcol('.')-1) % &tabstop)<CR>

" insert {{3
" append modeline
nnoremap<silent><leader>m		ovim:ts=4 sw=4 noet:<C-C>^
inoremap<silent><leader>m		 vim:ts=4 sw=4 noet:<C-C>^

" date
inoremap<silent><leader>dd		<C-R>=strftime('%Y-%m-%d')<CR>
" logdate
inoremap<silent><leader>l		<C-v>u25d81 <C-R>=strftime('%m/%d %a \| [] ')<CR><Left><Left>

" delete {{3
" delete into the null register
noremap			<leader>d		"_d
noremap			<leader>D		"_D
noremap			<leader>c		"_c
noremap			<leader>C		"_C

" delete the stretch of whitespace at or before the cursor
nnoremap<silent><leader><BS>	:normal! gE<CR>
								\:exec(getline('.')[col('.')-1]=~'\S' ? "normal! \<lt>Right>":"")<CR>
								\:exec(getline('.')[col('.')-1]=~'\s' ? 'normal! dw':'')<CR>

" diff {{3
nnoremap		du			:diffupdate<CR>

" jump between diffs
nnoremap		dN			[czz
nnoremap		dn			]czz

" quickfix {{3
noremap			<M-1>		<C-\><C-N>:cprevious<CR>
noremap			<M-2>		<C-\><C-N>:cnext<CR>
noremap			<M-3>		<C-\><C-N>:clist<CR>
noremap			<M-4>		<C-\><C-N>:make<Space><Up><CR>
cnoremap		<M-4>		<C-R>=expand('%:t:r')<CR>

" search {{3
" replace last search pattern
map				<leader>s		:%s///gc<Left><Left><Left>
xmap			<leader>s		:s///gc<Left><Left><Left>
" execute command on lines matching last search pattern
map				<leader>g		:g//

" search for a word
map				<leader>w		<C-\><C-N>/\<\><Left><Left>

" search for visually selected text {{4
function! <SID>FidgetWhitespace(pat)
	let pat = substitute(a:pat,'\_s\+$','\\s\\*', '')
	let pat = substitute(pat, '^\_s\+', '\\s\\*', '')
	return    substitute(pat,  '\_s\+', '\\_s\\+','g')
endfunction

" fuzzy whitespace
xnoremap<silent>*				<C-C>/\V<C-R>=<SID>FidgetWhitespace(escape(<SID>GetSelection(),'/\'))<CR><CR>
xnoremap<silent>#				<C-C>?\V<C-R>=<SID>FidgetWhitespace(escape(<SID>GetSelection(),'?\'))<CR><CR>

" exact match
xnoremap<silent><leader>*		<C-C>/\V<C-R>=substitute(escape(<SID>GetSelection(),'/\'),'\n','\\n','g')<CR><CR>
xnoremap<silent><leader>#		<C-C>?\V<C-R>=substitute(escape(<SID>GetSelection(),'?\'),'\n','\\n','g')<CR><CR>

" highlight without jumping {{4
xnoremap<silent><M-8>		:<C-U>let @/="\\V<C-R>=escape(<SID>FidgetWhitespace(escape(<SID>GetSelection(),'\')),'\"')<CR>"<CR>
"							exec "let @/='\\<".expand("<cword>")."\\>'"
nnoremap<silent><M-8>		:<C-U>normal! #*<CR>
inoremap<silent><M-8>		<C-O>:normal! #*<CR>

" regex quick-keys {{4
" parens
cnoremap		<leader>9		\(\)<Left><Left>
" brace multi, non-greedy multi
cnoremap		<leader>{		\{}<Left>
cnoremap		<leader>-		\{-}
" flexible whitespace
cnoremap		<leader>g		\_s\+

" }}2

" Section: plugins {{1
" ClipBrd {{2
let g:clipbrdDefaultReg = '+'

" echofunc {{2
let g:EchoFuncKeyPrev = '<M-p>'
let g:EchoFuncKeyNext = '<M-n>'
let g:EchoFuncMaxBalloonDeclarations = 6

" eregex {{2
nnoremap		<M-/>		:M/

" NERD Commenter {{2
let g:NERDBlockComIgnoreEmpty = 1
let g:NERDCommentWholeLinesInVMode = 2
let g:NERDDefaultNesting = 0
let g:NERDMenuMode = 0
let g:NERDSpaceDelims = 1
let g:NERDSexyComs = 0
let g:NERDCompactSexyComs = 0
let g:NERDShutUp = 1

" NERD Tree {{2
let g:NERDTreeWinPos = "right"

" session_dialog {{2
let g:SessionSaveDirectory = "~"
let g:SessionPath = ".,~"
"let g:SessionFilePrefix = ""
"let g:SessionFileSuffix = ""
let g:SessionDefault = ""
let g:SessionConfirmOverwrite = 0
let g:SessionQuitAfterSave = 0
let g:SessionCreateDefaultMaps = 1

" snippetsEmu {{2
let g:snip_start_tag = "\u2039"
let g:snip_end_tag = "\u203a"

" edit snippets for the current or given filetype
command! -nargs=* -complete=custom,EditSnippetsComplete EditSnippets
	\ call s:EditSnippets(<f-args>)
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
	return join(<SID>RemoveDuplicates(types), "\n")
endfunction

" speeddating {{2
let g:speeddating_no_mappings = 0

function! <SID>ToggleCtrlAX() " {{
if hasmapto('<Plug>SpeedDatingUp')
	unmap		<C-A>
	unmap		<C-X>
	unmap		d<C-A>
	unmap		d<C-X>
	nmap<silent><C-A>		:call <SID>OffsetCharacter(1)<CR>
	nmap<silent><C-X>		:call <SID>OffsetCharacter(-1)<CR>
	set nrformats+=alpha
	echo "charwise"
else
	nmap		<C-A>		<Plug>SpeedDatingUp
	nmap		<C-X>		<Plug>SpeedDatingDown
	xmap		<C-A>		<Plug>SpeedDatingUp
	xmap		<C-X>		<Plug>SpeedDatingDown
	nmap		d<C-A>		<Plug>SpeedDatingNowUTC
	nmap		d<C-X>		<Plug>SpeedDatingNowLocal
	set nrformats-=alpha
	echo "speeddating"
endif
endfunction " }}
map	<silent>	<leader><C-A>	:<C-U>call <SID>ToggleCtrlAX()<CR>
map	<silent>	<leader><C-X>	<leader><C-A>

" taglist {{2
let g:Tlist_Show_One_File = 1

" YankRing {{2
if !has('gui_win32')
	let g:yankring_history_file = ".vim_yankring_history"
else
	let g:yankring_history_file = "_vim_yankring_history"
endif
" rebind custom maps
function! YRRunAfterMaps()
nmap			Y			y$
nnoremap		x			"_x
nnoremap		X			"_X
nnoremap		s			"_s
endfunction
if exists("loaded_yankring") | call YRRunAfterMaps() | endif

" }}1
" vim:ts=4 sw=4 noet fdm=marker fmr={{,}} fdl=0:
