" Vim syntax file
" Last Change:  2009-09-25

if exists("b:current_syntax")
    finish
endif

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

syn case match
syn sync minlines=300

syn keyword     customKeywords      contained TODO
syn match       customEntry         "^\(#\|[A-Z]\w\+,\s[A-Z]\w\+ \d\+, 20\d\d\).*" contains=customDate,customKeywords
syn match       customDate          "20\d\d-\d\d-\d\d\|[A-Z]\w\+ \d\+, 20\d\d" containedin=customEntry
syn region      customLeader        start=/^\[\d\d:\d\d\]/ end=/: / contains=customTime,customName,customUser
syn match       customTime          containedin=customLeader "\[\d\d:\d\d\]"
syn match       customName          containedin=customLeader " \zs[^:]\+\ze: "
syn match       customUser          containedin=customLeader " \zs\(\(\w\+@\)\?[\x6f][\x72][\x61][\x6e][\x67][\x65][\x66][\x6f][\x6f][\x64][\x69][\x65]\(\.\w\{3}\)\?\|;\|[\u3070][\u304b][\u307f][\u305f][\u3044][^:]*\)\ze: "

hi def link customKeywords Todo
hi def link customEntry    Comment
hi def link customDate     String
hi def link customTime     Identifier
hi def link customName     Keyword
hi def link customUser     Constant

" hi! def link String

" hi! def link Comment

" hi! def link Special

" hi! def link Todo
"
" hi! def link Error

" hi! def link Function
" hi! def link Identifier
" hi! def link Type

" hi! def link Character
" hi! def link Constant
" hi! def link Float
" hi! def link Include
" hi! def link Number
" hi! def link PreProc

" hi! def link Conditional
" hi! def link Keyword
" hi! def link Label
" hi! def link Operator
" hi! def link Repeat
" hi! def link Statement

let b:current_syntax = "custom"

" vim:set ts=4 sw=4 et:
