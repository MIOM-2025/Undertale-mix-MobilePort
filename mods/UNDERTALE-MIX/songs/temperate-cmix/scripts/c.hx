var b1:FlxSprite = new FlxSprite().makeGraphic(FlxG.width / 2, FlxG.height, FlxColor.BLACK);
var b2:FlxSprite = new FlxSprite().makeGraphic(FlxG.width / 2, FlxG.height, FlxColor.BLACK);
function create() {	
	b1.screenCenter(FlxAxes.Y);
	b1.cameras = [camHUD];
	add(b1);
	
	b2.screenCenter(FlxAxes.Y);
	b2.setPosition(b1.width);
	b2.cameras = [camHUD];
	add(b2);
}

function onSongStart() {
	FlxTween.tween(b1, {x: -b1.width}, 1);
	FlxTween.tween(b2, {x: b2.x + b2.width}, 1);
}

function closeUp() {
	FlxTween.tween(b1, {x: 0}, 1, {ease: FlxEase.expoIn});
	FlxTween.tween(b2, {x: b1.width}, 1, {ease: FlxEase.expoIn});
}