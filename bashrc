# .bashrc
[ -z "$PS1" ] && return

umask 0022

#{{1 completion
if [ ! "${BASH_COMPLETION+set}" ]; then
	if [ -f "$HOME/.bash_completion" ]; then
		source "$HOME/.bash_completion"
	elif [ -f /etc/bash_completion ]; then
		source /etc/bash_completion
	fi
fi

#{{1 remap console keys
if [ -z "$DISPLAY" -a -f "$HOME/.loadkeys" ]; then
	(loadkeys "$HOME/.loadkeys" || sudo loadkeys "$HOME/.loadkeys") &>/dev/null
fi

#{{1 options and environment variables
#{{2 bash
shopt -s no_empty_cmd_completion
shopt -s checkwinsize	# if necessary, update LINES/COLUMNS after each command
shopt -s cmdhist		# multi-line histories
shopt -s dotglob		# include hidden files in pathname expansions
shopt -s extglob		# extended pattern matching
shopt -s histappend		# append to history file rather than overwrite
shopt -s nocaseglob		# case-insensitive matching

# ignore 2 EOF's before exiting
IGNOREEOF=1

# history file
export HISTFILE="$HOME/.commandline_history"
# max number of lines in history file
HISTFILESIZE=50000
# max number of commands
HISTSIZE=47000

# commands to exclude from history
HISTIGNORE='?:??:???:o*(o):dirs:free:clear:reset:exit'

# exclude duplicate commands and command lines starting with space
HISTCONTROL=ignoreboth

# time builtin format
TIMEFORMAT=$'\n%3lR\t%P%%'

# allow scripts access to window dimensions
export LINES COLUMNS

#{{2 pager
export PAGER=less
export LESS='-MiRSx4'
export LESS_TERMCAP_mb=$'\e[01;31m'		# blinking
export LESS_TERMCAP_md=$'\e[01;94m'		# begin bold
export LESS_TERMCAP_so=$'\e[01;90;103m'	# begin stand-out mode (search highlighting)
export LESS_TERMCAP_us=$'\e[01;36m'		# begin underline
export LESS_TERMCAP_me=$'\e[0m'			# end mode
export LESS_TERMCAP_se=$'\e[0m'			# end stand-out mode
export LESS_TERMCAP_ue=$'\e[0m'			# end underline

#{{2 text editors
export EDITOR=vim
export VISUAL=vim

#{{2 python
export PYTHONPATH="$HOME/code/lang/py/modules"
if [ -f "$HOME/.pythonrc" ]; then
	export PYTHONSTARTUP="$HOME/.pythonrc"
fi

#{{2 Cygwin
if [ "$(uname -o)" = "Cygwin" ]; then
	CYGWIN=$(uname -s)

	# TMP and TEMP are defined in the Windows environment
	# leaving them set to the default Windows temporary directory can have
	# unexpected consequences
	unset TMP TEMP
fi
#}}

#{{1 prompt
#{{2 main prompt
if [ "$TERM" = "linux" ]; then
	# long prompt (system console)
	PS1="\u@\h[\#]\W\$ "
else
	# short color prompt if possible (xterm etc.)
	if [ -x /bin/tput -o -x /usr/bin/tput ] && tput setaf 1 &>/dev/null || [ "$CYGWIN" ]
	then
		if type __git_ps1 &>/dev/null
		then GIT_PS1='\[\e['30';1m\]$(__git_ps1 "·%s")\[\e[0m\]'
		else GIT_PS1=
		fi
	PS1='$( if [ $? -eq 0 ]
			then echo "\[\e['30';1m\]·\[\e[0m\]"
			else echo "\[\e['31';1m\]·\[\e[0m\]"
			fi )\[\e['33';1m\]$(promptwd "\w")\[\e[0m\]'"$GIT_PS1"'\$ '
		unset GIT_PS1
	else
	PS1='[\#]\W\$ '
	fi
	# disable XON/XOFF
	[ -t 0 ] && stty -ixon
fi

#{{2 prompt command
PROMPT_COMMAND='history -a'
# set title bar
case "$TERM" in
xterm*|*rxvt*)
	PROMPT_COMMAND+=';echo -ne "\033]0;$USER@${HOSTNAME%%.*}:${PWD/#$HOME/~}\007"'
	;;
esac

#{{2 switch prompt
function PS1
{
	if [[ "$PS1" == *promptwd* ]]; then
		PS1=$(echo "$PS1" | awk '{ sub(/\$\(promptwd "\\w"\)/, "\\W"); print }')
	else
		PS1=$(echo "$PS1" | awk '{ sub(/\\W/, "$(promptwd \"\\w\")"); print }')
	fi
}
#function promptwd
#{
#	local top=$(echo "$1" | sed "s#\([^/]*/\)\(.*\)\(/[^/]\+/[^/]\+\)#\2#")
#	if [ "$top" = "$1" ]; then
#		echo "$1"
#	elif [ ${#top} -gt 5 ]; then
#		top="${top:0:3}"
#		top="${top%%/*}.."
#		echo "$1" | sed "s#\([^/]*/\)\(.*\)\(/[^/]\+/[^/]\+\)#\1$top\3#"
#	else
#		echo "$1"
#	fi
#}

#{{2 chroot
# set variable identifying the chroot you work in
if [ -z "$debian_chroot" -a -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi
PS1="${debian_chroot:+($debian_chroot)}$PS1"
#}}

#{{1 user bin directory
BIN="$HOME/bin"
function abspath #{{2
{
	[ $# -ne 1 ] && return 2
	local IFS=$'\n' abspath
	if [ -d "$1" ]; then
		abspath=$(cd -- "$1" 2>/dev/null && pwd)
	elif [ -e "$1" ]; then
		abspath=$(cd -- "$(dirname -- "$1")" 2>/dev/null && pwd) &&
		abspath="${abspath%/}/$(basename -- "$1")"
	else
		return 1
	fi
	if [ $? -eq 0 ]
	then echo "$abspath"
	else return 2
	fi
}
function lnbin #{{2
{
	[ ! -d "$BIN" ] && return 1
	local IFS=$'\n'
	local code=1 arg file
	for arg in "$@"; do
		for file in $(find "$arg" -maxdepth 1)
		do
			if [ -f "$file" -a -x "$file" ]; then
				ln -fs "$(abspath "$file")" "$BIN" && code=0
			fi
		done
	done
	return $code
}
#}}

#{{1 bootstrap scripts and set PATH
function addpath #{{2
{
	[ $# -ne 1 ] && return 2
	if ! echo "$PATH" | grep '\(:\|^\)'"$1"'\(:\|$\)' >/dev/null
	then PATH="$PATH:$1"
	else return 1
	fi
}
function addsource #{{2
{
	[ $# -eq 0 ] && return 2
	local -i code=0
	local arg
	for arg in "$@"; do
		if [ -f "$arg" ]
		then source "$arg"
		else false
		fi
		code+=$?
	done
	return $code
}
#}}

addpath /usr/local/bin
addsource "$HOME/.bash_aliases"

if [[ "$TERM" != "dumb" || "$CYGWIN" ]]; then
	addsource "$HOME/.bash_hacks"
	addpath .
fi
#}}

# done
true
# vim:ts=4 sw=4 noet fdm=marker fmr={{,}} fdl=0:
