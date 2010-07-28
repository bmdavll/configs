# user bin
if [ -d "$HOME/bin" ]; then
	PATH="$HOME/bin:$PATH"
fi

# if interactive
if [[ "$-" == *i* ]]; then

	# remap console keys
	if [ -z "$DISPLAY" -a -f "$HOME/.loadkeys" ]; then
		(loadkeys "$HOME/.loadkeys" || sudo loadkeys "$HOME/.loadkeys") &>/dev/null
	fi

	# bashrc
	if [ -r "$HOME/.bashrc" ]; then
		source "$HOME/.bashrc"
	fi

fi

