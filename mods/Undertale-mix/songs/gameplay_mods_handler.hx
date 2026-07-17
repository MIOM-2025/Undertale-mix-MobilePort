import funkin.savedata.FunkinSave;

var userScrollSpeed:Float = 1;
var scrollType:String = 'multiplicative';

var healthLossMult:Float = 1;
var healthGainMult:Float = 1;

var missInstaKill:Bool = false;
var songExists:Bool = false;
function create() {
	if (FlxG.save.data.gameHealthLossMult != null) {
		healthLossMult = FlxG.save.data.gameHealthLossMult;
	}
	if (FlxG.save.data.gameHealthGainMult != null) {
		healthGainMult = FlxG.save.data.gameHealthGainMult;
	}
	if (FlxG.save.data.gameScrollSpeed != null) {
		userScrollSpeed = FlxG.save.data.gameScrollSpeed;
	}
	if (FlxG.save.data.gameScrollType != null) {
		scrollType = FlxG.save.data.gameScrollType;
	}
	if (FlxG.save.data.missInstaKill != null) {
		missInstaKill = FlxG.save.data.missInstaKill;
	}
	
	songExists = FunkinSave.getSongHighscore(PlayState.SONG.meta.name, 'normal').date != null;
	if (!songExists) {
		healthLossMult = healthGainMult = 1;
		missInstaKill = false;
	}
}

function postCreate() {
	if (!songExists) {
		return;
	}

	if (scrollType == 'multiplicative') {
		scrollSpeed *= userScrollSpeed;
	} else {
		scrollSpeed = userScrollSpeed;
	}
	// trace(scrollType);
}

function onPlayerHit(e) {
	e.healthGain *= healthGainMult;
}

function onEvent(e) {
	if (e.event.name == 'Scroll Speed Change' && scrollType == 'constant' && songExists) {
		e.cancel();
		if (eventsTween.get('scrollSpeedTween') != null) {
			eventsTween.get('scrollSpeedTween').cancel();
		}
		scrollSpeed = userScrollSpeed;
	}
}

function onPlayerMiss(e) {
	if (missInstaKill) {
		health = PlayState.opponentMode ? 2 : 0;
	}
	e.healthGain *= healthLossMult;
}