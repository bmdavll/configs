/**
 * minion.js
 *
 * Minion is an mpd client which runs as a Firefox extension.
 *
 * @author David Liang (bmdavll@gmail.com)
 * @author Yoann Lamouroux (spamonsophia@gmail.com)
 * @version 0.2
 *
 **/
var INFO =
<plugin name="minion" version="0.2"
		href="https://addons.mozilla.org/en-US/firefox/addon/6324/"
		summary="MPD client"
		xmlns="http://vimperator.org/namespaces/liberator">
	<author email="bmdavll@gmail.com">David Liang</author>
	<author email="spamonsophia@gmail.com">Yoann Lamouroux</author>
	<license href="http://www.opensource.org/licenses/mit-license.html">MIT</license>
	<project name="Vimperator" minVersion="2.0" />
	<p>
		This plugin allows you to control the Minion mpd client from the
		Vimperator interface.
	</p>
	<item>
		<tags>:mp :mpd mpd-action</tags>
		<spec>:mp[d] <oa>action</oa></spec>
		<description><p>
			Issue a command to mpd. Actions can be one of: prev, next, play, pause, stop.
			Open the Minion interface in a new tab.
		</p></description>
	</item>
</plugin>;


var notify = true;

function MPVimperator() {

	var mpd = nsMPM.mpd;

	var _callbacks = {};
	var _ticket = 0;
	var _relative_cmds = [];
		_relative_cmds.limit = 7;

	var _notify_timeout = 2000;
	var _last_notify = null;

	function mpdCmd(command, callback) {
		mpd.doCmd(command);
		if (callback)
			_callbacks[_ticket] = callback;
		checkResponse(_ticket++);
	}
	function mpdRelativeCmd(cmd) {
		if (cmd) {
			if (_relative_cmds.length < _relative_cmds.limit)
				_relative_cmds.push(cmd);
			else
				return;
		}
		if (!mpd._idle) {
			setTimeout(mpdRelativeCmd, 150, null);
		} else if (_relative_cmds.length > 0) {
			var cmd = _relative_cmds.shift();
			var command = cmd['command'];
			var arg = parseInt(mpd[cmd['base']]) + cmd['offset'];
			mpd.doCmd(command+' '+arg);
			_callbacks[_ticket] = cmd['callback'] || null;
			checkResponse(_ticket++);
		}
	}
	function checkResponse(ticket) {
		if (!mpd._idle) {
			setTimeout(checkResponse, 75, ticket);
		} else {
			if (mpd.lastResponse != 'OK')
				liberator.echoerr(mpd.lastResponse);
			else if (_callbacks[ticket])
				_callbacks[ticket]();
			delete _callbacks[ticket];
		}
	}

	function autoNotify(init) {
		if (!notify) {
			_last_notify = null;
			return;
		}
		if (mpd.song) {
			if (mpd.file != _last_notify) {
				_last_notify = mpd.file;
				if (!init)
					echoInfo();
			}
		} else _last_notify = null;
		setTimeout(autoNotify, _notify_timeout, false);
	}

	function getSongInfo(id) {
		var song;
		if (id == mpd.song)
			song = mpd.currentsong;
		else
			song = mpd.plinfo[id];
		if (!song)
			return '';

		var sep = ' \u00b7 ';
		var title = song.Title;
		if (!title)
			return '';

		var artist = song.Artist;
		if (artist)
			artist = sep+'by '+artist;
		else
			artist = '';

		var album = song.Album;
		if (album) {
			var track = song.Track;
			album = (track ? sep+track : '')+sep+'from '+album;
		} else
			album = '';

		var date = song.Date;
		if (date)
			date = ' ('+date+')';
		else
			date = '';

		return title + artist + album + date;
	}

	function prettyTime(sec) {
		return Math.floor(sec/60) + ':' + ('0'+sec%60).substr(-2);
	}

	function echoInfo() {
		var songinfo = getSongInfo(mpd.song);
		if (!songinfo) {
			liberator.echoerr("Unable to get song info");
			return false;
		}
		var state = {
			play : '\u25b6',
			pause: '\u25b7',
			stop : '\u25fc',
		}[mpd.state];

		state += ' '+prettyTime(mpd.time)+'/'+prettyTime(mpd.Time);
		if (mpd.state != 'stop')
			state += ' @'+mpd.bitrate+'kb/s';

		var liststate = parseInt(mpd.song)+1+' of '+mpd.playlistlength;
		var shuffle = parseInt(mpd.random);
		var repeat  = parseInt(mpd.repeat);
		if (shuffle || repeat) {
			liststate += ' ';
			if (shuffle) liststate += '[?]';
			if (repeat)  liststate += '[&]';
		}

		var sep = ' | ';
		echo(songinfo + sep + state + sep + liststate);
		return true;
	}

	function echoVolume() {
		echo("Volume: "+mpd.volume+"%");
	}

	function echo(str) {
		commandline.echo(
			str,
			null,
			commandline.DISALLOW_MULTILINE
		);
	}

	function getSign(str) {
		if (str.charAt(0) == '+')
			return 1;
		else if (str.charAt(0) == '-')
			return -1;
		else
			return 0;
	}

	return {

		info: echoInfo,

		notify: function(args, bang) {
			var state = notify;
			if (args == null) {
				notify = true;
				autoNotify(true);
				return;
			} else if (args.length == 0) {
				if (bang)
					notify = !notify;
			} else if (/^\d+$/.test(args[0])) {
				var arg = parseInt(args[0], 10);
				notify = !!arg;
				if (arg >= 1000)
					_notify_timeout = arg;
			} else switch (args[0]) {
				case 'on':
					notify = true;
					break;
				case 'off':
					notify = false;
					break;
				default:
			}
			if (notify && !state)
				autoNotify(true);
			echo("Notify: "+(notify ? "on" : "off"));
		},

		prev: function() {
			mpdCmd('previous', echoInfo)
		},
		next: function() {
			mpdCmd('next', echoInfo)
		},
		pause: function(args, bang) {
			if (mpd.state == 'stop' && bang)
				mpdCmd('play', echoInfo)
			else
				mpdCmd('pause', echoInfo)
		},
		stop: function() {
			mpdCmd('stop', echoInfo)
		},
		update: function() {
			mpdCmd('update', function() {
				echo("Update OK")
			})
		},

		play: function(args) {
			if (args.length == 0)
				mpdCmd('play', echoInfo)
			else
				mpdCmd('play '+(args[0]-1), echoInfo)
		},

		shuffle: function(args, bang) {
			var state = mpd.random;
			if (args.length == 0) {
				if (bang)
					state = (state==0 ? 1 : 0);
			} else switch (args[0]) {
				case 'on':
				case '1':
					state = 1;
					break;
				case 'off':
				case '0':
					state = 0;
					break;
				default:
			}
			mpdCmd('random '+state, function() {
				echo("Shuffle: "+(parseInt(mpd.random) ? "on" : "off"));
			});
		},
		repeat: function(args, bang) {
			var state = mpd.repeat;
			if (args.length == 0) {
				if (bang)
					state = (state==0 ? 1 : 0);
			} else switch (args[0]) {
				case 'on':
				case '1':
					state = 1;
					break;
				case 'off':
				case '0':
					state = 0;
					break;
				default:
			}
			mpdCmd('repeat '+state, function() {
				echo("Repeat: "+(parseInt(mpd.repeat) ? "on" : "off"));
			});
		},

		seek: function(args) {
			if (args.length == 0)
				liberator.echoerr("Argument required");
			var arg = args[0];
			var sign = getSign(arg);
			if (sign)
				arg = arg.substr(1);

			if (/^\d*:\d\d$/.test(arg)) {
				var time = arg.split(':');
				var min = parseInt(time[0], 10);
				sec = (isNaN(min) ? 0 : min*60) + parseInt(time[1], 10);
			} else if (/^\d+$/.test(arg)) {
				sec = parseInt(arg, 10);
			} else {
				return liberator.echoerr("Invalid argument: "+arg[0]);
			}

			if (!sign) {
				mpdCmd('seek '+mpd.song+' '+sec, echoInfo);
			} else {
				sec *= sign;
				mpdRelativeCmd({
					command: 'seek '+mpd.song,
					base: 'time',
					offset: sec,
					callback: echoInfo
				});
			}
		},

		vol: function(args) {
			if (args.length == 0)
				return echoVolume();
			var arg = args[0];
			var sign = getSign(arg);
			if (sign)
				arg = arg.substr(1);

			if (/^\d+$/.test(arg)) {
				if (!sign) {
					mpdCmd('setvol '+arg, echoVolume);
				} else {
					arg = sign * parseInt(arg, 10);
					mpdRelativeCmd({
						command: 'setvol',
						base: 'volume',
						offset: arg,
						callback: echoVolume
					});
				}
			} else {
				liberator.echoerr("Invalid argument: "+arg[0]);
			}
		},

		_cmd: function(args) {
			mpdCmd(args.join(' '), function() {
				liberator.echomsg(mpd.lastResponse)
			})
		},

		_execute: function(args) {
			if (args.length == 0)
				return openUILinkIn('chrome://minion/content/minion.xul', 'tab');
			var name = args.shift();
			var bang = false;
			if (name.substr(-1) == '!') {
				bang = true;
				name = name.slice(0, -1);
			}
			var func = mpv[name];
			if (func) {
				return func(args, bang);
			} else {
				liberator.echoerr("Unsupported mpd command: "+name);
				return false;
			}
		},

		_completer: function(context) {
			var commands = [];
			for (var name in mpv) {
				if (name.indexOf('_') !== 0 && mpv.hasOwnProperty(name))
					commands.push(name);
			}
			commands.sort(function(a, b) {return a.length - b.length});
			for (var i = 0; i < commands.length; ++i) {
				for (var j = i+1; j < commands.length; ++j) {
					if (commands[j].indexOf(commands[i]) == 0) {
						commands[i] = null;
						break;
					}
				}
			}
			commands = commands.filter(function(item) {return item != null});
			commands.sort();
			context.completions = [[c, ''] for each (c in commands)];
		}

	};
}


var mpv = MPVimperator();

var abbreviations = {
	pr		: 'prev',
	pre		: 'prev',
	n		: 'next',
	ne		: 'next',
	nex		: 'next',
	pl		: 'play',
	pla		: 'play',
	p		: 'pause',
	pa		: 'pause',
	pau		: 'pause',
	paus	: 'pause',
	st		: 'stop',
	sto		: 'stop',
	se		: 'seek',
	see		: 'seek',
	sh		: 'shuffle',
	shu		: 'shuffle',
	shuf	: 'shuffle',
	shuff	: 'shuffle',
	shuffl	: 'shuffle',
	re		: 'repeat',
	rep		: 'repeat',
	repe	: 'repeat',
	repea	: 'repeat',
	u		: 'update',
	up		: 'update',
	upd		: 'update',
	upda	: 'update',
	updat	: 'update',
	v		: 'vol',
	vo		: 'vol',
	i		: 'info',
	in		: 'info',
	inf		: 'info',
	no		: 'notify',
	not		: 'notify',
	noti	: 'notify',
	notif	: 'notify',
};
for (var ab in abbreviations) {
	mpv[ab] = mpv[abbreviations[ab]];
}

if (notify)
	mpv.notify();

// disable minion control buttons
document.getElementById('mpm_status-bar_controls')
		.setAttribute('collapsed', 'true');

commands.addUserCommand(
	['mp[d]'],
	"Control mpd from vimperator",
	function(args) {
		mpv._execute(args);
	},
	{ argCount: '*', completer: mpv._completer }
);

// vim:set ts=4 sw=4 noet:
