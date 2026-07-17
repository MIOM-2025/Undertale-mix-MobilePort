// function preCreate() {
	// if (FlxG.save.data.disableHudScript == false) {
		// importScript('data/scripts/newHud');
	// }
// }
// var 
var comboCamera:FlxCamera = new FlxCamera();
// function postCreate() {
	// defaultDisplayRating = false;
	// minDigitDisplay = -1;
	// FlxG.cameras.add(comboCamera, false);
	// comboCamera.bgColor = FlxColor.TRANSPARENT;
	// comboGroup.cameras = [camHUD];
// }

// function onPlayerHit(e) {
    // e.note.splash = 'utsplash';
// }

function postCreate() {
	// FlxG.cameras.add(comboCamera, false);
	// comboCamera.bgColor = FlxColor.TRANSPARENT;
	// comboGroup.cameras = [comboCamera];
	// comboGroup.screenCenter();

	for (strumLine in strumLines.members) {
	if (FlxG.save.data.haveBotPlay) {
		strumLine.cpu = true;
	}
	
		for (strum in strumLine) {
			strum.antialiasing = false;
		}
		for (note in strumLine.notes) {
			note.antialiasing = false;
			note.splash = 'utsplash';
		}
	}
}