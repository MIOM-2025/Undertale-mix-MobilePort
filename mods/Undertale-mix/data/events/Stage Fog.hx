import flixel.addons.display.FlxBackdrop;

var fog:FlxBackdrop;
function create() {
	fog = new FlxBackdrop(Paths.image('fog'));
	fog.antialiasing = false;
	fog.alpha = 0;
	fog.velocity.set(5, 0);
	insert(members.indexOf(boyfriend), fog);
	
	fogOverlay = new FlxBackdrop(Paths.image('fog'));
	fogOverlay.antialiasing = false;
	fogOverlay.alpha = 0;
	fogOverlay.velocity.set(5, 0);
	insert(members.indexOf(dad) + 1, fogOverlay);
}

var duration:Int = 1;
var activated:Bool = false;
function onEvent(event) {
	if (event.event.name == 'Stage Fog') {
		activated = !activated;
		FlxTween.tween(fog, {alpha: (activated ? 1 : 0)}, duration, {ease: FlxEase.cubeOut});
		FlxTween.tween(fogOverlay, {alpha: (activated ? 0.05 : 0)}, duration, {ease: FlxEase.cubeOut});
		for (char in [boyfriend, dad]) {
			FlxTween.color(char, duration, (activated ? FlxColor.WHITE : FlxColor.BLACK), (activated ? FlxColor.BLACK : FlxColor.WHITE), {ease: FlxEase.cubeOut});
		}
		for (sprite in stage.stageSprites) {
			FlxTween.tween(sprite, {alpha: (activated ? 0 : 1)}, duration, {ease: FlxEase.cubeOut});
		}
	}
}

function special() {
	duration = 11;
	// activated = false;
	FlxTween.tween(fog, {alpha: 1}, duration, {ease: FlxEase.cubeOut});
	FlxTween.tween(fogOverlay, {alpha: 0.05}, duration, {ease: FlxEase.cubeOut});
	for (char in [boyfriend, dad]) {
		FlxTween.color(char, duration, FlxColor.WHITE, FlxColor.BLACK, {ease: FlxEase.cubeOut});
	}
	for (sprite in stage.stageSprites) {
		FlxTween.tween(sprite, {alpha: 0}, duration, {ease: FlxEase.cubeOut});
	}
}