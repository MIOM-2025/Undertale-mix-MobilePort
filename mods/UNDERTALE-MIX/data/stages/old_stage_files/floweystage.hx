import flixel.effects.FlxFlicker;

var soul:FlxSprite = new FlxSprite().loadGraphic(Paths.image('soul'), true, 20, 16);
var flowey:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/flowey'), true, 41, 43);
var fire:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/FIREFIREEEEEEEEEEEEEEEEEEEEE'), true, 20, 30);
function create() {
	var colors = [
		'determination' => 'FF0000',
		'patience' => '42FCFF',
		'bravery' => 'FCA600',
		'integrity' => '003CFF',
		'perseverance' => 'D535D9',
		'kindness' => '00C000',
		'justice' => 'FFFF00'
	];
	var color:String = FlxG.save.data.soulColor;
	color ??= 'determination';
	var soulColor:String = colors[color];
	soul.color = FlxColor.fromString('#' + soulColor);
	soul.animation.add('soul', [0, 1], 0);
	soul.animation.play('soul', true);
	soul.antialiasing = false;
	soul.visible = false;
	add(soul);

	bed.screenCenter();
	
	flowey.animation.add('evil', [0], 0, true);
	flowey.animation.add('laugh', [1, 2], 12, true);
	flowey.animation.add('angry', [3], 0, true);
	flowey.animation.add('what', [4], 0, true);
	flowey.animation.add('augh', [5], 0, true);
	flowey.antialiasing = false;
	flowey.visible = false;
	add(flowey);
	
	dad.setPosition(bed.x + 52, bed.y + 185);
	insert(members.indexOf(dad) - 1, stage);
	
	flowey.setPosition(dad.x + 30, dad.y + 29);
	
	fire.animation.add('fire', [0,1,2,3], 12, true);
	fire.antialiasing = false;
	fire.setPosition(flowey.x + 100, flowey.y + 8);
	fire.visible = false;
	add(fire);
	
	bf.setPosition(dad.x - 200, dad.y - 26);
}

function removeStage() {
	bed.visible = false;
	
	// bf.color = FlxColor.BLACK;
	// bf.setPosition(dad.x - 25, dad.y + 8);
	executeEvent({name: 'Change Character', params: [1, 'soul']});
	bf.setPosition(bf.x + 201, bf.y + 26);
	bf.color = FlxColor.BLACK;
	
	soul.scale.set(0.5, 0.5);
	soul.updateHitbox();
	soul.setPosition(dad.x + 44, dad.y + 130);
	
	camGame.snapToTarget();
	
	// canDie = false;
	// bulletCircle();
}

var frameTimer:Float = 0.05;
// function postUpdate(elapsed:Float) {
	// camGame.zoom = 1;

// }

function floweySet(e:String) {
	flowey.animation.play(e, true);
	if (e == 'augh') {
		flowey.velocity.set(-300,-20);
		flowey.angularVelocity = 100;
	} else if (e == 'angry') {
		fire.visible = true;
		FlxFlicker.flicker(fire, 0.6, 0.04, true, false, function() {
			FlxTween.tween(fire, {x: flowey.x + 24}, 0.39, {onComplete: function() {
				fire.visible = false;
			}});
		});
	}
}

var gameOvered:Bool = false;
function onGameOver(e) {
	// trace(Conductor.songPosition);
	if (Conductor.songPosition > 39000) {
		if (health <= 0 && !gameOvered) {
			gameOvered = true;
			health = 0.01;
			FlxG.sound.music.time = 79000;
			vocals.volume = 1;
			canDie = false;
			Conductor.songPosition = 79000;
			trace('h');
			e.cancel();
		}
	}

}

function postUpdate() {
		if (gameOvered) {
		vocals.volume = 1;
	}
}

var bulletAmount:Int = 51;
var curBullet:Int = 0;
// var frameTime
var spacing:Float = 0.5;
var bullets:Array<FlxSprite> = [];
var cutscene:Bool = false;
function bulletCircle() {
	vocals.volume = 1;

	curBullet = bulletAmount;
	timer = new FlxTimer().start(0.04, function() {
		makeBullet(Math.sin(curBullet / (bulletAmount * spacing) * Math.PI) * 50, Math.cos(curBullet / (bulletAmount * spacing) * Math.PI) * 50);
		curBullet--;
		// trace(timer.loops);
	}, bulletAmount);
	
	var frame:FlxSprite = new FlxSprite(soul.x - 2, soul.y - 3).makeGraphic(soul.width + 4, (soul.height + 2) + 4, FlxColor.WHITE);
	insert(members.indexOf(soul) - 1, frame);
	
	var frameBg:FlxSprite = new FlxSprite(frame.x + 2, frame.y + 2).makeGraphic(frame.width - 4, frame.height - 4, FlxColor.BLACK);
	insert(members.indexOf(soul) - 1, frameBg);
	
	cutscene = true;
	dad.visible = false;
	flowey.visible = true;
	soul.visible = true;
	bf.visible = false;
	camHUD.visible = false;
	bf.stunned = true;
}

function onInputUpdate(e) {
	if (cutscene) {
		e.cancel();
	}
}

function bulletAttack() {
	for (bullet in bullets) {
		FlxTween.tween(bullet, {x: soul.x + 2, y: soul.y + 1}, 4.6);
	}
}

function bulletKill() {
	for (bullet in bullets) {
		bullet.visible = false;
	}

}

function makeBullet(x:Int, y:Int) {
	var b:FlxSprite = new FlxSprite(x, y).loadGraphic(Paths.image('pellet'), true, 12, 12);
	b.animation.add('a', [0, 1], 12, true);
	b.animation.play('a', true);
	b.scale.set(0.5, 0.5);
	b.updateHitbox();
	b.antialiasing = false;
	b.setPosition(x + (soul.x + 2), y + (soul.y));
	add(b);
	bullets.push(b);
}