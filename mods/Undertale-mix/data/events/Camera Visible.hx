function onEvent(e) {
	if (e.event.name == 'Camera Visible') {
		prop = {
			cam: e.event.params[0]
		}
		var camera = [
			'camGame' => camGame,
			'camHUD' => camHUD
		];
		var cam:FlxCamera = camera.get(prop.cam);
		cam.visible = !cam.visible;
	}
}