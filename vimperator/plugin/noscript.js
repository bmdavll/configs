// Vimperator integration plugin for noscript
// @author	Martin Stubenschrott
// @version	0.2

mappings.addUserMap([modes.NORMAL], ["<leader>s"],
	"Toggle scripts temporarily on current web page",
	function() {
		noscriptOverlay.toggleCurrentPage(3);
	});

mappings.addUserMap([modes.NORMAL], ["<leader>S"],
	"Toggle scripts permanently on current web page",
	function() {
		const ns = noscriptOverlay.ns;
		const url = ns.getQuickSite(content.document.documentURI, 3);
		noscriptOverlay.safeAllow(url, !ns.isJSEnabled(url), false);
	});

commands.addUserCommand(["nosc[ript]"],
	"Show noscript info",
	function() {
		liberator.echo(util.objectToString(noscriptOverlay.getSites(), true));
	});
