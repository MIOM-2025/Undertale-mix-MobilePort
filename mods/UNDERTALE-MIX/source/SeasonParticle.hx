import flixel.FlxSprite;
import flixel.math.FlxRandom;
import Math;
import Date;

class SeasonParticle extends FlxSprite {
	//Random stuff.
	var r = new FlxRandom();
	var xRange = 50;
	var yRange = 80;
	var aSpeed = 30;
	//Particle stuff.
	var particle = 'leaf';
	var direction = (r.bool(50) ? 1 : -1);
	var startingY;
	//Other stuff.
	var siner = 0;
	var ampiflier = r.int(80, 120);
	//Season stuff.
	var season = 1;
	var particleProperties = [
		1 => ['snow', ['FFFFFF']],
		2 => ['leaf', ['FF8080']],
		3 => null,
		4 => ['leaf', ['FF0000', 'FFA040', 'FFFF00']]
	];
	public function new(x:Int, y:Int, ?color:FlxColor) {
		super(x, y);
		
		
		
		var southern = FlxG.save.data.southernSeasons;
		if (southern == null) {
			southern = false;
		}
		
		var d = Date.now().getMonth() + 1;
		if (d >= 12 && d <= 2) {
			season = (southern ? 3 : 1);
		} else if (d >= 3 && d <= 5) {
			season = (southern ? 4 : 2);
		} else if (d >= 6 && d <= 8) {
			season = (southern ? 1 : 3);
		} else if (d >= 9 && d <= 11) {
			season = (southern ? 2 : 4);
		}
		// trace(season);
		// trace(season);
		if (particleProperties[season][0] == null) { return null; }
		particle = particleProperties[season][0];
		var colors = particleProperties[season][1];

		this.velocity.set(r.int(xRange, xRange + 20) * direction, r.int(yRange, yRange + 20));
		this.angularAcceleration = r.int(aSpeed, aSpeed + 20) * direction;
		
		this.loadGraphic(Paths.image('seasonparticles/' + particle));
		this.color = FlxColor.fromString('#' + colors[r.int(0, colors.length - 1)]);
		this.antialiasing = false;
		this.scale.set(0.7, 0.7);
		this.alpha = 0.5;
		
		startingY = y;
	}
	
	override function update(elapsed:Float) {
		siner += 0.1;
		this.acceleration.set(Math.sin(siner) * ampiflier, Math.sin(siner) * (ampiflier - 10));
		if (this.y > startingY + 300) {
			recycle();
		}
		// this.alpha = (show ? 1 : 0);
		super.update(elapsed);
	}
	
	function recycle() {
		direction = (r.bool(50) ? 1 : -1);
		this.velocity.set(r.int(xRange, xRange + 20) * direction, r.int(yRange, yRange + 20));
		this.angularAcceleration = r.int(aSpeed, aSpeed + 20) * direction;
		this.setPosition(r.int(450, 700), startingY);
	}
}