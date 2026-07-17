import flixel.FlxObject;

var glitch:CustomShader;
function create() {
	if (Options.gameplayShaders) {
		glitch = new CustomShader('glitch02');
	}
}

var glitchSlider:FlxObject = new FlxObject();
var tween:FlxTween;
var updateGlitchShader:Bool = true;
var addedShader:Bool = false;
function update(elapsed:Float) {
	if (updateGlitchShader) {
		glitch.glitchIntensity = glitchSlider.x;
	}
}

function onEvent(e) {
	if (e.event.name == 'Glitch Shader' && FlxMath.inBounds(e.event.time / 1000, (Conductor.songPosition / 1000) - 2, (Conductor.songPosition / 1000) + 2)) {
		if (!Options.gameplayShaders) {
			return;
		}
	
		if (!addedShader) {
			FlxG.game.addShader(glitch);
			addedShader = true;
		}
		var eventData = {
			tween: e.event.params[0],
			tweenTime: e.event.params[1],
			removeTween: e.event.params[2],
			intensity: e.event.params[3],
			disable: e.event.params[4],
		};
		if (eventData.tween) {
			if (tween != null) {
				tween.cancel();
			}
			tween = FlxTween.tween(glitchSlider, {x: eventData.intensity}, eventData.tweenTime, {ease: FlxEase.cubeInOut, onComplete: function() {
				if (eventData.removeTween) {
					FlxG.game.removeShader(glitch);
					addedShader = false;
				}
			}});
		} else {
			glitchSlider.x = eventData.intensity;
			if (eventData.disable) {
				FlxG.game.removeShader(glitch);
				addedShader = false;
			}
		}
	}
}

function destroy() {
	FlxG.game.removeShader(glitch);
}