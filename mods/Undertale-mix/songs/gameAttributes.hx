var pointer:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
var extra:FlxCamera = new FlxCamera();
var cor:FunkinText = new FunkinText(0, 0, FlxG.width, '[0, 0]', 26);
var title:FunkinText = new FunkinText(0, 100, FlxG.width, 'CAMERA POINTING AT:', 26);
var pointMode:Bool = false;
function create() {
	trace('\nPress CTRL + [P, L] to see specific values.');
	
	FlxG.cameras.add(extra, false);
	extra.bgColor = FlxColor.TRANSPARENT;
	
	title.alignment = 'center';
	title.cameras = [extra];
	add(title);
	
	cor.setPosition(title.x, title.y + title.height);
	cor.alignment = 'center';
	cor.cameras = [extra];
	add(cor);
	
	// if (FlxG.save.data.haveBotPlay) {
		extra.visible = false;
	// }
}

//878, 146

function postCreate() {
	// add(pointer);
}

function update() {
	if (FlxG.keys.pressed.CONTROL) {
		if (FlxG.keys.justPressed.P) {
			trace('\ncamGame.zoom: ' + camGame.zoom + '\ncamHUD.zoom: ' + camHUD.zoom + '\ndefaultCamZoom: ' + defaultCamZoom);
		} else if (FlxG.keys.justPressed.L) {
			trace('\nmeta.customValues: ' + PlayState.instance.SONG.meta.customValues);
		}
	}
	
	// if (FlxG.keys.justPressed.P) {
		// pointMode = !pointMode;
		// pointer.visible = pointMode;
		// title.visible = pointMode;
		// camGame.target = camFollow;
	// }
}

function postUpdate() {
	// camGame.zoom = 1;
	if (pointMode) {
		cor.text = '[' + pointer.x + ', ' + pointer.y + ']';
		camGame.target = pointer;
		if (FlxG.keys.pressed.I) {
			pointer.y -= 1;
		} else if (FlxG.keys.pressed.J) {
			pointer.x -= 1;
		} else if (FlxG.keys.pressed.K) {
			pointer.y += 1;
		} else if (FlxG.keys.pressed.L) {
			pointer.x += 1;
		}
	}
}