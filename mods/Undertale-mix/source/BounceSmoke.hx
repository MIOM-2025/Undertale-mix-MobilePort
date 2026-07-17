import flixel.FlxObject;
import Math;

class BounceSmoke extends FlxSprite {
	var size:Float = 0.4;
	var respawnWait:Float = 0;
	var initX:Int = 0;
	var initY:Int = 0;
	var fuckassWaitObject:FlxObject = new FlxObject();
	
	override function new(x:Int, y:Int, wait:Float, startWait:Float) {
		super(x, y);
		initX = x; initY = y;
		respawnWait = wait;
		
		loadGraphic(Paths.image('stages/hotland/smoke'));
		antialiasing = false;
		scale.set(0.4, 0.4);
		
		direction = FlxG.random.int(30, 90) * FlxG.random.bool(50) ? 1 : -1;

		if (startWait > 0) {
			canStart = false;
			FlxTween.tween(fuckassWaitObject, {x: 1}, startWait, {onComplete: function() {
				canStart = true;
			}});
		}
	}
	
	var inWait:Bool = false;
	var frameTimer:Float = 0;
	var direction:Int = 30;
	override function update(elapsed:Float) {
		if (alpha > 0.1) {
			size += 2.4 * elapsed;
			scale.set(size, size);
		
			x += direction * elapsed;
			y -= 60 * elapsed;
			alpha -= 2.1 * elapsed;
			angle += 180 * elapsed;
		} else {
			if (!inWait) {
				inWait = true;
				
				alpha = 0;
				
				direction = FlxG.random.int(1, 30) * FlxG.random.bool(50) ? 1 : -1;
				size = 0.4;
				if (respawnWait > 0) {
					FlxTween.tween(fuckassWaitObject, {x: 1}, respawnWait, {onComplete: function() {
						reset(initX, initY);
						alpha = 1;
						scale.set(size, size);
						
						inWait = false;
					}});
				} else {
					reset(initX, initY);
					alpha = 1;
					scale.set(size, size);
					
					inWait = false;
				}
			}
		}
	}
}