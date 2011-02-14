" my defined filetypes
if exists("did_load_filetypes")
	finish
endif

augroup filetypedetect
	au BufRead,BufNewFile *.vimp	setfiletype vimperator
	au BufRead,BufNewFile *.ntj		setfiletype javascript
	au BufRead,BufNewFile *.ntl		setfiletype javascript
	au BufRead,BufNewFile *.nip		setfiletype javascript
augroup END

