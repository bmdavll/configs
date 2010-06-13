" my defined filetypes
if exists("did_load_filetypes")
	finish
endif

augroup filetypedetect
	au! BufRead,BufNewFile *.vimp		setfiletype vimperator
augroup END

