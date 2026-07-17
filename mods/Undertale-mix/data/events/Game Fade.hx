import flixel.math.FlxMath;
import funkin.editors.charter.Charter;

var fader:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
function postCreate() {
	fader.cameras = [camHUD];
	fader.alpha = 0;
	add(fader);
	if (PlayState.opponentMode) {
		remove(fader);
		insert(0, fader);
	}
}

function onEvent(e) {
	if (e.event.name == 'Game Fade' && FlxMath.inBounds(e.event.time / 1000, (Conductor.songPosition / 1000) - 2, (Conductor.songPosition / 1000) + 2)) {
		var prop = {
			steps: e.event.params[0],
			alpha: e.event.params[1]
		}
		if (prop.steps > 0) {
			FlxTween.tween(fader, {alpha: prop.alpha}, (Conductor.stepCrochet / 1000) * prop.steps);
		} else {
			if (Charter.startHere != null) {
				fader.alpha = prop.alpha;
			} 
		}
	}
}

function changeLayering(front:Bool) {
	remove(fader);
	insert(front ? 99999 : 0, fader);
}

function coolTransition() {
	fader.alpha = 0;
}