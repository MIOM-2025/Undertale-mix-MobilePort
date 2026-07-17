import UndertaleText;
import funkin.backend.utils.DiscordUtil;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxColor;
import Math;

var soul:FlxSprite = new FlxSprite();
var currentSpeed:Int = 500;
var bottomBound:Float = 0;
var soulHitbox:FlxSprite = new FlxSprite().makeGraphic(26, 26, FlxColor.RED);
var collisionGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
var healthPointsText:UndertaleText = new UndertaleText(48, 50, 'HEALTH POINTS:', 'left', FlxG.width, 3, 'FFFFFF', 'undertale-pixel');
var currentHealth:Int = 0;
var healthBlocks:Array<FlxSprite> = [];
var points:Float = 0;
var pointsText:UndertaleText = new UndertaleText(healthPointsText.x, healthPointsText.y + 50, '000000000', 'left', FlxG.width, 3, 'FFFFFF', 'undertale-pixel');
var maxHealth:Int = 3;
function create() {
	var floor:FlxSprite = new FlxSprite(0, 530).makeGraphic(FlxG.width, 8);
	add(floor);
	
	var colors = [
		'determination' => 'FF0000',
		'patience' => '42FCFF',
		'bravery' => 'FCA600',
		'integrity' => '003CFF',
		'perseverance' => 'D535D9',
		'kindness' => '00C000',
		'justice' => 'FFFF00'
	];
	var thisColor:String = FlxG.save.data.soulColor;
	thisColor ??= 'determination';
	var soulColor:String = colors[thisColor];
	var actualColor:FlxColor = FlxColor.fromString('#' + soulColor);
	soul.color = actualColor;
	soul.frames = Paths.getAsepriteAtlas('minigames/runner/soul');
	soul.animation.addByPrefix('r', 'run0', 12, true);
	soul.animation.addByPrefix('j', 'jump0', 12, true);
	soul.animation.addByPrefix('s', 'still0', 12, true);
	soul.animation.play('s', true);
	soul.scale.set(3, 3);
	soul.updateHitbox();
	soul.flipX = true;
	add(soul);
	soul.setPosition(floor.x + 100, floor.y - soul.height);
	
	bottomBound = floor.y - soul.height;
	
	
	spawnTime = (currentSpeed / 100) / 2;
	
	soulHitbox.visible = false;
	add(soulHitbox);
	
	healthPointsText.autoSize = true;
	healthPointsText.scale.set(2, 3);
	healthPointsText.updateHitbox();
	add(healthPointsText);
	
	pointsText.autoSize = true;
	pointsText.scale.set(3, 3);
	pointsText.updateHitbox();
	add(pointsText);
	
	
	if (FlxG.save.data.runnerHealth != null) {
		maxHealth = FlxG.save.data.runnerHealth;
	}
	for (i in 0...maxHealth) {
		var hpBlock:FlxSprite = new FlxSprite(((healthPointsText.x + healthPointsText.width) + 40 * i) + 10, healthPointsText.y + 4).makeGraphic(30, healthPointsText.height / 1.5, FlxColor.YELLOW);
		hpBlock.updateHitbox();
		hpBlock.ID = i;
		add(hpBlock);
		healthBlocks.push(hpBlock);
	}
	currentHealth = maxHealth;
	
	for (i in FlxG.random.int(-50, -100)...FlxG.random.int(50, 100)) {
		exclude = exclude + ',' + i;
	}
	
	DiscordUtil.changePresenceAdvanced({
		state: 'Running... HP: ' + maxHealth + '/' + maxHealth,
		details: 'Minigame time!'
	});
}

function postCreate() {
		// if (controls.ACCEPT && !pressOnceBro) {		
	soul.animation.play('r', true);
	FlxTween.tween(soul, {x: soul.x + 100}, 0.5, {ease: FlxEase.quadInOut, onComplete: function() {
		spawnBulletPattern(5);
		startedRunning = true;
	}});
}

// function preUpdate() {

// }

var rise:Float = 600;
var released:Bool = false;
var topBound:Float = 150;
var startedRunning = false;
var spawnTime:Float = 2;
var spawnElapsed:Float = 0;
var wiggleRoom:Int = 300;
var cantHurt:Bool = false;
var stopGame:Bool = false;
var pressOnceBro:Bool = false;
var firstFrame:Bool = false;
function update(elapsed:Float) {
	if (stopGame) {
		return;
	}
	
	if (!startedRunning) {
		return;
	}
	
	if (spawnElapsed > spawnTime) {
		spawnBulletPattern(FlxG.random.int(0, 5));
		currentSpeed += (wiggleRoom * 2) * elapsed;
		spawnTime = (1000 / currentSpeed) + 0.1;
		spawnElapsed = 0;
	} else {
		spawnElapsed += 3 * elapsed;
	}

	if (released) {
		soul.acceleration.y = rise * 4;
		if (soul.velocity.y > rise * 2) {
			soul.velocity.y = rise * 2;
		}
	}

	if (controls.UP_P) {
		if (!released) {
			soul.velocity.y = -rise;
		}
		soul.animation.play('j', true);
	} else if (controls.UP_R) {
		released = true;
	}
	
	if (controls.LEFT) {
		soul.x -= currentSpeed * elapsed;
	} else if (controls.RIGHT) {
		soul.x += currentSpeed * elapsed;
	}
	
	if (controls.DOWN_P) {	
		released = true;
		soul.velocity.y = rise * 2;
	}
	
	points += wiggleRoom * elapsed;
	pointsText.text = CoolUtil.addZeros(Math.round(points), 9);
	
	if (cantHurt) {
		return;
	}
	if (FlxG.overlap(soulHitbox, collisionGroup)) {
		soulHurt();
	}
	// trace(soul.velocity.y);
}

var availableBullets:Array<FlxSprite> = [];
var existingBullets:Array<FlxSprite> = [];
function spawnBulletPattern(type:Int) {
	switch(type) {
		case 0:
			spawnBullet(FlxG.width, bottomBound + 23, availableBullets[0]);
		case 1:
			spawnBullet(FlxG.width, bottomBound - 23, availableBullets[0]);
			spawnBullet(FlxG.width, bottomBound + 23, availableBullets[0]);
		case 2:
			spawnBullet(FlxG.width, bottomBound - 23 * 11, availableBullets[0]);
			spawnBullet(FlxG.width, bottomBound - 23 * 13, availableBullets[0]);
			spawnBullet(FlxG.width, bottomBound - 23, availableBullets[0]);
			spawnBullet(FlxG.width, bottomBound + 23, availableBullets[0]);
		case 3:
			spawnBullet(FlxG.width, bottomBound - 23 * 6, availableBullets[0]);
			spawnBullet(FlxG.width, bottomBound - 23 * 4, availableBullets[0]);
		case 4:
			spawnBullet(FlxG.width, bottomBound - 23, availableBullets[0]);
			spawnBullet(FlxG.width, bottomBound - 23 * 3, availableBullets[0]);
			spawnBullet(FlxG.width, bottomBound - 23 * 5, availableBullets[0]);
			spawnBullet(FlxG.width, bottomBound + 23, availableBullets[0]);
		case 5:
			spawnBullet(FlxG.width, bottomBound - 23, availableBullets[0]);
			spawnBullet(FlxG.width, bottomBound - 23 * 3, availableBullets[0]);
			spawnBullet(FlxG.width, bottomBound - 23 * 5, availableBullets[0]);
			spawnBullet(FlxG.width, bottomBound - 23 * 7, availableBullets[0]);
			spawnBullet(FlxG.width, bottomBound + 23, availableBullets[0]);
	}
}

function spawnBullet(x:Int, y:Int, useBullet:FlxSprite) {
	// trace(useBullet);
	// var b:FlxSprite;
	if (useBullet != null) {
		// useBullet;
		useBullet.reset(x, y);
		availableBullets.remove(useBullet);
		add(useBullet);
	} else if (useBullet == null) {
		useBullet = new FlxSprite(x, y).loadGraphic(Paths.image('minigames/runner/bullets/box'));
		add(useBullet);
	}
	collisionGroup.add(useBullet);
	FlxTween.tween(useBullet, {y: useBullet.y}, (1000 / (currentSpeed - 100)) * 2, {onComplete: function() {
		useBullet.kill();
		existingBullets.remove(useBullet);
		collisionGroup.remove(useBullet);
	}});
	useBullet.velocity.x = -currentSpeed;
	useBullet.scale.set(2, 2);
	useBullet.updateHitbox();
}

function postUpdate(elapsed:Float) {
	// if (soul.y > topBound) {
		// soul.y = topBound;
	if (soul.y < topBound) {
		released = true;
		soul.y = topBound;
	} else if (soul.y > bottomBound) {
		released = false;
		soul.velocity.y = soul.acceleration.y = 0;
		soul.y = bottomBound;
		soul.animation.play('r', true);
	} 
	if (soul.x < 0) {
		soul.x = 0;
	} else if (soul.x > FlxG.width - soul.width) {
		soul.x = FlxG.width - soul.width;
	}
	
	soulHitbox.setPosition(soul.x + 11, soul.y + 11);
	// trace(currentSpeed);
}

function soulHurt() {
	healthBlocks[currentHealth - 1].color = FlxColor.RED;
	healthBlocks[currentHealth - 1].alpha = 0.5;
	currentHealth -= 1;
	soul.alpha = 0.5;
	cantHurt = true;
	FlxG.sound.play(Paths.sound('hurt'), Options.volumeSFX);
	FlxG.sound.play(Paths.sound('break'), Options.volumeSFX);
	FlxG.camera.shake(0.02, 0.1);
	if (currentSpeed > 1000) {
		currentSpeed /= 2;
		collisionGroup.forEach(function(block:FlxSprite) {
			block.velocity.x = currentSpeed;
		});
	}
	
	DiscordUtil.changePresenceAdvanced({
		state: 'Running... HP: ' + currentHealth + '/' + maxHealth,
		details: 'Minigame time!'
	});
	
	if (currentHealth == 0) {
		collisionGroup.forEach(function(block:FlxSprite) {
			block.velocity.x = 0;
			var fake = new FlxSprite(block.x, block.y).loadGraphic(Paths.image('minigames/runner/bullets/box'));
			add(fake);
			fake.scale.set(2, 2);
			fake.updateHitbox();	
		});
		stopGame = true;
		soul.visible = false;
		FlxG.sound.play(Paths.sound('shatter'), Options.volumeSFX);
		for (i in 0...9) {
			soulShard(soul.x, soul.y);
		}
		FlxTween.tween(soul, {x: soul.x}, 0.5, {onComplete: function() {
			persistentUpdate = false;
			persistentDraw = true;
			openSubState(new ModSubState('SoulRunnerResults', {totalPoints: points, maxHP: maxHealth}));
		}});

		return;
	}
	
	for (i in 0...4) {
		soulShard(soul.x, soul.y);
	}
	FlxTween.tween(healthPointsText, {x: healthPointsText.x}, 1.6, {onComplete: function() {
		soul.alpha = 1;
		cantHurt = false;
	}});
}

var exclude:String = '';
function soulShard(s_x, s_y) {
	var shard:FlxSprite = new FlxSprite(s_x, s_y).loadGraphic(Paths.image('shard'), true, 7, 8);
	shard.antialiasing = false;
	shard.color = soul.color;
	shard.animation.add('anim', [0, 1, 2, 3], 8);
	shard.animation.play('anim', true);
	shard.scale.set(soul.scale.x / 2, soul.scale.y / 2);
	shard.velocity.set(FlxG.random.int(200, -250, exclude), FlxG.random.int(200, -250, exclude));
	shard.acceleration.y = 600;
	add(shard);
	FlxTween.tween(shard, {angle: shard.angle}, 3, {onComplete: function() {
		shard.velocity.set(0, 0);
		shard.acceleration.y = 0;
		shard.destroy();
	}});
}