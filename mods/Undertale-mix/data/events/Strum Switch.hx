var switched = false;
var basePlayerStrumPositions = [];
var baseCpuStrumPositions = [];
// var baseScale = 0;
function postCreate() {
	for (strumLine in strumLines) {
		for (strum in strumLine) {
			if (strumLine.opponentSide) {
				baseCpuStrumPositions.push(strum.x);
			} else {
				basePlayerStrumPositions.push(strum.x);
			}
		}
	}
	// camHUD.scale.x = 0.5;
}

var time = 0.6;
function onEvent(event) {
	var name = event.event.name;
	if (name == 'Strum Switch') {
		for (strumLine in strumLines) {
			for (strum in strumLine) {
				// baseScale = strum.scale.x;
				// FlxTween.tween(strum, {'scale.x': 0, alpha: (strumLine.opponentSide ? 0 : 1)}, time / 2, {ease: FlxEase.expoInOut, onComplete: function() {
					// FlxTween.tween(strum, {'scale.x': baseScale, alpha: (strumLine.opponentSide ? 1 : 1)}, time / 2, {ease: FlxEase.expoInOut});
				// }});
				if (strumLine.opponentSide) {
					var switchWith = (switched ? baseCpuStrumPositions : basePlayerStrumPositions);
					FlxTween.tween(strum, {x: switchWith[strum.ID]}, time, {ease: FlxEase.quadInOut});
					FlxTween.tween(strum, {alpha: 0.1}, time / 2, {ease: FlxEase.quadInOut, onComplete: function() {
						FlxTween.tween(strum, {alpha: 1}, time / 2, {ease: FlxEase.quadInOut});
					}});
					// for (note in strumLine.notes) {
						// FlxTween.tween(note, {alpha: 0.1}, time / 2, {ease: FlxEase.quadInOut, onComplete: function() {
							// FlxTween.tween(note, {alpha: 1}, time / 2, {ease: FlxEase.quadInOut});
						// }});
					// }
				} else {
					var switchWith = (switched ? basePlayerStrumPositions : baseCpuStrumPositions);
					FlxTween.tween(strum, {x: switchWith[strum.ID]}, time, {ease: FlxEase.quadInOut});
				}
			}
		}
		switched = !switched;
	}
}