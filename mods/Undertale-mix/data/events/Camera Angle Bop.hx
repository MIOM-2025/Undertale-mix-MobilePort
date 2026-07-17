var tilted:Bool = false;
var interval:Int = 4;
var offset:Int = 0;
var strength:Int = 2;
var beatType:Int = 0;
function onEvent(e) {
	if (e.event.name == 'Camera Angle Bop') {
		var prop = {
			interval: e.event.params[0],
			offset: e.event.params[1],
			strength: e.event.params[2],
			type: e.event.params[3]
		}
		beatType = (prop.type == 'BEAT' ? 0 : 2);
		strength = prop.strength;
		interval = prop.interval;
		offset = prop.offset;
	}
}

var lastBeat:Int = 0;
var curBeat:Int = 0;
function update(beat:Int) {
	curBeat = Conductor.getBeats(beatType, interval, offset);
	if (lastBeat != curBeat) {
		for (c in [camGame, camHUD]) {
			c.angle = (tilted ? -strength : strength);
			FlxTween.tween(c, {angle: 0}, (beatType == 0 ? Conductor.crochet / 2 : Conductor.stepCrochet) / 1000);
		}
		lastBeat = curBeat;
		tilted = !tilted;
	}
}