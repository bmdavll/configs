if !exists('loaded_snippet') || &cp
	finish
endif

let st = g:snip_start_tag
let et = g:snip_end_tag
let se = st.et

function! CustomFormat()
	%s/^\([a-z]\+\),\s\([a-z]\+\)\s\(\d\+\),\s\(20\d\d\)\s\(\S\+\)$/##1 \4-\2-\3 \5, \1/gi
	let months = {
				\'January':		'01',
				\'February':	'02',
				\'March':		'03',
				\'April':		'04',
				\'May':			'05',
				\'June':		'06',
				\'July':		'07',
				\'August':		'08',
				\'September':	'09',
				\'October':		'10',
				\'November':	'11',
				\'December':	'12'}
	%s/20\d\d-\zs[a-z]\+\ze-\d\+/\=months[submatch(0)]/ge
	%s/20\d\d-\d\d-\zs\d\ze\s/0&/ge
	%s/\n\n\+/\r/ge
endfunction
