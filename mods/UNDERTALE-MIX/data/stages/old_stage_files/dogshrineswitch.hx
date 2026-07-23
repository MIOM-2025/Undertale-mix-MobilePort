import funkin.game.Character;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTweenType;

var battleMewMew;
var mewmewBullet:FlxBackdrop;
var bulletBackdrop:FlxBackdrop;
var bulletBackdropAgain:FlxBackdrop;
var canDance:Bool = false;
var bulletCamera = new FlxCamera();
var bulletStartPoint = 668;
function create() {
	// var bullet:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/dogshrine-switch/mewbullet'), true, 19, 21);
	// bullet.animation.add('dance', [0, 1, 2, 3], true);
	// bullet.antialiasing = false;
	// bullet.cameras = [camHUD];
	// bullet.scale.set(3, 3);
	// bullet.screenCenter();
	// add(bullet);
	
	FlxG.cameras.add(bulletCamera, false);
	bulletCamera.pixelPerfectRender = true;
	// bulletCamera.y = 100;
	bulletCamera.bgColor = FlxColor.TRANSPARENT;
	
	bulletBackdrop = new FlxBackdrop(null, FlxAxes.X, 28).loadGraphic(Paths.image('stages/dogshrine-switch/mewbullet'), true, 19, 21);
	bulletBackdrop.animation.add('dance', [0, 1, 2, 3], 8, false);
	bulletBackdrop.antialiasing = false;
	bulletBackdrop.scale.set(4, 4);
	bulletBackdrop.animation.play('dance', true);
	bulletBackdrop.velocity.x = 60;
	bulletBackdrop.y = bulletStartPoint;
	bulletBackdrop.offset.y = -150;
	bulletBackdrop.cameras = [bulletCamera];
	add(bulletBackdrop);
	
	bulletBackdropAgain = new FlxBackdrop(null, FlxAxes.X, 28).loadGraphic(Paths.image('stages/dogshrine-switch/mewbullet'), true, 19, 21);
	bulletBackdropAgain.animation.add('dance', [0, 1, 2, 3], 8, false);
	bulletBackdropAgain.antialiasing = false;
	bulletBackdropAgain.scale.set(4, 4);
	bulletBackdropAgain.animation.play('dance', true);
	bulletBackdropAgain.velocity.x = 60;
	bulletBackdropAgain.offset.y = bulletBackdrop.offset.y;
	bulletBackdropAgain.setPosition(94, bulletBackdrop.y);
	bulletBackdropAgain.cameras = [bulletCamera];
	add(bulletBackdropAgain);
}

function postCreate() {
	// camGame.pixelPerfectRender = true;
	// curCameraTarget = -1;
	
	camFollow.setPosition(shrine.getGraphicMidpoint().x, shrine.getGraphicMidpoint().y - 22);
	camGame.snapToTarget();
	
	// player.cpu = true;
	
	battleMewMew = new Character(dad.x, dad.y, 'mewmew-battle');
	// battleMewMew.visible = false;
	// add(battleMewMew);
	// camHUD.visible = false;
	// playerStrums.cpu = true;
}

//Ok I'll add the anchor stuff later I wanna see this in action now.
var activeBattle = false;
var black:FlxSprite;
function battleSection() {
	activeBattle = true;
	
	// bf.visible = false; dad.visible = false;
	// bf.setPosition(9999, 9999); dad.setPosition(bf.x, bf.y);
	for (sprite in stage.stageSprites) {
		sprite.visible = false;
	}
	black = new FlxSprite(battleMewMew.x, battleMewMew.y).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	// add(black);
	add(battleMewMew);
	
	executeEvent({name: 'HScript Call', params: ['setMiddle', '']});
	camFollow.setPosition(156.5, 125);
}

function unBattleSection() {
	activeBattle = false;
	
	for (sprite in stage.stageSprites) {
		sprite.visible = true;
	}
	remove(black);
	battleMewMew.visible = false;
	executeEvent({name: 'HScript Call', params: ['setUnMiddle', '']});
}

function update() {
	if (activeBattle) {
		battleMewMew.playAnim(dad.animation.curAnim.name, true, null, false, dad.animation.curAnim.curFrame);
	}
}

function onEvent(event) {
	if (event.event.name == 'Mew Mew Bullets Dance') {
		canDance = true;
		FlxTween.tween(bulletBackdrop.offset, {y: 0}, 1, {ease: FlxEase.quadInOut});
		FlxTween.tween(bulletBackdropAgain.offset, {y: 0}, 1, {ease: FlxEase.quadInOut});
	}
}

var firstBeat:Bool = false;
function beatHit(curBeat:Int) {
	if (curBeat % 2 == 0 && canDance) {
		firstBeat = !firstBeat;
		if (firstBeat) {
			bulletBackdrop.animation.play('dance', true);
			FlxTween.tween(bulletBackdrop, {y: bulletBackdrop.y - 30}, Conductor.crochet / 1000, {ease: FlxEase.cubeOut, onComplete: function() {
				FlxTween.tween(bulletBackdrop, {y: bulletStartPoint}, Conductor.crochet / 1000, {ease: FlxEase.quintIn});
			}});
		} else {
			bulletBackdropAgain.animation.play('dance', true);
			FlxTween.tween(bulletBackdropAgain, {y: bulletBackdropAgain.y - 30}, Conductor.crochet / 1000, {ease: FlxEase.cubeOut, onComplete: function() {
				FlxTween.tween(bulletBackdropAgain, {y: bulletStartPoint}, Conductor.crochet / 1000, {ease: FlxEase.quintIn});
			}});
		}
	}
}