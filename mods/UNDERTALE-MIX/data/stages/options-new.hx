import flixel.math.FlxRandom;
import flixel.tweens.FlxTweenType;

import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;

import Toby;
import UndertaleText;

var charY:Int = 12;
var r:FlxRandom = new FlxRandom();
var toby:Toby;
var grid:FlxBackdrop;
var top:FlxCamera = new FlxCamera();
var canGlow:Bool = false;
var startSong = false;
var runninAround:FlxTween;
var jumpinUp:FlxTween;

var otherToby:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/options/tony'), true, 22, 19);
var tobyBall:FlxSprite = new FlxSprite(108, -200).loadGraphic(Paths.image('stages/options/balltoby'), true, 23, 22);
var dither:FlxBackdrop = new FlxBackdrop(Paths.image('stages/options/dither'), FlxAxes.X);
var secret:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/options/secretdogroom'));
var pile:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/options/dogpile'), true, 25, 19);
var dogShrine:FlxSprite = new FlxSprite(-10, 10).loadGraphic(Paths.image('stages/options/dogshrine'));
var tubeGuy:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/options/tubeguy'));
var speaker:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/options/speaker'));
var tobyOn:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/options/tobyonthething'));
var battleTransition:FlxSprite = new FlxSprite();
var battleBg:FlxSprite = new FlxSprite();
var battleCover:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
function create() {
	camGame.antialiasing = false;
	camGame.bgColor = FlxColor.TRANSPARENT;
	toby = new Toby(200, 120 + charY, '', this, (PlayState.SONG.meta.name == 'temperate' || PlayState.SONG.meta.name == 'temperate-cmix' ? false : true));

	if (PlayState.SONG.meta.name == 'temperate') {
		FlxG.cameras.add(top, false);
		top.bgColor = FlxColor.TRANSPARENT;
		top.zoom = 4;

		toby.screenCenter();
		toby.cameras = [top];
		toby.hide(false);
		
		otherToby.animation.add('w', [0, 1], 4, true);
		otherToby.animation.add('stop', [2], 0);
		otherToby.animation.add('still', [3], 0);
		otherToby.animation.play('w', true);
		add(otherToby);
	} else {
		toby.updateVariant('hat');
		runninAround = FlxTween.tween(toby, {x: toby.x - 40}, 1, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
	}

	var g:FlxSprite = FlxGridOverlay.create(20, 20, 120, 120, true, 0xFF969696, 0xFF404040);
	grid = new FlxBackdrop(g.pixels, FlxAxes.XY);
	grid.alpha = 0;
	grid.scrollFactor.set(0, 0);
	insert(0, grid);
	// trace(PlayState.SONG.meta.name);
	
	tobyBall.visible = false;
}

var title:UndertaleText;
var options:Array<UndertaleText> = [];
function postCreate() {
	var optionList:Array<String> = [
		'controls',
		'gameplay',
		'appearance',
		'miscellaneous'
	];
	if (FlxG.save.data.devMode) { optionList.push('debug'); }
	
	bf.setPosition(42, 74 + charY);
	camGame.targetOffset.y = -20;
	
	title = new UndertaleText(-482, -4, 'OPTIONS', 'center', FlxG.width, 2, 'FFFFFF', 'undertale-outline');
	add(title);
	
	var index:Int = 0;
	for (option in optionList) {
		var o:UndertaleText = new UndertaleText(114, 34 + (18 * index) , option.toUpperCase(), 'left', FlxG.width, 1.2, 'FFFFFF', 'undertale-outline');
		add(o);
		options.push(o);
		index++;
	}
	
	dither.setPosition(-100, 200);
	add(dither);
	
	pile.animation.add('i', [0, 1], 0);
	pile.animation.play('i', true);
	add(pile);
	
	add(tobyBall);
	
	secret.setPosition(200, 600);
	insert(members.indexOf(dad) - 1, secret);
	
	battleTransition.frames = Paths.getSparrowAtlas('stages/options/bossspiral');
	battleTransition.animation.addByPrefix('i', 'spiral0', 24, false);
	battleTransition.screenCenter();
	// battleTransition.animation.play('i', true);
	battleTransition.alpha = 0;
	battleTransition.cameras = [top];
	add(battleTransition);
	
	battleCover.visible = false;
	battleCover.scrollFactor.set(0, 0);
	add(battleCover);
	
	var bgs:Array<Array<String>> = [['backgroundNew', 'backgroundnew'], ['runawaydog', 'runawaydog'], ['veinydih', 'waveylines'], ['prettypattern', 'prettypattern']];
	var bg:Array<String> = bgs[r.int(0, bgs.length - 1)];
	battleBg.frames = Paths.getSparrowAtlas('stages/options/' + bg[0]);
	battleBg.animation.addByPrefix('i', bg[1], (FlxG.save.data.flashingLights ? 24 : 0), true);
// if (!FlxG.save.data.flashingLights) {
			// return;
		// }
	battleBg.animation.play('i', true);
	battleBg.scale.set(0.81, 0.81);
	battleBg.updateHitbox();
	battleBg.screenCenter();
	battleBg.scrollFactor.set(0, 0);
	battleBg.visible = false;
	add(battleBg);
	
	dogShrine.visible = false;
	add(dogShrine);
	
	tubeGuy.setPosition(dogShrine.x + 48, dogShrine.y + 42);
	tubeGuy.frames = Paths.getSparrowAtlas('stages/options/tubeguy');
	tubeGuy.animation.addByIndices('danceLeft', 'tubeguy0', [0, 1], null, 8, false);
	tubeGuy.animation.addByIndices('danceRight', 'tubeguy0', [2, 3], null, 8, false);
	tubeGuy.visible = false;
	add(tubeGuy);
	
	speaker.setPosition(dogShrine.x + 228, dogShrine.y + 80);
	speaker.frames = Paths.getSparrowAtlas('stages/options/speaker');
	speaker.animation.addByPrefix('i', 'speaker0', 8, false);
	speaker.visible = false;
	add(speaker);
	
	pile.setPosition(secret.x + 94, secret.y + 147);
}

var difficulty:String = 'normal';
function onStartCountdown(e) {
	if (PlayState.SONG.meta.name == 'temperate') {
		if (!startSong) {
			camHUD.visible = (PlayState.opponentMode ? true : false);
			tobyRun();
			e.cancel();
		}
	}
}

function onStartSong() {
	if (PlayState.SONG.meta.name == 'temperate') {
		if (difficulty == 'skiptobattle') {
			bf.setPosition(secret.x + 138, secret.y + 64);	
			dad.setPosition(secret.x + 86, secret.y + 90);
			
			executeEvent({name: 'Change Character', params: [1, 'bf-ut' ]});
			executeEvent({name: 'Change Character', params: [0, 'toby']});
			
			executeEvent({name: 'Camera Position', params: [secret.getGraphicMidpoint().x, secret.getGraphicMidpoint().y, false, 0, 'CLASSIC', 'In', false]});
			executeEvent({name: 'Camera Zoom', params: [false, 4, 'camGame', 4, 'linear', 'In', 'direct']});
			
			camGame.targetOffset.set(0, 0);
		} else if (difficulty == 'afterbattle') {
			executeEvent({name: 'Change Character', params: [0, 'toby-earthbound']});
			executeEvent({name: 'HScript Call', params: ['earthboundCreate', '']});
			battleStart();
			executeEvent({name: 'HScript Call', params: ['setVisibility', 'false']});
		} else if (difficulty == 'shrinetransition') {
			for (o in options) {
				o.visible = false;
			}
			mimic = true;
			otherToby.visible = false;
			toby.hide(false);
			dogged = false;
			camHUD.visible = true;
		
			tubeGuy.visible = speaker.visible = dogShrine.visible = true;
			executeEvent({name: 'Change Character', params: [0, 'toby']});
			dad.setPosition(dogShrine.x + 84, dogShrine.y + 92);
			
			fakeDad.setPosition(dad.x, dad.y);
			add(fakeDad);
			dad.visible = false;
			
			executeEvent({name: 'Change Character', params: [1, 'bf-ut']});
			
			// var fakeBf:Character = new Character(0, 0, 'bf-ut', true);
			fakeBf.setPosition(dogShrine.x + 156, dogShrine.y + 65);
			// playerStrums.characters.push(fakeBf);
			add(fakeBf);
			
			bf.alpha = 0;
			bf.setPosition(fakeBf.x, fakeBf.y);
			camGame.targetOffset.y = 0;
		
		}
	}
}

function stepHit() {
	toby.step();
}

var d:Bool = false;
var glowInterval:Int = 4;
function beatHit(curBeat:Int) {
	if (curBeat % glowInterval == 0 && canGlow) {
		grid.alpha = 0.3;
		grid.velocity.set(-20, 20);
		
		var g:FlxSprite = FlxGridOverlay.create(20, 20, 120, 120, true, r.color(), r.color());
		grid.pixels = g.pixels;
		FlxTween.tween(grid, {alpha: 0}, (Conductor.crochet / 1000) * glowInterval / 2, {ease: FlxEase.quadInOut});
		FlxTween.tween(grid.velocity, {x: 0, y: 0}, (Conductor.crochet / 1000) * glowInterval / 2, {ease: FlxEase.quadInOut});
	}
	
	d = !d;
	tubeGuy.animation.play((d ? 'danceLeft' : 'danceRight'), true);
	
	speaker.animation.play('i', true);
	
	if (curBeat % 2 == 0 && !stopIt) {
		jumpinUp = FlxTween.tween(toby, {y: toby.y - 20}, (Conductor.crochet / 1000) / 1.5, {ease: FlxEase.quadOut, onComplete: function() {
			FlxTween.tween(toby, {y: toby.y + 20}, (Conductor.crochet / 1000) / 1.5, {ease: FlxEase.quadIn, onComplete: function() {
				// if (stopIt) {
					// jumpinUp.cancel();
				// }
			}});
		}});
	}
}

//351, 704
var dogged:Bool = true;
var mimic:Bool = false;
function update() {
	if (dad.animation.curAnim.name != 'idle') {
		toby.face.animation.curAnim.curFrame = (dad.animation.curAnim.curFrame == 0 ? 1 : 0);
	}
	
	if (dogged) {
		dad.alpha = 0;
		dad.setPosition(toby.x, toby.y);
	}
	
	if (mimic) {
		fakeBf.playAnim(bf.animation.curAnim.name, true, null, false, bf.animation.curAnim.curFrame);
		fakeDad.playAnim(dad.animation.curAnim.name, true, null, false, dad.animation.curAnim.curFrame);
		dad.alpha = 0;
	}
	
	
	// trace(camFollow.x + ' ' + camFollow.y);
}

function postUpdate() {
// bf.setPosition(secret.x + 138, secret.y + 64);
		
		// dad.setPosition(secret.x + 86, secret.y + 90);
		// camGame.zoom = 0.5;
		// trace(dogShrine.x + ' ' + dogShrine.y);
		// camGame.zoom = 1;
}

//Stage functions.
// function stage(type:String) {
	// if (sta
// }

//Toby helper functions.
function setExpression(s:String) {
	toby.expression(s);
}

function setVariant(v:String) {
	toby.updateVariant(v);
}

function stand(y:Bool) {
	if (y) {
		toby.offset.y = 0;
		toby.face.offset.y = toby.offset.y;
	} else {
		toby.offset.y = -1;
		toby.face.offset.y = toby.offset.y;
	}
}

//Call functions.
function jumpDown() {
	if (!startSong) { return; }
	stand(false);
	FlxTween.tween(camHUD, {x: camHUD.x}, 2, {onComplete: function() {
		camHUD.visible = true;
		if (!PlayState.opponentMode) {
			camHUD.y = -FlxG.height * 1.5;
			FlxTween.tween(camHUD, {y: 0}, 1, {ease: FlxEase.bounceOut});
		}
	}});
	FlxTween.tween(speaker, {x: speaker.x}, 0.2, {onComplete: function() {
		stand(true);
		FlxG.sound.play(Paths.sound('jump'), 0.3);
		FlxTween.tween(toby, {y: toby.y - 20}, 0.5, {ease: FlxEase.expoOut, onComplete: function() {
			FlxTween.tween(toby, {y: toby.y + 200}, 0.5, {ease: FlxEase.expoIn, onComplete: function() {
				toby.cameras = [camGame];
				toby.setPosition(200, -400);
				FlxTween.tween(toby, {y: 120 + charY}, 1, {ease: FlxEase.quadIn, onComplete: function() {
					stand(false);
					var timer_1:FlxTimer = new FlxTimer().start(0.2, function() {
						stand(true);
						runninAround = FlxTween.tween(toby, {x: toby.x - 40}, 1, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
						executeEvent({name: 'Camera Movement', params: [0, true, 4, 'CLASSIC', 'In']});
						canGlow = true;
						FlxG.sound.play(Paths.sound('snd_impact'), 0.3);
					});
				}});
			}});
		}});
	}});
	
}

var time:Float = 1.0;
var skidSound:FlxSound = new FlxSound();
function tobyRun() {
	skidSound.loadEmbedded(Paths.sound('skid'), true);
	skidSound.volume = Options.volumeSFX;
	otherToby.cameras = [top];
	otherToby.setPosition(toby.x + 200, toby.y);
	FlxTween.tween(otherToby, {x: toby.x}, time, {ease: FlxEase.expoOut, onComplete: function() {
		otherToby.visible = false;
		toby.hide(true);
		startSong = true;
		startCountdown();
			
	}});
	FlxTween.tween(speaker, {y: speaker.y}, time / 4, {onComplete: function() {
		otherToby.animation.play('stop', true);
		skidSound.play();
		FlxTween.tween(speaker, {angle: speaker.angle}, 0.5, {onComplete: function() {
			skidSound.stop();
			otherToby.visible = false;
			toby.hide(true);
			
		}});
	}});
}

function tobyJumpAgain() {
	if (runninAround != null) {
		runninAround.cancel();
	}
	executeEvent({name: 'Camera Movement', params: [0, true, 4, 'CLASSIC', 'In']});
	FlxTween.tween(toby, {x: toby.x + 50}, 1, {ease: FlxEase.quadInOut, onComplete: function() {
		var timer:FlxTimer = new FlxTimer().start(0.2, function() {
			executeEvent({name: 'Camera Movement', params: [1, true, 4, 'CLASSIC', 'In']});
			// toby.stayingStill = true;
			stand(false);
			var timer_1:FlxTimer = new FlxTimer().start(0.4, function() {
				// FlxTween.tween(toby, {y: toby.y - 20}, 1, {ease: FlxEase.expoOut, onComplete: function() {
					// toby.velocity.y = -100;
					// toby.acceleration.y = 100;
				// }});
				FlxG.sound.play(Paths.sound('jump'), 0.3);
				toby.velocity.y = -100;
				toby.acceleration.y = 250;
				toby.stayingStill = false;
				stand(true);
				executeEvent({name: 'Camera Movement', params: [0, true, 4, 'CLASSIC', 'In']});
				var timer_2:FlxTimer = new FlxTimer().start(0.6, function() {
					FlxTween.tween(dither, {y: dither.y - 220}, 1, {ease: FlxEase.quadInOut, onComplete: function() {
						camGame.visible = true;
						dither.visible = false;
						secretStage();
					}});
					var timer_3:FlxTimer = new FlxTimer().start(0.8, function() {
						canGlow = false;
						camGame.visible = false;
					});
				});
			});
			// FlxTween.tween(toby, {x: toby.x - 100}, 1, {ease: FlxEase.quadInOut, onComplete: function() {
				toby.velocity.x = -100;
			// }});
		});
	}});
	// runninAround = FlxTween.tween()
}

function secretStage() {
	for (o in options) {
		o.visible = false;
	}

	dogged = false;
	executeEvent({name: 'Camera Position', params: [secret.getGraphicMidpoint().x, secret.getGraphicMidpoint().y - 400, false, 4, 'CLASSIC', 'In', false]});
	executeEvent({name: 'Camera Position', params: [secret.getGraphicMidpoint().x, secret.getGraphicMidpoint().y, true, 4, 'CLASSIC', 'In', false]});
	executeEvent({name: 'Camera Zoom', params: [false, 4, 'camGame', 4, 'linear', 'In', 'direct']});
	
	executeEvent({name: 'Change Character', params: [1, 'bf-ut' ]});
	bf.setPosition(secret.x + 138, secret.y + 64);
	
	dad.setPosition(secret.x + 86, secret.y + 90);
	executeEvent({name: 'Change Character', params: [0, 'toby']});
	dad.alpha = 0;
	
	tobyBall.visible = true;
	tobyBall.setPosition(dad.x + 14, dad.y - 500);
	FlxTween.tween(tobyBall, {x: dad.x + 14, y: dad.y + 17}, 1, {ease: FlxEase.linear, onComplete: function() {
		dad.alpha = 1;
		tobyBall.visible = false;
		FlxG.sound.play(Paths.sound('snd_impact'), 0.3);
		pile.animation.curAnim.curFrame = 1;
	}});
	
	camGame.targetOffset.set(0, 0);
}

function battle() {
	top.zoom = 3.3;
	battleTransition.alpha = 0.5;
	battleTransition.animation.play('i', true);
	battleTransition.animation.finishCallback = function(name:String) {
		if (name == 'i') {
			executeEvent({name: 'HScript Call', params: ['earthboundCreate', '']});
		}
	}
}

function battleStart() {
	executeEvent({name: 'Change Character', params: [0, 'toby-earthbound']});
	executeEvent({name: 'Camera Movement', params: [0, false, 4, 'CLASSIC', 'In']});
	battleCover.visible = battleBg.visible = true;
	// battleBg
	
	battleTransition.visible = false;
}

var middle = [412, 524, 636, 748];
var originalValuesPlayer = [];
var originalValuesOpponent = [];
function strumChange() {
	if (PlayState.SONG.meta.name == 'temperate') {
		FlxTween.tween(camHUD, {alpha: 1}, Conductor.crochet / 1000, {onComplete: function() {
			for (strumLine in strumLines.members) {
				if (strumLine.opponentSide) {
					for (note in strumLine.notes) {
						note.alpha = PlayState.opponentMode ? 1 : 0;
					}
				} else {
					if (PlayState.opponentMode) {
						for (note in strumLine.notes) {
							note.alpha = 0;
						}
					}
				}
				for (strum in strumLine) {
					if (strumLine.opponentSide) {
						strum.alpha = PlayState.opponentMode ? 1 : 0;
						originalValuesOpponent.push(strum.x);
					} else {
						strum.alpha = PlayState.opponentMode ? 0 : 1;
						originalValuesPlayer.push(strum.x);
					}
					FlxTween.tween(strum, {x: middle[strum.ID]}, Conductor.crochet / 1000, {ease: FlxEase.quadInOut});
				}
			}
			executeEvent({name: 'HScript Call', params: ['updateNotes', 'earthboundNotes']});
			executeEvent({name: 'HScript Call', params: ['setVisibility', 'false']});
			FlxTween.tween(camHUD, {alpha: 1}, Conductor.crochet / 1000, {onComplete: function() {

			}});
		}});
	} else {
			executeEvent({name: 'HScript Call', params: ['updateNotes', 'earthboundNotes']});
			executeEvent({name: 'HScript Call', params: ['setVisibility', 'false']});
			executeEvent({name: 'HScript Call', params: ['earthboundCreate', '']});
			
			for (strumLine in strumLines.members) {
				if (strumLine.opponentSide) {
					for (note in strumLine.notes) {
						note.alpha = PlayState.opponentMode ? 1 : 0;
					}
				} else {
					if (PlayState.opponentMode) {
						for (note in strumLine.notes) {
							note.alpha = 0;
						}
					}
				}
				for (strum in strumLine) {
					if (strumLine.opponentSide) {
						strum.alpha = PlayState.opponentMode ? 1 : 0;
						originalValuesOpponent.push(strum.x);
					} else {
						strum.alpha = PlayState.opponentMode ? 0 : 1;
						originalValuesPlayer.push(strum.x);
					}
					FlxTween.tween(strum, {x: middle[strum.ID]}, 1, {ease: FlxEase.quadInOut});
				}
			}
			
		mimic = false;
		dogged = false;
			
		executeEvent({name: 'Change Character', params: [0, 'toby-earthbound']});
		executeEvent({name: 'Camera Movement', params: [0, false, 4, 'CLASSIC', 'In']});
		dad.alpha = 1;
		// dad.visible = true;
	}
}

function backToNormal() {
	battleCover.visible = false;
	battleBg.visible = false;
	
	dogged = true;
	executeEvent({name: 'Change Character', params: [0, 'toby-dogforcamera']});
	executeEvent({name: 'Change Character', params: [1, 'bf-ut-left']});
	bf.cameras = [camGame];
	bf.setPosition(42, 74 + charY);

	executeEvent({name: 'HScript Call', params: ['returnNormal', '']});
	executeEvent({name: 'HScript Call', params: ['strumNormal', '']});
	executeEvent({name: 'HScript Call', params: ['updateNotes', 'default']});
	
	stopIt = false;
}

function strumNormal() {
	for (strumLine in strumLines.members) {
		if (strumLine.opponentSide) {
			for (note in strumLine.notes) {
				note.alpha = 1;
			}
			
			for (strum in strumLine) {
				FlxTween.tween(strum, {x: originalValuesOpponent[strum.ID], alpha: 1}, 0.5, {ease: FlxEase.quintInOut});
				strum.alpha = 0;
			}
		} else {
			for (strum in strumLine) {
				FlxTween.tween(strum, {x: originalValuesPlayer[strum.ID]}, 0.5, {ease: FlxEase.quintInOut});
			}
		}
	}
}

var fakeBf:Character = new Character(0, 0, 'bf-ut', true);
var fakeDad:Character = new Character(0, 0, 'toby', false);
function shrineSwitch() {
	battleCover.visible = false;
	battleBg.visible = false;
		tubeGuy.visible = speaker.visible = dogShrine.visible = true;
		executeEvent({name: 'Change Character', params: [0, 'toby']});
		dad.setPosition(dogShrine.x + 84, dogShrine.y + 92);
		
		fakeDad.setPosition(dad.x, dad.y);
		add(fakeDad);
		dad.alpha = 0;
		//145, 120
		
		executeEvent({name: 'Change Character', params: [1, 'bf-ut']});
		
		// var fakeBf:Character = new Character(0, 0, 'bf-ut', true);
		fakeBf.setPosition(dogShrine.x + 156, dogShrine.y + 65);
		// playerStrums.characters.push(fakeBf);
		add(fakeBf);
		
		bf.alpha = 0;
		bf.setPosition(fakeBf.x, fakeBf.y);
		camGame.targetOffset.y = 0;
		mimic = true;
		executeEvent({name: 'Camera Movement', params: [0, false, 4, 'CLASSIC', 'In']});
	
	// var refBf:Character
	
	executeEvent({name: 'HScript Call', params: ['returnNormal', '']});
	executeEvent({name: 'HScript Call', params: ['strumNormal', '']});
	executeEvent({name: 'HScript Call', params: ['updateNotes', 'default']});
}

var stopIt:Bool = true;
function shrineTransition() {
	toby.setPosition(200, 120 + charY);
	bf.setPosition(42, 74 + charY);

	executeEvent({name: 'Change Character', params: [1, 'bf-ut-left']});
	executeEvent({name: 'Change Character', params: [0, 'toby-dogforcamera']});
	dad.alpha = 0;
	// camGame.targetOffset.y = -20;
	
	tobyOn.setPosition(dogShrine.x - 100, dogShrine.y + 19);
	FlxTween.tween(tobyOn, {x: tobyOn.x + 80}, 0.4, {onComplete: function() {
		tobyOn.velocity.x = 170;
		for (t in [dogShrine, fakeBf, fakeDad, tubeGuy, speaker]) {
			t.moves = true;
			t.velocity.x = 170;
		}
	}});
	
	t = new FlxTimer().start(1, function() {
		for (o in options) {
			o.visible = true;
			o.alpha = 0;
			FlxTween.tween(o, {alpha: 1}, 0.4, {ease: FlxEase.quadInOut});
		}
		canGlow = true;
		glowInterval = 2;
	});
	//149, 124
	
	dogged = true;
	toby.cameras = [camGame];
	toby.velocity.set(0, 0);
	toby.acceleration.set(0, 0);
	toby.hide(true);
	add(tobyOn);
	runninAround = FlxTween.tween(toby, {x: toby.x - 40}, (Conductor.crochet / 1000) * 2, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
	remove(bf);
	insert(members.indexOf(dogShrine) - 1, bf);
	// jumpinUp = FlxTween.tween(toby, {y: toby.y + 50}, (Conductor.crochet / 1000) / 2, {ease: FlxEase.quadIn, onComplete: function() {
		// jumpinDown = FlxTween.tween(toby, {y: toby.y - 50}, (Conductor.crochet / 1000) / 2, {ease: FlxEase.quadIn, onComplete: function() {
			// jumpinUp.start();
		// }});
	// }});
	// dogShrine.visible = false;
	stopIt = false;
	jumpinUp = FlxTween.tween(toby, {y: toby.y - 20}, (Conductor.crochet / 1000) / 2, {ease: FlxEase.quadOut, onComplete: function() {
		FlxTween.tween(toby, {y: toby.y + 20}, (Conductor.crochet / 1000) / 2, {ease: FlxEase.quadIn, onComplete: function() {
			if (stopIt) {
				jumpinUp.cancel();
			}
		}});
	}});
	toby.updateVariant('hat');
}

function stopThat() {
	stopIt = true;
	// jumpinUp.cancel();
}

function stayStill() {
	if (runninAround != null) {
		runninAround.cancel();
	}
	FlxTween.tween(toby, {x: 200}, 1, {ease: FlxEase.quadInOut});
}

function stopSong() {
	inst.pitch = 0;
}

function setTargetOffset(x:Int, y:Int) {
	camGame.targetOffset.set(x, y);
}