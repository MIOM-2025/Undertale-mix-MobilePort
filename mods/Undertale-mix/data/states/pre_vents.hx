import overworld.Kris;
import overworld.DialogueBox;
import overworld.Interactable;
import BounceSmoke;
import flixel.tweens.FlxTweenType;

var gameCamera:FlxCamera = new FlxCamera();

var player:Kris;
var dbox:DialogueBox;
var ventOfDoom:FlxSprite;
var quittingSprite:FlxSprite = new FlxSprite();
var realVents:Array<FlxSprite> = [];

var collisionGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
var collisions = [
	[560, 280, 20, 160],
	[640, 340, 20, 160],
	[660, 340, 100, 20],
	[580, 260, 180, 20],
	[760, 280, 20, 60],
	[580, 440, 60, 20],
];
// var 0.03:Float = 0.03;
var interactables = [
	[580, 435, 60, 20, [[["*No reason to go back.", null, '0', 0.03],]]],
];
var timerTween:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);

function create() {
	setFramerate(30);

	FlxG.sound.playMusic(Paths.music('overworld/anothermedium'), 1, true);

	FlxG.cameras.add(gameCamera, false);
	gameCamera.bgColor = FlxColor.TRANSPARENT;
	gameCamera.antialiasing = false;
	gameCamera.zoom = 3;
	this.cameras = [gameCamera];
	


	var path:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/hotland/path'));
	path.screenCenter();
	
	var pathBg:FlxSprite = new FlxSprite(path.x + 60, path.y + 40).loadGraphic(Paths.image('stages/hotland/pathbg'));
	// pathBg.screenCenter();
	add(pathBg);
	
	for (i in 0...7) {
		var red:FlxSprite = new FlxSprite(100, 510).makeGraphic(FlxG.width, 20 * (7 - i), FlxColor.RED);
		red.setPosition(red.x, (red.y - red.height * 0.5));
		FlxTween.tween(red, {y: red.y - (19 * i)}, 2, {ease: FlxEase.quadInOut, startDelay: 1 - (0.03 * i), type: FlxTweenType.PINGPONG});
		red.alpha = 0.5 - (0.06 * i);
		add(red);
	}
	
	add(path);
	
	var ventSpot:FlxSprite = new FlxSprite(path.x + 120, path.y).loadGraphic(Paths.image('stages/hotland/ventoutl'));
	add(ventSpot);
	
	ventOfDoom = new FlxSprite(ventSpot.x + 20, ventSpot.y + 20).loadGraphic(Paths.image('stages/hotland/vent'), true, 20, 20);
	ventOfDoom.animation.add('v', [0,1,0,2], 8, true);
	ventOfDoom.animation.play('v', true);
	add(ventOfDoom);
	
	for (i in 0...5) {
		var ventSpotR:FlxSprite = new FlxSprite(ventSpot.x + (ventSpot.width * i + 1), ventSpot.y).loadGraphic(Paths.image('stages/hotland/ventoutl'));
		ventSpotR.visible = i % 2 == 0;
		
		var ventReally:FlxSprite = new FlxSprite(ventSpotR.x + 20, ventSpotR.y + 20).loadGraphic(Paths.image('stages/hotland/vent'), true, 20, 20);
		ventReally.animation.add('v', [0,1,0,2], 8, true);
		ventReally.animation.play('v', true);
		ventReally.visible = ventSpotR.visible;
		add(ventReally);
		ventReally.updateHitbox();
		
		var pillar/*chase 2*/:FlxSprite = new FlxSprite(ventSpotR.x + 120, ventSpotR.y + 40).loadGraphic(Paths.image('stages/hotland/rockp'));
		pillar.visible = ventSpotR.visible && i < 3;
		add(pillar);
		
		add(ventSpotR);
		
		if (ventSpotR.visible) {
			steamCreate(ventReally.x, ventReally.y);
			realVents.push(ventReally);
		}
		
		if (i == 4) {
			ventReally.flipX = true;
		}
	}
	
	var showPath:FlxSprite = new FlxSprite(path.x + 500, path.y).loadGraphic(Paths.image('stages/hotland/thing'));
	add(showPath);
	
	player = new Kris(path.x + 18, path.y + 144, this, collisionGroup);
	add(player);
	gameCamera.follow(player);
	
	add(collisionGroup);
	for (collision in collisions) {
		var collision:FlxSprite = new FlxSprite(collision[0], collision[1]).makeGraphic(collision[2], collision[3], FlxColor.BLUE);
		collision.immovable = true;
		collision.alpha = (Options.devMode ? 1 : 0);
		collisionGroup.add(collision);
	}
	
	dbox = new DialogueBox(0, 0, this);
	add(dbox);
	dbox.setupBox();
	
	gameCamera.setScrollBoundsRect(404, 240, 1000, 200);
	
	for (interactable in interactables) {
		var interact:Interactable = new Interactable(interactable[0], interactable[1], interactable[2], interactable[3], interactable[4], player, dbox);
		interact.alpha = (Options.devMode ? 0.5 : 0);
		add(interact);
	}
	
	// quittingSprite.setPosition(10, 10);
	quittingSprite.frames = Paths.getAsepriteAtlas('quitting');
	quittingSprite.animation.addByPrefix('q', 'quit', 24, true);
	quittingSprite.animation.play('q', true);
	quittingSprite.animation.timeScale = 0.4;
	quittingSprite.scale.set(3, 3);
	quittingSprite.alpha = 0;
	quittingSprite.updateHitbox();
	quittingSprite.setPosition(0, 2);
	// quittingSprite.scrollFactor.set(0, 0);
	quittingSprite.cameras = [FlxG.camera];
	add(quittingSprite);
	
	if (data != null && data == true) {
		printText('YOU CAME FROM LEVEL SELECT\nPRESS ANY BACK KEY TO RETURN');
	}
	// FlxG.cameras.remove(FlxG.camera);
	// FlxG.cameras.add(FlxG.camera);
	
	
	
	setFramerate(Options.framerate);
	
	// 0.03 = (0.03 * 30) * FlxG.elapsed;
	// trace(0.03);
}

var dir = [
	0 => 'left',
	1 => 'down',
	2 => 'right',
	3 => 'up',
];
var cutscene:Bool = false;
var time:Float = 0.6;
var spin:Bool = false;
var spinner:Int = 2;
var elap:Float = -0.1;
var once:Bool = false;
var lastBoxState:Bool = false;
var realFuckedUpSpinHell:Bool = false;
var timeQuit:Float = 0;
var ventedTimes:Int = 1;
// var 0.03:Float = 0.03;
function update(elapsed:Float) {
	if (spin) {
		elap += elapsed;
		if (elap > 0.11) {
			spinner += 1;
			elap = 0;
					if (!once) {
			FlxG.sound.play(Paths.sound('snd_vaporized'), 1);
			once = true;
		}
		}
		if (spinner > 3) {
			spinner = 0;
		}
		player.direction = dir.get(spinner);
	}
	
	if (FlxG.keys.pressed.ESCAPE) {
		if (data != null && data == true) {
			FlxG.switchState(new ModState('OverworldLevelPicker'));
		}
		timeQuit += elapsed;
		quittingSprite.alpha += elapsed * 4;
		if (timeQuit >= 0.5) {
			FlxG.switchState(new ModState('MixedFreeplayState'));
		}
	} else {
		timeQuit = 0;
		quittingSprite.alpha -= elapsed * 4;
	}
	

	if (FlxG.overlap(player.collisionBox, ventOfDoom) && !cutscene) {
		// dialogueBox.setupDialogue(heldDialogue[0]);
		// beingUsed = true;
		// trace('ouh');
		cutscene = true;
		FlxTween.tween(player.collisionBox, {x: ventOfDoom.x, y: ventOfDoom.y}, 0.1, {onComplete: function() {
			FlxG.sound.play(Paths.sound('snd_noise'), 1);
			spin = true;
			FlxTween.tween(player.collisionBox, {y: player.collisionBox.y - 45}, time / 2.6, {startDelay: 0.1, ease: FlxEase.quadOut, onComplete: function() {
				FlxTween.tween(player.collisionBox, {y: player.collisionBox.y + 45}, time / 2.6, {startDelay: 0.1, ease: FlxEase.quadIn, onComplete: function() {
					spin = false;
					once = false;
					ventedTimes++;
					FlxTween.tween(player.collisionBox, {y: player.collisionBox.y - 45}, time / 2.6, {startDelay: 0.1, ease: FlxEase.quadOut, onComplete: function() {
						FlxTween.tween(player.collisionBox, {y: player.collisionBox.y + 45}, time / 2.6, {startDelay: 0.1, ease: FlxEase.quadIn, onComplete: function() {
							spin = false;
							FlxG.sound.music.fadeOut(2, 0);
							FlxTween.tween(timerTween, {x: 1}, 2, {onComplete: function() { //Because flxtween is a more reliable timer than flxtimer
								lastBoxState = true;
								
								dbox.setupDialogue([['*(You look at the vent below.)', null, '0', 0.03], ['*(Well that doesn\'t look\nñright.)', null, '0', 0.03]]);
								// FlxTween.tween(timerTween, {x: 0}, 2, {onComplete: function() {
									// dbox.setupDialogue([['*...Well that doesn\'t look\nñright.', null, '0', 0.03]]);
								// }});
							}});
						}});
					}});
					spinner = 2;
					elap = -0.1;
					spin = true;
					FlxG.sound.play(Paths.sound('snd_noise'), 1);
					steamEffect(realVents[1].x - 8, realVents[1].y - 20);
					FlxTween.tween(player.collisionBox, {x: realVents[2].x}, time, {startDelay: 0.1});
				}});
			}});
			// trace(ventedTimes);
			steamEffect(realVents[0].x - 8, realVents[0].y - 20);
			FlxTween.tween(player.collisionBox, {x: realVents[1].x}, time, {startDelay: 0.1});
			
		}});
		player.lockMovement = true;
	}
	if (cutscene && lastBoxState != dbox.active) {
		trace('hello proceed dialgoued');
		cutsceneStuff();
		lastBoxState = dbox.active;
	}
}

var vented:Bool = false;
function vent() {
	FlxG.sound.play(Paths.sound('snd_noise'), 1);
	spinner = (vented ? 2 : 0);
	elap = -0.1;
	spin = true;
	FlxTween.tween(timerTween, {angle: 5}, 0.1, {onComplete: function() {
		FlxG.sound.play(Paths.sound('snd_vaporized'), 1);
	}});
	FlxTween.tween(player.collisionBox, {y: player.collisionBox.y - 45}, time / 2.6, {startDelay: 0.1, ease: FlxEase.quadOut, onComplete: function() {
		FlxTween.tween(player.collisionBox, {y: player.collisionBox.y + 45}, time / 2.6, {startDelay: 0.1, ease: FlxEase.quadIn, onComplete: function() {
			spin = false;
		}});
	}});
	FlxTween.tween(player.collisionBox, {x: player.collisionBox.x + (vented ? 120 : -120)}, time, {startDelay: 0.1});
	steamEffect(realVents[(vented ? 1 : 2)].x - 8, realVents[(vented ? 1 : 2)].y - 22, !vented);
	vented = !vented;
}

var t:Int = 0;
function cutsceneStuff(?c:Int) {
	if (t == 0) {
		FlxTween.tween(timerTween, {x: 1}, 0.1, {onComplete: function() {
			realFuckedUpSpinHell = true;
			FlxTween.tween(timerTween, {x: 0}, 7, {onComplete: function() {
				lastBoxState = true;
				dbox.setupDialogue([['*(You look around,\nñno help in sight.)', null, '0', 0.03], ['*(You ask yourself, is this it?)', null, '0', 0.03], ['*(You\'re stuck here, spinning.\nñAgain, again and again.)', null, '0', 0.03], ['*(You think of reaching for\nñyour phone to try and get\nñhelp, but fear losing balance.)', null, '0', 0.03], ['*(You wonder if Alphys is\nñdoing something to fix\nñthis.)', null, '0', 0.03]]);
			}});
			FlxTween.tween(timerTween, {y: 1}, 2, {type: FlxTweenType.PINGPONG, onComplete: function() {
				vent();
			}});
		}});
	} else if (t == 1) {
		FlxTween.tween(timerTween, {x: 1}, 2, {onComplete: function() {
			dbox.setupDialogue([['*(Waiting seems like the best\nñthing to do.)', null, '0', 0.03], ['*(What could you do\nñto pass the time...?)', null, '0', 0.03]]);
		}});
	} else if (t == 3) {
		FlxTween.tween(gameCamera, {zoom: 9}, 5, {ease: FlxEase.quadInOut});
		gameCamera.fade(FlxColor.BLACK, 5, false, function() {
			Options.freeplayLastSong = 'vent';
			Options.freeplayLastDifficulty = 'normal';
			Options.freeplayLastVariation = '';
			
			PlayState.loadSong('vent', 'normal', false, false);
			FlxG.switchState(new PlayState());
		});
	}
	t++;
}

function steamCreate(whereX:Int, whereY:Int) {
	for (i in 0...2) {
		// trace('teataet');
		var steam:BounceSmoke = new BounceSmoke(whereX, whereY, 0.5, i > 0 ? 0.2 : 0);
		add(steam);
	}
}

function steamEffect(whereX:Int, whereY:Int, ?rev:Bool = false) {
	for (i in 0...13) {
		var scale:Float = 0.46 + (0.07 * i);
		var smoke:FlxSprite = new FlxSprite((whereX) + (i + 6), (whereY - (i + 6)) - 1 * i).loadGraphic(Paths.image('stages/hotland/smoke'));
		smoke.scale.set(scale, scale);
		smoke.updateHitbox();
		smoke.offset.set((!rev ? -10 : 20) * (i * 0.3), 10 * (i * 0.2));
		smoke.offset.y -= 25;
		smoke.alpha = 1 - (0.1 + (0.07 * i));
		insert(members.indexOf(player) - 1, smoke);
		smoke.visible = false;
		smoke.angularVelocity = 500;
		FlxTween.tween(smoke, {y: smoke.y}, 0.02 * i, {startDelay: 0.01 * i, onComplete: function() {
			smoke.visible = true;
		}});
		FlxTween.tween(smoke, {x: smoke.x}, 0.65, {startDelay: 0.04 * i, onComplete: function() {
			smoke.destroy();
		}});
	}
	
}

function setFramerate(fps:Float) {
	FlxG.updateFramerate = fps;
	FlxG.drawFramerate = fps;
}

function destroy() {
	setFramerate(Options.framerate);
}