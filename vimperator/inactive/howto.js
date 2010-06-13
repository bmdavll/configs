// yank selected text to clipboard
mappings.addUserMap([modes.NORMAL], ["Y"],
	"Yank the currently selected text",
	function() {
		events.feedkeys("<C-v>" + (/^Mac/.test(navigator.platform) ? "<M-c>" : "<C-c>"), true);
		setTimeout( function() {
			liberator.echo("Yanked " + util.readFromClipboard(), commandline.FORCE_SINGLELINE);
		}, 20 );
	}
);

