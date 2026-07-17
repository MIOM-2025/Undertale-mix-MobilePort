import overworld.Kris;
import overworld.DialogueBox;
import overworld.Interactable;

var gameCamera:FlxCamera = new FlxCamera();

var quittingSprite:FlxSprite = new FlxSprite();
var collisionGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
var dbox:DialogueBox;
var player:Kris;
var collisions = [
	[300, 290, 20, 100],
	[320, 270, 40, 20],
	[360, 250, 180, 20],
	[540, 270, 40, 20],
	[340, 410, 20, 20],
	[580, 290, 20, 80],
	[600, 350, 360, 20],
	[320, 390, 20, 20],
	[360, 430, 20, 20],
	[520, 430, 20, 20],
	[540, 410, 420, 20],
	[380, 450, 140, 20],
	// [],
];

var interactables = [
	[900, 356, 40, 20, [[["*(What are you looking for?)", null, '0', 0.03],]]],
];

var fakePath:FlxSprite = new FlxSprite().makeGraphic(FlxG.width + 50, 40, 0xFF3A3948);
var top:FlxSprite = new FlxSprite(0, 360).makeGraphic(40, 20, FlxColor.BLUE);
var bottom:FlxSprite = new FlxSprite(0, top.y + 40).makeGraphic(40, 20, FlxColor.BLUE);
var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('overworld/flowerbed'));
var frisk:FlxSprite = new FlxSprite().loadGraphic(Paths.image('overworld/frisk-f'), true, 20, 30);
var thing:Interactable;
function create() {
	// setFramerate(30);
	
	FlxG.sound.playMusic(Paths.music('overworld/forestcarnival'), 0, true);

	if (data != null && data == true) {
		printText('YOU CAME FROM LEVEL SELECT\nPRESS ANY BACK KEY TO RETURN');
	}
	
	FlxG.cameras.add(gameCamera, false);
	gameCamera.bgColor = FlxColor.TRANSPARENT;
	gameCamera.antialiasing = false;
	gameCamera.zoom = 3;
	this.cameras = [gameCamera];
	
	dbox = new DialogueBox(0, 0, this);
	add(dbox);
	dbox.setupBox();
	
	
	bg.screenCenter();
	bg.setPosition(bg.x + 105, bg.y);
	add(bg);
	
	fakePath.setPosition(bg.x, bg.y + 100);
	fakePath.visible = false;
	add(fakePath);
	
	player = new Kris(bg.x + 120, bg.y + 70, this, collisionGroup);
	player.bfSkin();
	add(player);
	gameCamera.follow(player);
	
	add(collisionGroup);
	for (collision in collisions) {
		var collision:FlxSprite = new FlxSprite(collision[0], collision[1]).makeGraphic(collision[2], collision[3], FlxColor.BLUE);
		collision.immovable = true;
		collision.alpha = (Options.devMode ? 1 : 0);
		collision.alpha = 0;
		collisionGroup.add(collision);
	}
	
	for (interactable in interactables) {
		var interact:Interactable = new Interactable(interactable[0], interactable[1], interactable[2], interactable[3], interactable[4], player, dbox);
		interact.alpha = (Options.devMode ? 0.5 : 0);
		interact.alpha = 0;
		// add(interact);
		thing = interact;
	}

	// top.immovable = true;
	// collisionGroup.add(top);
	
	// bottom.immovable = true;
	// collisionGroup.add(bottom);
	frisk.setPosition(bg.x + 600, bg.y + 91);
	frisk.animation.add('left', [3, 4, 3, 4], 0, false);
	frisk.animation.add('down', [0, 1, 0, 2], 0, false);
	frisk.animation.add('up', [7, 8, 7, 9], 0, false);
	frisk.animation.add('right', [5, 6, 5, 6], 0, false);
	frisk.animation.play('right', true, false, 0);
	add(frisk);
	// bg.loadGraphic(Paths.image('overworld/flowerbed-f'));
	
	quittingSprite.frames = Paths.getAsepriteAtlas('quitting');
	quittingSprite.animation.addByPrefix('q', 'quit', 24, true);
	quittingSprite.animation.play('q', true);
	quittingSprite.animation.timeScale = 0.4;
	quittingSprite.scale.set(3, 3);
	quittingSprite.alpha = 0;
	quittingSprite.updateHitbox();
	quittingSprite.setPosition(0, 2);
	quittingSprite.cameras = [FlxG.camera];
	add(quittingSprite);
}

var inf:Bool = false;
var friskMove:Bool = false;
var maxDistance:Int = 2500;
var pixelsAdvanced:Int = 2500;
var pointOfNoReturn:Bool = false;
var end:Bool = false;
var nope:Bool = false;
var lol:Bool = false;
var lastBox:Bool = false;
var THISCUTSCENECANACTUALLYHAPPEN:Bool = false;
function update(elapsed:Float) {
	if (FlxG.keys.pressed.ESCAPE) {
		if (data != null && data == true) {
			FlxG.switchState(new ModState('OverworldLevelPicker'));
		}
		timeQuit += (0.9 * elapsed);
		quittingSprite.alpha += (0.9 * elapsed) * 4;
		if (timeQuit >= 0.5) {
			FlxG.switchState(new ModState('MixedFreeplayState'));
		}
	} else {
		timeQuit = 0;
		quittingSprite.alpha -= (0.9 * elapsed) * 4;
	}
	
	// trace('x: ' + player.collisionBox.x + ' y: ' + player.collisionBox.y);
	
	if (nope && !lol && player.x < 564 && THISCUTSCENECANACTUALLYHAPPEN) {
		player.lockMovement = true;
		var alert:FlxSprite = new FlxSprite(player.x + 5, player.y - 16).loadGraphic(Paths.image('overworld/alert'));
		FlxG.sound.play(Paths.sound('snd_b'), Options.volumeSFX);
		FlxG.sound.music.volume = 0;
		FlxTween.tween(alert, {alpha: 0}, 0.1, {startDelay: 0.4, onComplete: function() {
			player.cutsceneFrameTimer = 2;
			FlxTween.tween(player.collisionBox, {x: 488, y: 345}, 3, {startDelay: 1, onComplete: function() {
				FlxTween.tween(fakePath, {angle: 5}, 2, {onComplete: function() {
					gameCamera.visible = false;
					dbox.textSound = false;
					dbox.visible = false;
					lastBox = true;
					FlxG.sound.play(Paths.sound('snd_oddtalk1'), Options.volumeSFX);
					dbox.setupDialogue([
						['*Welcome back.', null, '0', 0.03],
					]);
					// dbox.advanceDialogue();
				}});
				player.cutsceneFrameTimer = 0;
			}});
		}});
		add(alert);
		
		lol = true;
	}
	
	if (lastBox != dbox.active) {
		trace('changed!!!');
		if (lol) {
			FlxTween.tween(frisk, {x: 1020}, 2, {onComplete: function() {
				Options.freeplayLastSong = 'true-reset';
				Options.freeplayLastDifficulty = 'normal';
				Options.freeplayLastVariation = '';
				
				PlayState.loadSong('true-reset', 'normal', false, false);
				FlxG.switchState(new PlayState());
			}});
		}
		lastBox = dbox.active;
	}
	
	if (nope) {
		return;
	}

	if (!friskMove && player.x > 700) {
		frisk.velocity.set(50, 0);
		frisk.acceleration.set(50, 0);
		frisk.animation.play('right', true);
		friskMove = true;
	}
	// if (frisk.velocity.x > 
	
	if (!end && pixelsAdvanced > 8000) {
		FlxG.sound.music.fadeIn(4, 1, 0);
		gameCamera.fade(FlxColor.BLACK, 2, false, function() {
			player.collisionBox.setPosition(925, 376);
			FlxTween.tween(fakePath, {alpha: 0}, 4, {onComplete: function() {
				bg.loadGraphic(Paths.image('overworld/flowerbed-f'));
				bg.visible = true;
				player.collisionBox.setPosition(925, 376);
				FlxG.sound.playMusic(Paths.music('mus_f_wind2'), Options.volumeMusic, true);
				FlxG.sound.music.volume = Options.volumeMusic;
				FlxG.sound.music.pitch = 1;
				gameCamera.fade(FlxColor.BLACK, 0.01, true, function() {
					THISCUTSCENECANACTUALLYHAPPEN = true;
				}, true);
				gameCamera.zoom = 3;
				gameCamera.angle = 0;
				
				
				var block:FlxSprite = new FlxSprite(960, 370).makeGraphic(20, 40, FlxColor.BLUE);
				// add(block);
				block.immovable = true;
				block.alpha = 0;
				collisionGroup.add(block);
				
				frisk.velocity.set(0, 0);
				frisk.setPosition(bg.x + 75, bg.y + 58);
				frisk.animation.play('left', true, false, 0);
				
				add(thing);
				
				add(collisionGroup);
			}});
			nope = true;
		}, true);
		
		end = true;
	}
	if (end) {
		pixelsAdvanced += 9000 * elapsed;
	}
	
	FlxG.sound.music.pitch = ((FlxG.sound.music.volume / Options.volumeMusic) * 1) / 2;
	
	if (!pointOfNoReturn && player.x > 2000) {
		pointOfNoReturn = true;

		// trace( 2.5 + (player.x / maxDistance) * 1);
	}

	if (pointOfNoReturn) {
		gameCamera.angle = -(((pixelsAdvanced / maxDistance) * 180) - 135) / 26;
		gameCamera.zoom = 2.18 + (pixelsAdvanced / maxDistance) * 1;
		var diff:Float = player.collisionBox.x - player.collisionBox.last.x;
		if (diff < 0) {
			diff *= -1;
		}
		pixelsAdvanced += diff;
		// trace(pixelsAdvanced);
	}

	if (!inf && player.x > 941) {
		fakePath.visible = true;
		bg.visible = false;
		
		// for (c in collisionGroup) {
			// c.remove();
		// }
		limitPos = true;
		FlxG.sound.music.fadeIn(4, 0, Options.volumeMusic);
		FlxG.sound.music.pitch = 0.5;
		remove(collisionGroup);
		inf = true;
	}

	// trace(pixelsAdvanced);
	// printText(frisk.velocity.x);
}

var bottomLimit:Int = 397;
var topLimit:Int = 370;
var limitPos:Bool = false;
var walkFrame:Int = 0;
function postUpdate() {
	if (nope) {
		return;
	}

	fakePath.x = player.x - 230;
	if (frisk.velocity.x > 200) {
		frisk.acceleration.set(0, 0);
	}
	
	if (limitPos) {
		if (player.collisionBox.y > bottomLimit) {
			player.collisionBox.y = bottomLimit;
			player.y = bottomLimit - 15;
		}
		if (player.collisionBox.y < topLimit) {
			player.collisionBox.y = topLimit;
			player.y = topLimit - 15;
		}
	}
	
	if (getPixelDifference() > 0) {
		frameTimer += getPixelDifference() / 10;
	} else {
		frameTimer = 0;
	}
	if (frameTimer > 3) {
		frameTimer = 0;
		walkFrame++;
		if (walkFrame > 3) {
			walkFrame = 0;
		}
	}
	frisk.animation.play('right', true, false, walkFrame);
	// if (player.y
	// top.x = player.x;
	// bottom.x = player.x;
}

function setFramerate(fps:Float) {
	FlxG.updateFramerate = fps;
	FlxG.drawFramerate = fps;
}

function destroy() {
	setFramerate(Options.framerate);
}

function getPixelDifference() {
	var xDiff:Float = frisk.last.x - frisk.x;
	var yDiff:Float = frisk.last.y - frisk.y;
	if (xDiff != 0) {
		if (xDiff < 0) {
			return xDiff * -1;
		} else {
			return xDiff;
		} 
	} else if (yDiff != 0) {
		if (yDiff < 0) {
			return yDiff * -1;
		} else {
			return yDiff;
		} 
	}
}