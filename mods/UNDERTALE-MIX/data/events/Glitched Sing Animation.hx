import flixel.math.FlxRandom;
import flixel.math.FlxMath;
import Reflect;

var animList:Map<String, Array<String>> = [];
var r:FlxRandom = new FlxRandom();
var limit:Int = 1;
var timer:FlxTimer;
function onEvent(e) {
	if (e.event.name == 'Glitched Sing Animation' && FlxMath.inBounds(e.event.time / 1000, (Conductor.songPosition / 1000) - 2, (Conductor.songPosition / 1000) + 2)) {
		var prop = {
			strum: e.event.params[0],
			anim: e.event.params[1],
		}
		if (timer != null) {
			timer.cancel();
		}
		var animations:Array<String> = [];
		var character:Character = strumLines.members[prop.strum].characters[0];
		if (Options.gameplayShaders) {
			if (character.shader != null) {
				character.shader.glitchIntensity = FlxG.random.float(0.1, limit);
			} else {
				character.shader = new CustomShader('glitch02');
				character.shader.glitchIntensity = FlxG.random.float(0.1, limit);
			}
		}
		if (animList.get(character.curCharacter) == null) {
			var list:Array<String> = [];
			for (k => v in character.animDatas) {
				list.push(k);
			}
			animList.set(character.curCharacter, list);
		} else {
			animations = animList.get(character.curCharacter);
		}
		character.playAnim((prop.anim == '' ? animations[r.int(0, animations.length - 1)] : prop.anim), true);
		if (Options.gameplayShaders) {
			FlxTween.tween(character, {x: character.x}, Conductor.crochet / 1000, {onComplete: function() {
				character.shader = null;
			}});
		}
	}
}