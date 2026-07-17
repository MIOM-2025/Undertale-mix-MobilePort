import flixel.input.mouse.FlxMouseEvent;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.tweens.FlxTweenType;

import flixel.math.FlxRandom;
import flixel.math.FlxMath;
import Math;

import UndertaleText;

import funkin.backend.utils.CoolUtil;

var dog:FlxSprite = new FlxSprite(0, 1200).loadGraphic(Paths.image('minigame/perro'), true, 22, 19);
var r:FlxRandom = new FlxRandom();
var counter:UndertaleText = new UndertaleText(0, 0, 'SCORE: 0', 'center', FlxG.width, 3, 'FF0000', 'undertale-pixel');
var topText:UndertaleText = new UndertaleText(0, 50, 'KILL TOBY FOX', 'center', FlxG.width, 4, 'FF0000', 'undertale-pixel');
var chainsaw:FlxSprite = new FlxSprite().loadGraphic(Paths.image('minigame/chainsaw'));
var untilChainsaw:Int = 100;
function create() {

	FlxG.sound.playMusic(Paths.music('holidaycorrupted'), 1, true);

	dog.animation.add('i', [3], 0, false);
	dog.animation.add('w', [0, 1], 8, true);
	dog.animation.add('h', [2], 0, false);
	dog.antialiasing = false;
	dog.scale.set(4, 4);
	dog.updateHitbox();
	dog.screenCenter(FlxAxes.X);
	add(dog);
	// FlxMouseEvent.add(dog, function onMouseDown(d:FlxSprite) {
		// dogHit();
	// }, null, function onMouseOver(d:FlxSprite) {
	// });
	
	counter.autoSize = true;
	counter.screenCenter();
	add(counter);
	
	topText.autoSize = true;
	topText.screenCenter(FlxAxes.X);
	add(topText);
	FlxTween.tween(topText, {angle: 10}, 0.1, {type: FlxTweenType.PINGPONG});
	FlxTween.tween(topText.scale, {x: 1.3, y: 1.3}, 0.2, {type: FlxTweenType.PINGPONG});
	
	chainsaw.antialiasing = false;
	chainsaw.scale.set(3, 3);
	chainsaw.updateHitbox();
	chainsaw.screenCenter();
	add(chainsaw);
	FlxG.mouse.visible = true;
	
}

var yMax:Int = 640;
var xMax:Int = 1200;
var xMaxNeg:Int = 100;
var timePressed:Float;
var siner:Float = 0;
function postUpdate(elapsed:Float) {
	if (dog.y > yMax) {
		dog.y = yMax;
		dog.acceleration.set(0, 0);
		dog.velocity.set(0, 0);
		dog.angularVelocity = 0;
		dog.angularAcceleration = 0;
		dog.angle = 0;
	}
	if (dog.x > xMax) {
		dog.x = xMax - 5;
		dog.velocity.x = dog.velocity.x * -1;
		dog.acceleration.x = dog.acceleration.x * -1;
	}
	if (dog.x < 0) {
		// dog.velocity.x q;
		dog.velocity.x = dog.acceleration.x * -1;
		dog.acceleration.x = dog.velocity.x;
		dog.x = 0;
	}
	// if (dog.acceleration.x > 0 || dog.velocity.x > 0) {
		// dog.acceleration.x -= 30 / elapsed;
		// dog.velocity.x -= 30 / elapsed;
		// if (dog.acceleration.x < 0) {
			// dog.acceleration.x = 0;
		// }
		// if (dog.velocity.x < 0) {
			// dog.velocity.x = 0;
		// }
	// }
	
	// dog.velocity.x = FlxMath.lerp(0, dog.velocity.x, 0.05);
	// dog.acceleration.x = FlxMath.lerp(0, dog.acceleration.x, 0.05);
	// trace(dog);
	
	// siner += elapsed * 30;
	// topText.angle += Math.sin(siner);
	// topText.scale.set(topText.scale.x / Math.sin(elapsed), topText.scale.y / Math.sin(elapsed));
	if (untilChainsaw == 0) {
		if (FlxG.keys.justPressed.M) {
			chainsawMode = !chainsawMode;
		}
	}
	
	chainsaw.visible = chainsawMode;
	if (chainsawMode) {
		chainsaw.setPosition(FlxG.mouse.x, FlxG.mouse.y);
		chainsaw.offset.set(r.int(-10, 10), r.int(-10, 10));
	}
	
		if (FlxG.mouse.overlaps(dog)) {
			// if (timePressed > 0.15) {
			if (!chainsawMode) {
				if (FlxG.keys.justPressed.SPACE) {
					dogHit();
				}
				} else {
					// dog.setPosition(FlxG.mouse.x, FlxG.mouse.y);
					dogHit();
				}
			// }
			if (!chainsawMode && FlxG.mouse.justPressed) {
				dogHit();
			}
			// timePressed += elapsed;
		// } else {
			// timePressed = 0;
			
		} 
		
	if (FlxG.keys.justPressed.ESCAPE) {
		FlxG.switchState(new ModState('ModMainMenu'));
	}
}

var hit:Int = 0;
var chainsawMode:Bool = false;
function dogHit() {

	hit++;
	if (untilChainsaw != 0) {
		untilChainsaw--;
		counter.text = 'SCORE: ' + hit + '\nUNTIL CHAINSAW: ' + untilChainsaw;
	} else {
		if (chainsawMode) {
			counter.text = 'SCORE: ' + hit;
		} else {
			counter.text = 'SCORE: ' + hit + '\nPRESS M TO TURN ON CHAINSAW MODE';
		}
	}
	
	if (!chainsawMode && untilChainsaw <= 0) {
		counter.text = counter.text + '\nTURN IT ON TURN IT ON';
	}

	dog.velocity.set(r.int(-500, 500), -200);
		dog.acceleration.set(r.int(-500, 500), 500);
		dog.angularVelocity = r.int(-1500, 1500);
		dog.angularAcceleration = r.int(-1500, 1500);

	var b:FlxSprite = new FlxSprite().loadGraphic(Paths.image('minigame/blood' + r.int(0,3)));
	b.antialiasing = false;
	b.scale.set(1, 1);
	b.updateHitbox();
	b.setPosition(dog.getMidpoint().x - 100, dog.getMidpoint().y - 100);
	if (r.bool(99)) {
		FlxTween.tween(b, {alpha: 0}, r.float(0.5, 2), {onComplete: function() {
			b.destroy();
		}});
	} else {
		FlxTween.tween(b, {alpha: 0}, r.float(0.5, 2), {startDelay: r.float(10, 15), ronComplete: function() {
			b.destroy();
		}});
	}
	insert(0, b);
	FlxG.sound.play(Paths.sound('hit/hit' + r.int(0, 4)), 1);
	FlxG.sound.play(Paths.sound('pain/pain' + r.int(0, 8)), 1);
}