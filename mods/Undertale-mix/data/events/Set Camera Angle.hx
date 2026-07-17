function onEvent(e) {
	if (e.event.name == 'Set Camera Angle' && FlxMath.inBounds(e.event.time / 1000, (Conductor.songPosition / 1000) - 2, (Conductor.songPosition / 1000) + 2)) {
		var prop = {
			camera: e.event.params[0],
			tween: e.event.params[1],
			angle: e.event.params[2],
			steps: e.event.params[3],
			ease: e.event.params[4],
			type: e.event.params[5],
		}
		var camera = (prop.camera == 'camGame' ? camGame : camHUD);
		if (prop.tween) {
			FlxTween.tween(camera, {angle: prop.angle}, (Conductor.stepCrochet / 1000) * prop.steps, {ease: CoolUtil.flxeaseFromString(prop.ease, prop.type)});
		} else {
			camera.angle = prop.angle;
		}
	}
}