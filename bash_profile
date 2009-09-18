if [ -d "$HOME/bin" ]; then
	PATH="$HOME/bin:$PATH"
fi

if [ -r "$HOME/.bashrc" ]; then
	source "$HOME/.bashrc"
fi
