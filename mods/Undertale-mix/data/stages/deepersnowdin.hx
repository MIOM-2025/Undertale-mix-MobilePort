import flixel.math.FlxRandom;
import SnowParticle;

var r:FlxRandom = new FlxRandom();
function postCreate() {
	// camGame.pixelPerfectRender = true;
	// camGame.pixelPerfectShake = true;
	if (FlxG.save.data.particlesEnabled == null) {
		FlxG.save.data.particlesEnabled = true;
	}
	if (FlxG.save.data.particlesEnabled) {
		new FlxTimer().start(0.1, function() {
			var snow:SnowParticle = new SnowParticle(r.int(200, 700), -300);
			snow.scrollFactor.set(1 - (snow.scale.x / 2), 1);
			add(snow);
		}, 60);
	}
	
	if (FlxG.save.data.haveBotPlay) {
		camHUD.visible = false;
	}
}

//Hscript call stuff.
function transformationShake() {
	FlxG.camera.shake(0.002, 3);
}

function hideTheCamera() {
	camGame.visible = false;
}

function fadeCamera() {
	FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
}