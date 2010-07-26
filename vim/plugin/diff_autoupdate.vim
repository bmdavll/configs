"===========================================================================
" File:         diff_autoupdate.vim
" Last Change:  2010-07-25
"
" Description:
" When doing a diff, automatically update the differences when leaving
" insert mode, upon writing changes to a file, or when the cursor hasn't
" moved in a while and there have been changes.
"
"===========================================================================

function! s:DiffUpdate()
	diffupdate
	let b:diff_changedtick = b:changedtick
endfunction

augroup DiffAutoUpdate
	au!
	au InsertLeave  * if &diff | call s:DiffUpdate() | endif
	au BufWritePost * if &diff | call s:DiffUpdate() | endif
	au CursorHold *
		\ if &diff && (!exists("b:diff_changedtick") || b:diff_changedtick != b:changedtick)
		\|	call s:DiffUpdate()
		\|endif
augroup END

nnoremap <silent> do do:let b:diff_changedtick = b:changedtick<CR>
nnoremap <silent> dp dp<C-W>w:if &modifiable && &diff \| let b:diff_changedtick = b:changedtick \| endif<CR><C-W>p

" vim:ts=4 sw=4 noet:
