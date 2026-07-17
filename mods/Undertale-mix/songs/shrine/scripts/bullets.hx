import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTweenType;

var canDance:Bool = false;
var bulletCamera = new FlxCamera();

var line_1:FlxBackdrop;
var line_2:FlxBackdrop;
var beatTime:Float = 0;
function create() {
	FlxG.cameras.add(bulletCamera, false);
	bulletCamera.antialiasing = false;
	bulletCamera.bgColor = FlxColor.TRANSPARENT;
	
	line_1 = bullet();
	line_2 = bullet(94);
}

function postCreate() {
	beatTime = Conductor.crochet / 1000;
}

var bulletStartPoint = 668;
function bullet(?offset:Int) {
	b = new FlxBackdrop(null, FlxAxes.X, 28).loadGraphic(Paths.image('stages/dogshrine-switch/mewbullet'), true, 19, 21);
	b.animation.add('dance', [0, 1, 2, 3], 8, false);
	b.scale.set(4, 4);
	b.animation.play('dance', true);
	b.velocity.x = 60;
	b.y = bulletStartPoint;
	b.offset.y = -150;
	b.setPosition(offset, b.y);
	b.cameras = [bulletCamera];
	add(b);
	return b;
}

function bulletDance() {
	canDance = true;
	for (l in [line_1, line_2]) {
		FlxTween.tween(l.offset, {y: 0}, Conductor.crochet / 1000, {ease: FlxEase.quadInOut});
	}
}

function bulletStop() {
	canDance = false;
	for (l in [line_1, line_2]) {
		l.offset.y = -150;
	}
}

function bulletDanceStop() {
	canDance = false;
}

var first:Bool = false;
function beatHit(beat:Int) {
	if (canDance) {
		var object:FlxBackdrop = (first ? line_1 : line_2);
		object.animation.play('dance', true);
		FlxTween.tween(object, {y: object.y - 30}, beatTime / 2, {ease: FlxEase.cubeOut, onComplete: function() {
			FlxTween.tween(object, {y: object.y + 30}, beatTime / 2, {ease: FlxEase.cubeIn});
		}});
		first = !first;
	}
}