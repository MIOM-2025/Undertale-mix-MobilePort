var fader:FlxSprite;
function create() {
	fader = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	fader.alpha = 0;
	fader.cameras = [camHUD];
	insert(0, fader);
}

var faded = false;
function onEvent(event) {
	var name = event.event.name;
	if (name == 'Fade') {
		faded = !faded;
		FlxTween.tween(fader, {alpha: (faded ? 1 : 0)}, 0.3, {ease: FlxEase.expoOut});
		trace(faded);
	}
}