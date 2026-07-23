import flixel.FlxCamera.FlxCameraFollowStyle;
import funkin.backend.system.Flags;

var forcing = false;
var forcedOnce = false;
var forcedPosition = [0, 0];
function onEvent(event) {
	if (event.event.name == 'Really Force Camera Position') {
		var tween = PlayState.instance.eventsTween['cameraMovement'];
		trace(tween);
		var params = event.event.params;
		if (params[2]) {
			forcedPosition = [params[0], params[1]];
		}
		forcedOnce = false;
		if (forcing) {
			forcing = false;
		} else {
			forcing = true;
		}
		if (!forcing) {
			// trace('a');
			FlxG.camera.follow(camFollow, FlxCameraFollowStyle.LOCKON, Flags.DEFAULT_CAMERA_FOLLOW_SPEED);
		}
		trace('Forcing?: ' + forcing);
	}
}

function postUpdate() {
	if (forcing && !forcedOnce) {
		// camFollow.setPosition(forcedPosition[0], forcedPosition[1]);
		FlxG.camera.follow(camFollow, FlxCameraFollowStyle.LOCKON, 999999999999);
		forcedOnce = true;
	}
}