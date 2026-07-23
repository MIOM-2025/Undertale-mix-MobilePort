import flixel.tweens.FlxTweenType;

var halfLeft:FlxSprite = new FlxSprite().makeGraphic(FlxG.width / 2, FlxG.height, FlxColor.BLACK);
var halfRight:FlxSprite = new FlxSprite().makeGraphic(FlxG.width / 2, FlxG.height, FlxColor.BLACK);
var animation:FlxSprite = new FlxSprite();
var charaAnims:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/flowerbed/charaanims'), true, 19, 33);
function create() {
	animation.frames = Paths.getAsepriteAtlas('stages/flowerbed/tungtung');
	animation.animation.addByPrefix('a', 'anim', 8, false);
	animation.scrollFactor.set(0, 0);
	animation.screenCenter();
	animation.updateHitbox();
	add(animation);
	animation.visible = false;
	
	charaAnims.animation.add('j', [2, 3, 4], 12);
	charaAnims.scrollFactor.set(0, 0);
	charaAnims.screenCenter();
	add(charaAnims);
	charaAnims.visible = false;
}

var dontDoThatAgain:Bool = false;
function coolTransition() {
	camGame.shake(0.01, 0.2);
	camHUD.shake(0.01, 0.2);
	
	halfLeft.setPosition(0, 0);
	halfLeft.velocity.set(0, 0);
	halfLeft.acceleration.set(0, 0);
	halfLeft.angularAcceleration = 0;
	halfLeft.angularVelocity = 0;
	halfLeft.angle = 0;
	
	halfRight.velocity.set(0, 0);
	halfRight.acceleration.set(0, 0);
	halfRight.angularAcceleration = 0;
	halfRight.angularVelocity = 0;
	halfRight.angle = 0;
	
	halfLeft.cameras = [camHUD];
	halfLeft.screenCenter(FlxAxes.Y);
	add(halfLeft);
	
	halfRight.cameras = [camHUD];
	halfRight.setPosition(halfLeft.x + halfLeft.width, halfLeft.y);
	add(halfRight);
	
	halfLeft.velocity.set(-300, 500);
	halfLeft.acceleration.set(-100, -2000);
	halfLeft.angularAcceleration = -30;
	halfLeft.angularVelocity = -10;
	
	halfRight.velocity.set(300, 600);
	halfRight.acceleration.set(100, -2200);
	halfRight.angularAcceleration = 50;
	halfRight.angularVelocity = 10;
	
	anim.visible = false;
	if (!dontDoThatAgain) {
		dad.setPosition(dad.x - 4, dad.y + 4);
		dontDoThatAgain = true;
	}
	
	if (PlayState.opponentMode) {
		remove(halfLeft);
		insert(0, halfLeft);
		remove(halfRight);
		insert(0, halfRight);
		camHUD.visible = true;
		camHUD.zoom = 1;
	}
	//131, 56
}

var slash:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/flowerbed/slash'), true, 26, 110);
function screenSlash() {
	slash.animation.add('i', [0, 1, 2, 3, 4, 5, 6], 12, false);
	slash.animation.play('i', true);
	slash.cameras = [camHUD];
	
	slash.scale.set(3, 3);
	slash.updateHitbox();
	slash.screenCenter();
	add(slash);
	
	if (PlayState.opponentMode) {
		remove(halfLeft);
		insert(0, halfLeft);
		remove(halfRight);
		insert(0, halfRight);
		camHUD.visible = true;
		camHUD.zoom = 1;
	}
}

function postUpdate() {
	if (PlayState.opponentMode) {
		if (!camHUD.visible) {
			camHUD.visible = true;
		}
		if (camHUD.zoom > 1) {
			camHUD.zoom = 1;
		}
		if (camHUD.angle != 0) {
			camHUD.angle = 0;
		}
	}
}

function voicelineAnim() {
	animation.animation.play('a', true);
	animation.visible = true;
	animation.animation.timeScale = 0.94;
	
	for (uglies in [bf, dad, bed]) {
		uglies.visible = false;
	}
}

function comeBack() {
	for (uglies in [bf, dad, bed]) {
		uglies.visible = true;
	}
	charaAnims.visible = red.visible = false;
}

var anim:FlxSprite = new FlxSprite();
function charaTransform() {
	dad.alpha = 0;
	anim.setPosition(dad.x, dad.y);
	anim.antialiasing = false;
	anim.frames = Paths.getAsepriteAtlas('stages/flowerbed/transformation');
	anim.animation.addByPrefix('a', 't', 8, false);
	anim.animation.play('a', true);
	add(anim);
}

function scary() {
	bf.visible = false;
	bed.visible = false;
}

var red:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
function jumpy() {
	red.scrollFactor.set(0, 0);
	red.screenCenter();
	red.color = FlxColor.BLACK;
	insert(members.indexOf(animation) - 1, red);
	if (FlxG.save.data.flashingLights) {
		FlxTween.color(red, 0.1, FlxColor.BLACK, FlxColor.RED, {type: FlxTweenType.PINGPONG});
	}
	
	animation.visible = false;

	charaAnims.visible = true;
	charaAnims.animation.play('j', true);
	charaAnims.updateHitbox();
	
	FlxTween.tween(charaAnims.scale, {x: 12, y: 12}, 0.8);
	camGame.shake(0.002, 1);
}

var middle = [412, 524, 636, 748];
function strumChange() {
	// camHUD.visible = false;
	for (strumLine in strumLines.members) {
		if (strumLine.opponentSide) {
			for (note in strumLine.notes) {
				note.alpha = PlayState.opponentMode ? 1 : 0;
			}
		} else {
			for (note in strumLine.notes) {
				note.alpha = PlayState.opponentMode ? 0 : 1;
			}
		}
		for (strum in strumLine) {
			if (strumLine.opponentSide) {
				strum.alpha = PlayState.opponentMode ? 1 : 0;
				// originalValuesOponent.push(strum.x);
			} else {
				strum.alpha = PlayState.opponentMode ? 0 : 1;
				// originalValuesPlayer.push(strum.x);
			}
			strum.x = middle[strum.ID];
		}
	}
}
