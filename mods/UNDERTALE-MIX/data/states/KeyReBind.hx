import UndertaleText;

var stateCamera:FlxCamera = new FlxCamera();
function create() {
	FlxG.cameras.add(stateCamera, false);
	stateCamera.bgColor = FlxColor.TRANSPARENT;
	this.cameras = [stateCamera];
	stateCamera.zoom = 4;

	var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	bg.screenCenter();
	bg.alpha = 0.5;
	add(bg);
	
	
	var keyName:UndertaleText = new UndertaleText(0, 0, data.keyName.toUpperCase(), 'left', FlxG.width, 1, 'FFFFFF', 'undertale-outline');
	keyName.autoSize = true;
	keyName.screenCenter();
	keyName.y -= 14;
	add(keyName);
	
	var keyCategory:UndertaleText = new UndertaleText(0, keyName.y + keyName.height / 1.5, '(' + data.belongsTo.toUpperCase() + ')', 'left', FlxG.width, 1, 'FFFFFF', 'undertale-outline');
	keyCategory.autoSize = true;
	keyCategory.screenCenter(FlxAxes.X);
	add(keyCategory);
	
	var title:UndertaleText = new UndertaleText(0, keyCategory.y + keyCategory.height, 'Press any key to rebind.', 'left', FlxG.width, 1, 'FFFFFF', 'undertale-outline');
	title.autoSize = true;
	title.screenCenter(FlxAxes.X);
	// title.screenCenter();
	add(title);
	
}

var skipFrame:Bool = false;
function update() {
	if (!skipFrame) {
		skipFrame = true;
		return;
	}
	if (FlxG.keys.justPressed.ANY) {
		data.rebindKey(FlxG.keys.firstJustPressed());
		close();
	}// else if (controls.BACK) {
		// close();
	// }
}