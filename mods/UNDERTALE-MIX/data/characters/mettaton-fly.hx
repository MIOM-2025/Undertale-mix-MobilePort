import flixel.math.FlxRandom;

var r:FlxRandom = new FlxRandom();
var singing:Bool = false;
function onPlayAnim(e) {
	if (e.animName == 'singLEFT' || e.animName == 'singDOWN' || e.animName == 'singUP' || e.animName == 'singRIGHT') {
		if (!singing) {
			singing = true;
		}
	} else if (e.animName == 'idle') {
		if (singing) {
			singing = false;
			changeIdle();
		}
	}
}

function idleAnimChange(anim:String) {
	this.idleSuffix = '-' + anim;
}