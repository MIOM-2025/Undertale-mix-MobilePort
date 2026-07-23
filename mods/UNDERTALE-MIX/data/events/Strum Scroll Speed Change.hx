import flixel.math.FlxRandom;

import Std;

// var r:FlxRandom = new FlxRandom();
function onEvent(e) {
	if (e.event.name == 'Strum Scroll Speed Change') {
		var prop = {
			strum: e.event.params[0],
			strums: e.event.params[1],
			speed: e.event.params[2],
			reset: e.event.params[3]
		}
		var strumLine = strumLines.members[prop.sturm];
		if (strumLine.opponentSide && PlayState.opponentMode) {
			return;
		} else if (!strumLine.opponentSide && (FlxG.save.data.gameScrollType != null && FlxG.save.data.gameScrollType == 'constant') || !FlxG.save.data.flashingLights) {
			return;
		}	
		var bound:Array<String> = ['0', Std.string(strumLine.members.length - 1)];
		if (prop.strums != '') {
			bound = prop.strums.split(',');
		}
		for (i in Std.parseInt(bound[0])...Std.parseInt(bound[1])) {
			if (prop.reset) {
				strumLine.members[i].scrollSpeed = PlayState.SONG.scrollSpeed;
				// trace('Reset strum speed.');
			} else {
				strumLine.members[i].scrollSpeed = (prop.speed != 0 ? prop.speed : FlxG.random.float(0, 10));
				// trace('Changed strum speed.');
			}
		}
	}
}