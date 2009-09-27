#!/bin/bash
# bash aliases and command-line functions
## convenience variables and utility functions {{{
NBSP=' '

# patterns
HELP_PAT='^-[?]'

# file matchers
CODE_PAT='?*.@(c|C|cc|cpp|h|H|hh|hpp|java|cs|py|rb|pl|sh|vim|js|php|l|y)'
# the '*' before a literal is a compgen hack
MAKE_PAT='@(*[Mm]akefile|*configure)?(.@(ac|am|in))'
TEXT_PAT='@(*README|*INSTALL|?*.@(txt|log|rst))'

# return the maximum integer value from a list {{{
function max
{ :
	if [ $# -eq 0 ]; then
		return 1
	fi
	local -i code=0
	local arg val
	for arg in "$@"; do
		if [[ "$arg" =~ ^-?[0-9]+$ ]]; then
			if [ -z "$val" ]; then
				val=$arg
			elif [ $arg -gt $val ]; then
				val=$arg
			fi
		else
			code+=1
		fi
	done
	[ "$val" ] && echo "$val"
	return $code
} # }}}
# spawn gui application {{{
function gui
{ :
	if type "$1" &>/dev/null; then
		"$@" &>/dev/null &
		disown -r
	else
		return $?
	fi
} && GUI=gui
complete -c gui
# }}}
# check if a string or pattern matches any of the arguments that follow {{{
function str_in
{	:
	local arg str="$1" && shift
	[ $# -eq 0 ] && return 1
	for arg in "$@"; do
		[ "$arg" = "$str" ] && return 0
	done
}
function pat_in
{	:
	local arg pat="$1" && shift
	[ $# -eq 0 ] && return 1
	for arg in "$@"; do
		[[ "$arg" =~ $pat ]] && return 0
	done
}
# }}}
# function to split an argument list into options and non-options {{{
# clears and fills arrays OPTS and ARGV (use `split_opts -c' to unset)
# first parameter: one-character options that take arguments
#                  follow an option with '?' if the argument to it is optional
# parameters until first '--': list of long options that require an argument
# e.g. split_opts 'tq?cSd?ir?s' cmd servername -- "$@"
#      split_opts -- "$@"
function split_opts
{ : :
	local code=$?
	unset OPTS ARGV
	[ "$1" = "-c" ] && return $code
	code=0 OPTS=() ARGV=()
	local opt optional longopts=() argopts
	local nocaseglob=$(shopt -p nocaseglob) && shopt -u nocaseglob
	[ "$1" != "--" ] && argopts="$1" && shift
	if [[ "$argopts" == *?'?'* ]]; then
		for opt in $(echo "$argopts" | grep -o '.?'); do
			optional+="${opt%?}"
		done
		argopts=$(echo "$argopts" | sed 's/?//g')
	fi
	while [ $# -gt 0 ]; do
		opt="$1" && shift
		[ "$opt" = "--" ] && break
		longopts+=("$opt")
	done
	while [ $# -gt 0 ]; do
		if [[ "$1" =~ ^--(.*)$ ]]; then
			if [ -z "${BASH_REMATCH[1]}" ]; then
				OPTS+=('--')
				shift && break
			else
				OPTS+=("$1")
				if str_in "${BASH_REMATCH[1]}" "${longopts[@]}"; then
					if [ $# -gt 1 ]; then
						OPTS+=("$2")
						shift
					else
						code=1 && break
					fi
				fi
			fi
		elif [[ "$argopts" && "$1" =~ ^-[^$argopts]*([$argopts])(.*)$ ]]; then
			OPTS+=("$1")
			if [ -z "${BASH_REMATCH[2]}" ]; then
				if [ $# -gt 1 ]; then
					if [[ "${BASH_REMATCH[1]}" != [$optional] || "$2" != -?* ]]
					then
						OPTS+=("$2")
						shift
					fi
				elif [[ "${BASH_REMATCH[1]}" != [$optional] ]]; then
					code=1 && break
				fi
			fi
		elif [[ "$1" == -?* ]]; then
			OPTS+=("$1")
		else
			ARGV+=("$1")
		fi
		shift
	done
	eval "$nocaseglob"
	if [ $code -ne 0 ]; then
		unset OPTS ARGV
		return $code
	fi
	ARGV+=("$@")
}
# }}}

## from /etc/bash_completion
function quote_readline
{
	local arg="${1//\\/\\\\}"
	echo \'${arg//\'/\'\\\'\'}\'
}
# This function performs file and directory completion. It's better than
# simply using 'compgen -f', because it honors spaces in filenames.
# If passed -d, it completes only on directories.
function file_glob # {{{
{
	local IFS=$'\n'

	if [[ "$cur" == \~*/* ]]; then
		eval "cur=$cur"
	elif [[ "$cur" == \~* ]]; then
		cur="${cur#\~}"
		COMPREPLY=($(compgen -P '~' -u "$cur"))
		[ ${#COMPREPLY[@]} -ne 0 ] && return 0
	fi

	local toks=() tmp

	while read -r tmp; do
		[ -n "$tmp" ] && toks+=("$tmp")
	done < <(compgen -d -- "$(quote_readline "$cur")")

	if [ "$1" != "-d" ]; then
		while read -r tmp; do
			[ -n "$tmp" ] && toks+=("$tmp")
		done < <(compgen -f -X "${1:+!$1}" -- "$(quote_readline "$cur")")
	fi

	COMPREPLY+=("${toks[@]}")
} # }}}
## }}}
## command line essentials {{{
# colors {{{
if [ -x /bin/tput -o -x /usr/bin/tput ] && tput setaf 1 &>/dev/null; then :
	COLOR='--color=auto'
	if [ "$TERM" != "dumb" ] && [ -x /bin/dircolors -o -x /usr/bin/dircolors ]
	then
		if [ -f "$HOME/.dircolors" ]; then
			eval "$(dircolors -b $HOME/.dircolors)"
		else
			eval "$(dircolors -b)"
		fi
		alias ls="ls $COLOR"
	fi
	if echo "." | grep $COLOR "." &>/dev/null; then
		alias grep="grep $COLOR"
		alias egrep="egrep $COLOR"
		alias fgrep="fgrep $COLOR"
	fi
	unset COLOR
fi
# }}}
# ls {{{
function l # {{{
{ :
	local IFS=$'\n' arg
	split_opts 'IkpTw' -- "$@" || return $?
	set -- "${ARGV[@]}"
	if [ $# -eq 0 ]; then
		ls "${OPTS[@]}"
	else
		ARGV=()
		for arg in "$@"; do
			if [ -e "$arg" ]
			then ARGV+=("$arg")
			else ARGV+=($arg*)
			fi
		done
		ls "${OPTS[@]}" "${ARGV[@]}"
	fi
	split_opts -c
} # }}}
alias la='l -A'
alias ll='l -lh'
alias lt='l -lhtr'
alias lS='l -lhSr'

# ls links {{{
function lh
{ :
	if pat_in "$HELP_PAT" "$@"; then
		echo "Usage: lh [ls_argument|--soft|--hard]..." && return
	fi
	local soft='$1 ~ /^l/'
	local hard='$1 ~ /^-/ && $2 > 1'
	local arg argv=() unset
	for arg in "$@"; do
		if [ "$arg" = "--hard" ]; then
			[ ! "$unset" ] && unset soft && unset=1
			shift
		elif [ "$arg" = "--soft" ]; then
			[ ! "$unset" ] && unset hard && unset=1
			shift
		else
			argv+=("$arg")
		fi
	done
	[ ! "$unset" ] && soft+=' || '
	ls --color=always -lh "${argv[@]}" | awk '{
		if ($0 ~ /^total[[:blank:]]+[[:alnum:].]+$/) {
			next;
		} else if ( length($1) != 10 || $1 !~ /^.[r-][w-][xsS-]/ ||
					$7 !~ /^[0-9][0-9]:[0-9][0-9]$/ ) {
			if (header ~ /:\n$/)
				header = "";
			header = header $0 "\n";
		} else if ('"${soft}${hard}"') {
			if (header != "") {
				sub(/\n$/, "", header);
				if (! sep)
					sub(/^\n/, "", header);
				print header;
				header = "";
			}
			print $0; sep = 1;
		}
	}'
	return ${PIPESTATUS[0]}
} # }}}

# pipe to less with colors {{{
function _lsl
{ :
	local code=0 output ls="$1" && shift
	output=$([ "$ls" ] && $ls --color=always "$@") || code=$?
	if [ "$output" ]; then
		printf "%s" "$output" | less -R
	fi
	return $code
} # }}}
alias lsl='_lsl "l"'
alias lal='_lsl "l -A"'
alias lll='_lsl "l -lh"'
alias ltl='_lsl "l -lhtr"'
alias lSl='_lsl "l -lhSr"'
alias lhl='_lsl "lh"'

# selective ls {{{
# modes are code, other, hidden
# option -R will be ignored
_lsmode() { :
	local mode=$1 && shift
	case "$mode" in
	c)	ls -d "$@" @($CODE_PAT|$MAKE_PAT) 2>/dev/null
		;;
	o)	ls -d "$@" !($CODE_PAT|$MAKE_PAT) 2>/dev/null
		;;
	h)	ls -d "$@" .[^.]* 2>/dev/null
		;;
	esac
}
_ls_special() { :
	if pat_in "$HELP_PAT" "$@"; then
		echo "Usage: ls$1 [ls_option|directory]..." && return
	fi
	local -i code=0
	local IFS=$'\n' mode=$1 && shift
	split_opts 'IkpTw' -- "$@" || return $?
	set -- "${ARGV[@]}"
	if [ $# -eq 0 ]; then
		_lsmode "$mode" "${OPTS[@]}"
		code+=$?
	else
		local dir sep error=1
		for dir in "$@"; do
			if pushd -- "$dir" &>/dev/null; then
				[ $# -gt 1 ] && echo "$sep$dir:" && sep=$'\n'
				_lsmode "$mode" "${OPTS[@]}" && error=0
				popd >/dev/null
				continue
			elif [ -d "$dir" ]; then
				echo >&2 "ls$mode: cannot open directory $dir: Permission denied"
			elif [ -e "$dir" ]; then
				echo >&2 "ls$mode: cannot open $dir: Not a directory"
			else
				echo >&2 "ls$mode: cannot access $dir: No such file or directory"
			fi
			code+=1
		done
		code+=$error
	fi
	split_opts -c
	return $code
}
alias lsc='_ls_special c'
alias lso='_ls_special o'
alias lsh='_ls_special h'
# }}}

alias cls='clear && ls'

# completion
complete -A directory lh lhl lsc lso lsh
# }}}
# changing directories {{{
alias bd='cd - >/dev/null'
alias CD='cd "$(readlink -m "$PWD")"'

function c
{ :
	local IFS=$'\n'
	if [ $# -gt 0 -a ! -d "$1" ]; then
		local try=$(ls -d $1* 2>/dev/null)
		[ ! -d "$try" ] && try=$(dirname -- "$1")
		if [ -d "$try" -a ! "$try" -ef "$PWD" ]; then
			shift
			set -- "$try" "$@"
		fi
	fi
	cd "$@"
}
# cd and ls in new directory {{{
function cl
{ :
	if pat_in "$HELP_PAT" "$@"; then
		echo "Usage: cl [ls_option|directory]..." && return
	fi
	split_opts 'IkpTw' -- "$@" || return $?
	c "${ARGV[@]}" && ls "${OPTS[@]}"
	split_opts -c
}
# macro for inputrc binding
function cll
{ : :
	if pat_in "$HELP_PAT" "$@"; then
		echo "Usage: cll [ls_option]..." && return
	fi
	local opts=("$@") args=() arg
	set -- $(tail -n1 "$HISTFILE" 2>/dev/null | sed 's/[&|!<>;]//g')
	while [ $# -gt 0 ]; do
		args[$#]="$1" && shift
	done
	for arg in "${args[@]}"; do
		if [ ! -d "$arg" ]; then
			arg=$(dirname -- "$arg")
			[ "$arg" = . ] && continue
		fi
		if [ -d "$arg" -a ! "$arg" -ef "$PWD" -a "$arg" != '/' ]; then
			cl "${opts[@]}" -- "$arg"
			return
		else
			continue
		fi
	done
	return 1
}
# }}}
complete -A directory cd c cl

# push/pop
alias pu='pushd'
alias pp='popd'
alias dirs='dirs -v'
complete -A directory pu
# }}}

# mk/rmdir
alias md='mkdir -p'
alias rd='rmdir'
complete -A directory rd

# remove current directory (if empty)
function rcd
{ :
	[ $# -ne 0 ] && return 2
	rmdir "$PWD" && cd ..
}

# find {{{
_finder() { :
	if pat_in "$HELP_PAT" "$@"; then
		echo "Usage: [find_option|path|iname|^exclude]... [find_spec]..." && return
	fi
	local IFS=$'\n' specs=() opts=() paths=() special gflag pat i
	local nocaseglob=$(shopt -p nocaseglob) && shopt -u nocaseglob
	# parse {{{
	if [[ "$1" && "$1" != [-\!\(]* || "$1" == -[PLHO]* ]]; then
		gflag=1
	elif [[ "$1" == -special* ]]; then
		special="${1#-special }" && shift
	else
		specs=(${1// /$IFS}) && shift
	fi
	while [ $# -gt 0 ]; do
		if [[ "$1" == -[PLHO]* ]]; then
			opts+=("$1")
		elif [ -d "$1" ]; then
			paths+=("$1")
		elif [[ "$1" != [-\!\(]* ]]; then
			if [ "$gflag" ]; then
				pat="$1" && gflag=
			elif [[ "$1" == ^* ]]; then
				[ "${1:1}" ] && specs+=(! -path "*${1:1}*")
			elif [ "$1" ]; then
				unset i && [[ "$1" == *[A-Z]* ]] || i=i
				specs+=(-${i}name "$1")
			fi
		else
			break
		fi
		shift
	done
	[ ${#paths[@]} -eq 0 ] && paths='.'
	# }}}
	# execute {{{
	[ "$special" = "ed" ] && specs=(-depth -mindepth 1 "${specs[@]}")
	local args=("${opts[@]}" "${paths[@]}" "${specs[@]}")
	if [ "$special" ]; then
		case "$special" in
		bk)	# backup files
			find "${args[@]}" \( -name "*~" -o -name "*.bak" -o -name "*.swp" -o \
								 -name "a.out" -o -name "foo" \) "$@"
			;;
		bl)	# broken links
			find -L "${args[@]}" -type l "$@"
			;;
		ed)	# empty directories
			local dir
			for dir in $(find "${args[@]}" -type d "$@"); do
				[ -z "$(find "$dir" ! -type d)" ] && echo "$dir"
			done
			return 0
			;;
		*)	return 2
			;;
		esac
	elif [ -z "$pat" ]; then
		find "${args[@]}" "$@"
	else
		type _sd &>/dev/null && pat=$(_sd "$pat")
		unset i && [[ "$pat" == *[A-Z]* ]] || i=i
		local result
		for result in \
		$(find "${args[@]}" -regextype 'posix-egrep' -${i}regex ".*$pat[^/]*" "$@")
		do
			echo -n "$(dirname -- "$result")/"
			if ! echo "$(basename -- "$result")" | egrep -${i}e "$pat"; then
				echo "$(basename -- "$result")"
			fi
		done
	fi
	# }}}
	eval "$nocaseglob"
}
alias findg='_finder'
alias findn='_finder ""'
alias findf='_finder "-type f"'
alias findd='_finder "-depth -type d"'
alias findl='_finder "-maxdepth 1 -mindepth 1"'

alias findbk='_finder "-special bk"'
alias findbl='_finder "-special bl"'
alias finded='_finder "-special ed"'

_rm_special() { :
	local -i code=0
	local line spec="-special $1" && shift
	_finder "$spec" "$@" | while read line
	do
		rm -r "$line" || code+=$?
	done
	return $code
}
alias rmbk='_rm_special bk'
alias rmbl='_rm_special bl'
alias rmed='_rm_special ed'

complete -F _find -o filenames -o default \
findg findn findf findd findl findbk findbl finded rmbk rmbl rmed
# }}}
# rm {{{
alias rmr='rm -r'

# secure rm with shred
function rms
{ :
	split_opts -- "$@" || return $?
	if [ ${#ARGV[@]} -eq 0 ] || pat_in "$HELP_PAT" "$@"; then
		split_opts -c
		echo "Usage: rms [rm_option|file|dir]..." && return
	fi
	find "${ARGV[@]}" -type f -print0 | xargs -0r shred -zn 3
	if [ "$(max "${PIPESTATUS[@]}")" -eq 0 ]
	then rm -r "${OPTS[@]}" "${ARGV[@]}"
	else false
	fi
	split_opts -c
}

# files recursively
function rmf
{ :
	split_opts -- "$@" || return $?
	if [ ${#ARGV[@]} -eq 0 ] || pat_in "$HELP_PAT" "$@"; then
		split_opts -c
		echo "Usage: rmf [rm_option|file|dir]..." && return
	fi
	local code=0 arg
	for arg in "${ARGV[@]}"; do
		if [ -d "$arg" ]; then
			find "$arg" ! -type d -exec rm "${OPTS[@]}" {} +
		elif [ -e "$arg" ]; then
			rm "${OPTS[@]}" "$arg"
		else
			echo >&2 "rm: cannot remove \`$arg': No such file or directory"
			false
		fi
		code=$(max $code "${PIPESTATUS[@]}")
	done
	split_opts -c
	return $code
}
# }}}
# mv {{{
_echodo() { :
	echo "$@" && "$@"
}
_swap() { :
	[ $# -ne 2 -o ! -e "$1" ] && return 1
	local PREF_A PREF_B BASE_A BASE_B mv
	PREF_A=$(dirname -- "$1") && BASE_A=$(basename -- "$1")
	PREF_B=$(dirname -- "$2") && BASE_B=$(basename -- "$2")
	shift 2
	if [[ "$BASE_A" =~ ^'..'?$ || "$BASE_B" =~ ^'..'?$ ]]; then
		return 1
	fi
	if [ "$PREF_A" = "." ]
	then PREF_A=
	else PREF_A="$PREF_A/"
	fi
	if [ "$PREF_B" = "." ]
	then PREF_B=
	else PREF_B="$PREF_B/"
	fi
	if [ "${_swap_hook:+set}" ]
	then mv="$_swap_hook"
	else mv=mv
	fi
	if [ ! -e "${PREF_B}$BASE_B" ]; then
		_echodo $sudo $mv "${PREF_A}$BASE_A" "${PREF_B}$BASE_B"
	elif [ "$mv" != "mv" ]; then
		_echodo $sudo $mv -Ti "${PREF_A}$BASE_A" "${PREF_B}$BASE_B"
	else
		_echodo $sudo mv -Ti "${PREF_A}$BASE_A" "${PREF_A}__${BASE_A}__"
		if [ ! -e "${PREF_A}$BASE_A" ]; then
			_echodo $sudo mv -Ti "${PREF_B}$BASE_B" "${PREF_A}$BASE_A" &&
			_echodo $sudo mv -Ti "${PREF_A}__${BASE_A}__" "${PREF_B}$BASE_B"
		else
			return 1
		fi
	fi
}
function swap
{ :
	if  [[ $# -le 1 || -z "$1" ]] || pat_in "$HELP_PAT" "$@"; then
		echo "Usage: swap [-s] file_a file_b"
		echo "       swap [-s] ext_a [ext_b] file..."
		return
	fi
	local -i code=0
	local EXT_A EXT_B S='.' file dest sudo
	split_opts -- "$@" || return $?
	str_in '-s' "${OPTS[@]}" && sudo=sudo
	set -- "${ARGV[@]}"
	split_opts -c
	if [ $# -eq 2 ] && [[ -d "$1" && -d "$2" || -f "$1" && -f "$2" ]]; then
		_swap "$@"
		return
	fi
	EXT_A="$1" && shift
	if [[ -e "$1" || "$1" == */* ]]
	then EXT_B=
	else EXT_B="$1" && shift
	fi
	for file in "$@"; do
		file=$(echo "$file" | sed 's|/*$||')
		if [ ! -e "$file" ]; then
			! echo >&2 "$file: No such file or directory"
		elif [ "$EXT_B" ]; then
			if [ -e "$file${S}$EXT_A" ]; then
				_echodo $sudo mv -Ti "$file" "$file${S}$EXT_B" &&
				_echodo $sudo mv -Ti "$file${S}$EXT_A" "$file"
			elif [ -e "$file${S}$EXT_B" ]; then
				_echodo $sudo mv -Ti "$file" "$file${S}$EXT_A" &&
				_echodo $sudo mv -Ti "$file${S}$EXT_B" "$file"
			elif [[ "$file" == *"${S}$EXT_A" ]]; then
				_swap "$file" "${file%${S}$EXT_A}${S}$EXT_B"
			elif [[ "$file" == *"${S}$EXT_B" ]]; then
				_swap "$file" "${file%${S}$EXT_B}${S}$EXT_A"
			else
				! echo >&2 "$file: No match"
			fi
		else
			if [[ "$file" == *"${S}$EXT_A" ]]; then
				dest="${file%${S}$EXT_A}"
			elif [[ "$file" =~ (.+)"${S}$EXT_A${S}"(.+) ]]; then
				dest="${BASH_REMATCH[1]}${S}${BASH_REMATCH[2]}"
			else
				dest="$file${S}$EXT_A"
			fi
			_swap "$file" "$dest"
		fi
		[ $? -ne 0 ] && code+=1
	done
	return $code
}
alias bak='swap bak ""'
alias cbak='_swap_hook="cp -a" swap bak ""'
# }}}
# jobs {{{
function psgrep
{ :
	if pat_in "$HELP_PAT" "$@"; then
		echo "Usage: psgrep [-ps_option] [pattern]..." && return
	fi
	local psopts
	if [[ "$1" == -* ]]
	then psopts="$1" && shift
	else psopts="-o comm"
	fi
	local arg procs=$(ps -e $psopts | egrep -v '^(ps|COMMAND|egrep)$')
	for arg in "$@"; do
		procs=$(echo "$procs" | egrep -e "$arg")
	done
	[ "$procs" ] && echo "$procs" | egrep -e "$arg"
}
# killall
alias ka='killall -u $USER -ir'
alias ok='sudo killall -9 -ir'
_psgrep() { :
	local args
	if [ $# -gt 3 ]
	then args=("${@:4}")
	else args=(-e)
	fi
	COMPREPLY=($( compgen -W "$(ps -o comm "${args[@]}" | sort -u
				  egrep -v '^(ps|COMMAND|egrep|sort)$')" -- "$2" ))
}
_ka() { :
	_psgrep "$@" -u "$USER"
}
complete -F _ka ka
complete -F _psgrep psgrep ok
# }}}

alias ?='echo $?'
alias p='pwd'
alias x='xargs -r'
alias e='egrep --color=always'
alias g='egrep'
alias gv='egrep -v'
alias ch='chmod'
alias hist='history | sort -nr | less'
alias histop='history | awk "{print \$2}" | sort | uniq -c | sort -nr | head -n'

function path
{
	local var=PATH
	[ "$1" ] && var="$1"
	eval "expr \"\$$var\"" | tr ':' $'\n'
}
complete -A variable path

function typef
{
	local -i code=0
	while [ $# -gt 0 ]; do
		readlink -e "$(type -p "$1")" || code+=1
		shift
	done
	return $code
}
complete -c typef

# file browser/terminal {{{
function f
{ :
	local fileman
	for fileman in Thunar "nautilus --no-desktop"; do
		if type "${fileman%% *}" &>/dev/null; then
			[ $# -eq 0 ] && set "$PWD"
			($GUI $fileman "$@")
			return
		fi
	done
	return 1
}
complete -A directory t
# }}}
# help {{{
function h
{ :
	local -i code=0 error
	local arg section output
	for arg in "$@"; do
		if [[ "$arg" == [0-9ln] ]]; then
			section="$arg" && continue
		fi
		error=0
		man $section "$arg" 2>/dev/null
		if [ $? -eq 0 ]; then
			:
		elif ! type "$arg" &>/dev/null; then
			error=1
		else
			output=$("$arg" -? 2>&1)
			if [ $? -eq 0 -a -n "$output" ]
			then echo "$output"
			else
				output=$("$arg" --help 2>&1)
				if [ $? -eq 0 -a -n "$output" ]
				then echo "$output"
				else error=1
				fi
			fi
		fi
		if (( $error )); then
			echo >&2 "No help for $arg${section:+($section)}"
			code+=1
		fi
		unset section
	done
	return $code
}
# eval $(complete -p man 2>/dev/null | sed 's/man$/h/')
# }}}
# alias help {{{
function ahelp
{ :
	[ $# -eq 0 ] && set -- ""
	local arg list width
	for arg in "$@"; do
		list+=$(alias | egrep -e "$arg" | grep -v "ahelp")$'\n'
	done
	list=$(echo "${list%$'\n'}" | sort -u)
	[ -z "$list" ] && return 1
	width=$(echo "$list" | awk -F'[ =]' '{print $2}' | wc -L)
	echo "$list" | awk '{
		sub(/^alias/, ""); sub(/=./, " "); sub(/.$/, "");
		if ($1 != "") {
			printf "%-'$((width + 2))'s", $1; $1 = ""; print;
		}
	}'
}
# }}}
## }}}
## the rest {{{
alias cat4='expand -t4'
alias db='diff -bB'
alias df='df -h'
alias dr='diff -qr'
alias free='free -m'
alias pl='perl -de 47'
alias py3='python3'
alias py='python'
alias wcL='wc -L'
alias wcl='wc -l'

# calculators {{{
_float() { :
	sed -e 's/\.0\+$//' -e 's/\(\.[0-9]*[1-9]\)0\+$/\1/'
}
function calc
{ :
	local constants='
	pi = 3.14159265358979323846
	e  = 2.71828182845904523536
	'
	echo "$constants; $*" | bc -l | _float
	return ${PIPESTATUS[1]}
}
function rpn
{ :
	dc -e "20 k $* p" | _float
	return ${PIPESTATUS[0]}
}
# }}}
# variables {{{
function var
{ :
	[ $# -eq 0 ] && return 1
	local varname decl value
	for varname in "$@"; do
		decl=$(declare -p "$varname" 2>/dev/null)
		if [ $? -ne 0 ]; then
			echo -n "$varname is "
			echo -e "\e[31;1mnot set\e[0m"
		elif [[ "$decl" =~ ^'declare -'([^[:blank:]]+)' '[[:alnum:]_]+=(.*)$ ]]
		then
			decl="${BASH_REMATCH[1]}" && value="${BASH_REMATCH[2]}"
			echo -n "$varname"
			[[ "$decl" =~ [Aa] ]] && varname+="[@]"
			decl=$( echo "$decl|$(eval "expr \"\${#$varname}\"")" |
					sed -e 's/^-|//' -e 's/\(^\||\)0$//' )
			echo -en "${decl:+\e[30;1m[$decl]\e[0m} is "
			if [ "$value" = '""' ]
			then echo -e "\e[34;1mset and null\e[0m"
			else echo "$value" | perl -pe "s|^'\(\s*|(|; s|\s*\)'$|)|"
			fi
		else
			return 3
		fi
	done
}
complete -A variable var
# }}}
# web {{{
_search() { :
	uzbl "$1$(echo "${@:2}" | sed 's/[[:space:]]\+/+/g')"
}
alias goog='_search "http://google.com/search?q="'
alias wiki='_search "http://en.wikipedia.org/wiki/Special:Search?search="'
# }}}
# vim {{{
function vd { ($GUI gvimdiff "$@") }
function vp { ($GUI gvim -p  "$@") }

# open in a new tab in existing gvim server {{{
function vs
{ : :
	if pat_in "$HELP_PAT" "$@"; then
		echo "Usage: vs [server] [vim_option|file]..." && return
	fi
	split_opts 'tq?cSd?ir?s?TuUwW' \
		cmd remote-expr remote-send servername socketid -- "$@" || return $?
	set -- "${ARGV[@]}"
	local server=()
	if [ "$1" -a ! -f "$1" ] || str_in "$1" $(gvim --serverlist); then
		server=(--servername "$1") && shift
	else
		server=($(gvim --serverlist))
		if [ ${#server[@]} -gt 0 ]
		then server=(--servername "${server[0]%%[0-9]*}")
		else server=()
		fi
	fi
	if [ $# -eq 0 ]
	then ($GUI gvim "${server[@]}" "${OPTS[@]}")
	else ($GUI gvim "${server[@]}" "${OPTS[@]}" --remote-tab-silent "$@")
	fi
	split_opts -c
} # }}}
_vs() { :
	if [ $COMP_CWORD -eq 1 ]; then
		COMPREPLY=($(compgen -W "$(gvim --serverlist)" -- "$2"))
	fi
}
complete -F _vs -o filenames -o default vs

alias dev='vs DEV'
alias lib='vs LIB -R'
_devlib() { :
	local cur="$2"
	file_glob "@($CODE_PAT|$MAKE_PAT|$TEXT_PAT)"
}
complete -F _devlib -o filenames -o default dev lib

# edit code {{{
function vc
{ : :
	[ "$1" = "--cd" ] && local cd="$1" && shift
	if [ $# -eq 0 ] || pat_in "$HELP_PAT" "$@"; then
		echo "Usage: vc [-s] [vim_option|server|filename]..." && return
	fi
	local IFS=$'\n' sudo vopts=() vargs=() arg paths path files=() server=CODE
	split_opts 'tq?cSd?ir?TuUwW' \
		cmd remote-expr remote-send servername socketid -- "$@" || return $?
	set -- "${ARGV[@]}"
	for arg in "${OPTS[@]}"; do
		if [ "$arg" = "-s" ]; then
			sudo=sudo
			paths="$PATH:"
			continue
		fi
		vopts+=("$arg")
	done
	split_opts -c
	[ "$CODE_PATH" ] && paths+="$CODE_PATH"
	paths=($(echo "$paths" | tr ':' "$IFS"))
	for arg in "$@"; do
		arg="${arg%/}"
		files=($(which "$arg" 2>/dev/null))
		for path in "${paths[@]}"; do
			files+=($(ls -d $path/$arg 2>/dev/null))
		done
		if [ "${#files[@]}" -eq 0 ]; then
			server="$arg" && continue
		fi
		for arg in "${files[@]}"; do
			arg=$(readlink -f -- "$arg")
			path="$(file -b "$arg" 2>/dev/null)"
			if [[ "$path" == *text* || "$path" == empty ]] &&
				! str_in "$arg" "${vargs[@]}"
			then
				vargs+=("$arg")
			fi
		done
	done
	[ "$cd" ] && cd "$(dirname -- "${vargs[0]}")"
	[ -z "$sudo" ] && sudo=$GUI
	[ ${#vargs[@]} -gt 0 ] &&
	(cd "$(dirname -- "${vargs[0]}")" && $sudo gvim --servername "$server" \
	 "${vopts[@]}" --remote-tab-silent "${vargs[@]}")
}
alias vcc='vc --cd'
# }}}
_vc() { : :
	[ ! -d "$BIN" ] && return 1
	local IFS=$'\n' path replies=() cur="$2" i
	if [ "$COMP_TYPE" -ne 63 ]; then
		for path in "$BIN" $(echo "$CODE_PATH" | tr ':' "$IFS"); do
			replies=($(compgen -f -- "$path/$cur"))
			for i in "${!replies[@]}"; do
				[ -d "${replies[$i]}" -a ! -d "${replies[$i]#$path/}" ] &&
					replies[$i]+='/'
			done
			COMPREPLY+=("${replies[@]#$path/}")
		done
	fi
	if [ ${#COMPREPLY[@]} -eq 0 ]; then
		COMPREPLY=($(compgen -W "$(gvim --serverlist)" -- "$cur"))
	fi
}
complete -F _vc -o nospace -o filenames vc vcc
# }}}
# ssh {{{
SSH_ENV="$HOME/.ssh/environment"

function start-ssh-agent
{
	/usr/bin/ssh-agent | sed 's/^echo/#echo/' >"$SSH_ENV"
	chmod 600 "$SSH_ENV"
	source "$SSH_ENV" >/dev/null
	/usr/bin/ssh-add
}
# }}}
# git {{{
type __gitdir &>/dev/null &&
function gs
{ :
	local IFS=$'\n' WD="$PWD" OWD dir gitdir sep=-n remote
	split_opts -- "$@" || return $?
	if pat_in '^--?([a-z]+)$' "${OPTS[@]}"; then
		remote="${BASH_REMATCH[0]##*-}"
	fi
	set -- "${ARGV[@]}"
	split_opts -c
	[ "${OLDPWD+set}" ] && OWD="$OLDPWD"
	[ $# -eq 0 ] && set -- .
	for dir in "$@"; do
		cd "$WD"
		cd "$dir" || continue
		gitdir=$( (cd "$(__gitdir)" && pwd) 2>/dev/null)
		[ ! "$gitdir" -o "$gitdir" = "$PWD" ] && continue
		echo $sep && unset sep
		echo "${PWD#$(dirname "$(dirname "$gitdir")")/}" | grep '^[^/]*'
		git status 2>/dev/null | grep '^#' \
		| GREP_COLORS='ms=35' grep -P '(?<=^# On branch )\w+|'
		if [ "$remote" ] && git remote | grep "^$remote$" >/dev/null; then
			[ -f "$SSH_ENV" ] && source "$SSH_ENV" >/dev/null
			ps -ef	| grep "$SSH_AGENT_PID" \
					| grep 'ssh-agent$' >/dev/null || start-ssh-agent
			git push "$remote" HEAD 2>&1 | grep -v '^Everything up-to-date$'
		fi
	done
	[ "${OWD+set}" ] && cd "$OWD"
	cd "$WD"
}
# }}}
# gpg {{{
function encrypt
{ :
	[ $# -eq 0 ] && return 2
	local -i code=0
	local arg tmp
	tmp=$(mktemp) || return $?
	for arg in "$@"; do
		if [ -f "$arg" -a -r "$arg" -a -w "$arg" ]; then
			echo "$arg"
			cat "$arg" | gpg -ac --no-options >"$tmp"
			if [ "$(max "${PIPESTATUS[@]}")" -eq 0 ]; then
				shred -uzn 8 "$arg" && mv "$tmp" "$arg.pgp" && chmod 600 "$arg.pgp"
			else
				false
			fi
		else
			! echo >&2 "encrypt: can't open \`$arg'"
		fi
		code+=$?
	done
	rm -f "$tmp"
	return $code
}
function decrypt
{ :
	local -i code=0
	local arg
	for arg in "$@"; do
		if [ -f "$arg" -a -r "$arg" ]; then
			cat "$arg" | gpg -d --no-options 2>/dev/null
		else
			echo >&2 "decrypt: can't open \`$arg'"
			false
		fi
		code+=$(max "${PIPESTATUS[@]}")
	done
	return $code
}
# }}}
# samba {{{
function smbmount
{ :
	[ $# -lt 2 ] && return 2
	local -i code=0
	local arg SERVER="$1" && shift
	[ -z "$SERVER" ] && return 2
	for arg in "$@"; do
		local MNT="$HOME/$SERVER.$arg"
		mkdir -p "$MNT" &&
		mount.cifs "//$SERVER/$arg" "$MNT" -o iocharset=utf8,password= &&
		cd "$MNT"
		if [ $? -ne 0 ]; then
			rmdir "$MNT" 2>/dev/null
			code+=1
		fi
	done
	return $code
}
function smbumount
{ :
	[ $# -ne 1 ] && return 2
	local IFS=$'\n' SERVER="$1" && shift
	local MNT="$HOME/$SERVER.*"
	[ -z "$SERVER" ] && return 2
	if ls -d $MNT &>/dev/null; then
		umount.cifs $MNT
		if [ $? -eq 0 ]
		then rmdir $MNT
		else rmdir $MNT 2>/dev/null
		fi
	fi
}
# }}}
## }}}
# vim:set ts=4 sw=4 noet fdm=marker: