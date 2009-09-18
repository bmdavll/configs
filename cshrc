alias cl	'cd'

alias la	'ls -A'
alias ll	'ls -lh'
alias lt	'ls -lht'

alias bd	'cd -'
alias ..	'cd ..'
alias ...	'cd ../..'
alias ....	'cd ../../..'

alias md	'mkdir -p'
alias rd	'rmdir'
alias rmr	'/bin/rm -r'

alias c		'chmod'
alias g		'grep'
alias j		'jobs'
alias hist	'history | sort -nr | less'
alias l		'less'
alias p		'pwd'
alias path	'echo $PATH | tr ":" "\n"'
alias x		'xargs'

alias py	'python'
alias wcl	'wc -l'

alias vi	'vim'
alias more	'less'

set prompt='%m[%h] %~ %?%# '
set autolist

setenv EDITOR	vim
setenv VISUAL	vim
setenv PAGER	less
setenv LESS		-Mi

# if (-d $HOME/bin) then
#     setenv PATH ${PATH}:$HOME/bin
# endif

# source ~ctest/bin/setup

# vim:set ts=4 sw=4 noet ft=tcsh syn=tcsh:
