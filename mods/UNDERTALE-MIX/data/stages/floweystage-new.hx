import flixel.effects.FlxFlicker;

var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/flowey/floweyspot'));
var flowey:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/flowey/flowey'), true, 41, 43);
var fire:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/flowey/FIREFIREEEEEEEEEEEEEEEEEEEEE'), true, 20, 30);
function onStageXMLParsed() {
	bg.screenCenter();
	add(bg);
}

var otherWay:Bool = FlxG.random.bool(50);
var basePlayerStrumPositions = [];
var baseCpuStrumPositions = [];
function postCreate() {
	for (strumLine in strumLines) {
		for (strum in strumLine) {
			if (strumLine.opponentSide) {
				baseCpuStrumPositions.push(strum.x);
			} else {
				basePlayerStrumPositions.push(strum.x);
			}
		}
	}

	camGame.antialiasing = false;
	if (otherWay) {
		dad.setPosition(bg.x + 52, bg.y + 185);
		
		executeEvent({name: 'Change Character', params: [1, 'bf-ut-left']});
		bf.setPosition(bg.x - 108, bg.y + 158);
	} else {
		dad.setPosition(bg.x + 55, bg.y + 185);
		dad.flipX = true;
		dad.swapLeftRightAnimations();
		
		bf.setPosition(bg.x + 168, bg.y + 159);
		
		for (strumLine in strumLines) {
			for (strum in strumLine) {
				if (strumLine.opponentSide) {
					var switchWith = basePlayerStrumPositions;
					strum.x = switchWith[strum.ID];
				} else {
					var switchWith = baseCpuStrumPositions;
					strum.x = switchWith[strum.ID];
				}
			}
		}
	}

	flowey.animation.add('evil', [0], 0, true);
	flowey.animation.add('laugh', [1, 2], 12, true);
	flowey.animation.add('angry', [3], 0, true);
	flowey.animation.add('what', [4], 0, true);
	flowey.animation.add('augh', [5], 0, true);
	flowey.visible = false;
	add(flowey);
	flowey.setPosition(dad.x + 30, dad.y + 29);
	
	fire.animation.add('fire', [0,1,2,3], 12, true);
	fire.setPosition(flowey.x + 100, flowey.y + 8);
	fire.visible = false;
	add(fire);
	
	laugh = FlxG.sound.load(Paths.sound('snd_floweylaugh'), Options.volumeSFX);
}

function onCameraMove(e) {
	if (otherWay || !bg.visible) {
		return;
	}
	if (e.strumLine.opponentSide) {
		camGame.targetOffset.set(38, 0);
	} else {
		camGame.targetOffset.set(0, 0);
	}
}

var cutscene:Bool = false;
var laugh:FlxSound;
var canActuallyEnd:Bool = false;
function onSongEnd(e) {
	if (battle && !cutscene) {
		cutscene = true;
		
		flowey.visible = true;
		floweySet('evil');
		dad.visible = false;
		
		FlxG.sound.play(Paths.sound('snd_impact'), Options.volumeSFX);
		
		boyfriend.playAnim('idle', true);
		var frame:FlxSprite = new FlxSprite(boyfriend.x + 44, boyfriend.y + 43.5).makeGraphic(13, 13, FlxColor.WHITE);
		insert(members.indexOf(boyfriend) - 1, frame);
		
		var frameBg:FlxSprite = new FlxSprite(frame.x + 2, frame.y + 2).makeGraphic(frame.width - 4, frame.height - 4, FlxColor.BLACK);
		insert(members.indexOf(boyfriend) - 1, frameBg);
		
		endingSong = true;
		canPause = false;
		for (strumLine in strumLines.members) {
			strumLine.vocals.stop();
			strumLine.vocals.pitch = 0;
		}
		inst.stop();
		inst.pitch = 0;
		vocals.stop();
		vocals.pitch = 0;
		
		camHUD.visible = false;
		
		camFollow.setPosition(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y - 50);
		FlxTween.tween(camGame, {zoom: 3.6}, 1, {ease: FlxEase.cubeInOut});
		defaultCamZoom = 3.6;
		
		
		madeBullets = bulletAmount;
		FlxTween.tween(flowey, {x: flowey.x}, 1, {onComplete: function() {
			makeBullets();
		}});
		FlxTween.tween(flowey, {y: flowey.y}, (0.04 * bulletAmount) + 1.5, {onComplete: function() {
			floweySet('laugh');

			laugh.play();
			FlxTween.tween(flowey, {angle: 0}, 5.7, {onComplete: function() {
				for (bullet in bullets) {
					bullet.visible = false;
				}
				laugh.stop();
				FlxG.sound.play(Paths.sound('snd_heal_c'), Options.volumeSFX);
				
				floweySet('angry');
				// trace('hello');
				
			}});
			for (bullet in bullets) {
				FlxTween.tween(bullet, {x: boyfriend.getGraphicMidpoint().x - 2, y: boyfriend.getGraphicMidpoint().y - 3}, 7);
			}
		}});
		
		// e.cancel();
	}
	if (!canActuallyEnd) {
		e.cancel();
	}
}

var battle:Bool = false;
var doOnce:Bool = false;
function onGameOver(e) {
	if (battle && !doOnce) {
		doOnce = true;
		endSong();
		e.cancel();
	}
	if (doOnce) {
		e.cancel();
	}
}

var bulletAmount:Int = 51;
var madeBullets:Int = 0;
var bullets:Array<FlxSprite> = [];
var spacing:Float = 0.5;
function makeBullets() {
	if (madeBullets != 0) {
		FlxTween.tween(flowey, {x: flowey.x}, 0.04, {onComplete: function() {
			makeBullet(Math.sin(madeBullets / (bulletAmount * spacing) * Math.PI) * 50, Math.cos(madeBullets / (bulletAmount * spacing) * Math.PI) * 50);
			madeBullets--;
			makeBullets();
			FlxG.sound.play(Paths.sound('snd_chug'), Options.volumeSFX);
		}});
	}
}

function removeStage() {	
	bg.visible = false;
	camGame.targetOffset.set(-3, 0);
	
	executeEvent({name: 'Change Character', params: [1, 'soul']});
	bf.setPosition(dad.x, dad.y + 70);
	
	battle = true;
}

function makeBullet(x:Int, y:Int) {
	var b:FlxSprite = new FlxSprite(x, y).loadGraphic(Paths.image('pellet'), true, 12, 12);
	b.animation.add('a', [0, 1], 12, true);
	b.animation.play('a', true);
	b.scale.set(0.5, 0.5);
	b.updateHitbox();
	b.antialiasing = false;
	b.setPosition(x + (boyfriend.x + 47), y + (boyfriend.y + 47));
	add(b);
	bullets.push(b);
}

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
				floweySet('augh');
				FlxG.sound.play(Paths.sound('snd_ehurt1'), Options.volumeSFX);
				FlxTween.tween(boyfriend, {x: boyfriend.x}, 2, {onComplete: function() {
					canActuallyEnd = true;
					endSong();
				}});
			}});
		});
	}
}