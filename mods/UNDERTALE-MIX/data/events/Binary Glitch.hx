import Reflect;
import flixel.math.FlxRandom;

var r:FlxRandom = new FlxRandom();
function onEvent(event) {
	if (event.event.name == 'Binary Glitch') {
		var params = event.event.params;
		var shader = new CustomShader('binaryGlitch');
		var objects = [];
		if (params[3] != '') {
			objects.push(PlayState.instance.stage.stageSprites[params[3]]);
		} else {
			for (char in strumLines.members[params[0]].characters) {
				objects.push(char);
			}
		}
		shader.size = r.float(10, 20);
		if (params[2]) {
			for (thing in objects) {
				// trace('disabled');
				thing.shader = null;
			}
			return;
		} else if (!params[2]) {
			for (thing in objects) {
				if (thing.shader == null) {
					thing.shader = shader;
				}
			}
		}
	}
}