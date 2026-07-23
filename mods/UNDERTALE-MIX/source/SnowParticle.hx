import flixel.FlxSprite;
import flixel.math.FlxRandom;

class SnowParticle extends FlxSprite {
	var startY:Int;
	var r:FlxRandom = new FlxRandom();
	public function new(x, y) {
		super(x, y);
		
		this.loadGraphic(Paths.image('snow'), 6, 6);
		this.animation.add('anim', [0, 1], r.int(2, 6), true);
		this.animation.play('anim', true);
		this.antialiasing = false;
		recycle();
		
		startY = y;
	}
	
	override function update(elapsed:Float) {
		if (this.y > startY + 300) {
			recycle();
		}
		super.update(elapsed);
	}
	
	function recycle() {
		this.y = startY;
		var particleScale:Float = r.float(0.2, 0.5);
		// var particleScroll:Float = r.float
		// this.scrollFactor.set(particleScale, particleScale);
		this.velocity.y = r.int(5, 30);
		this.alpha = r.float(0.3, 0.7);
		this.scale.set(particleScale, particleScale);
	}
}