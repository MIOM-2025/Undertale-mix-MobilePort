import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTweenType;
import flixel.util.FlxAxes;
import flixel.math.FlxRandom;

var raindrops:Array<Dynamic> = [];
var drops:Array<Dynamic> = [];
var random:FlxRandom = new FlxRandom();
var tiles:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
var maxTiles = 200;
var tileNum = 1;
var tileRow = 0;
var monsterkid:FlxSprite = new FlxSprite(520, -127);
var playerClone:Character;
var opponentClone:Character;
var binary = new CustomShader('binaryGlitch');
function postCreate() {
	WATERFALL(436); WATERFALL(599); WATERFALL(772);
	
	// curCameraTarget = -1;
	// camFollow.setPosition(632, -83);
	
	camGame.targetOffset.y = -22;
	// camGame.pixelPerfectRender = true;
	
	var bfClone:Character = new Character(0, 0, bf.curCharacter, true);
	bfClone.setPosition(boyfriend.x, boyfriend.y + 32);
	bfClone.alpha = 0.5;
	bfClone.flipY = true;
	remove(bfClone);
	insert(members.indexOf(stage.stageSprites.get('puddlebg')) + 1, bfClone);
	player.characters.push(bfClone);
	
	// for (strum in strumLines) {
	
	// }
	
	var dadClone:Character = new Character(0, 0, 'squeezo');
	dadClone.setPosition(dad.x, dad.y + 30);
	dadClone.alpha = 0.5;
	dadClone.flipY = true;
	remove(dadClone);
	insert(members.indexOf(stage.stageSprites.get('puddlebg')) + 1, dadClone);
	cpu.characters.push(dadClone);
	
	monsterkid.frames = Paths.getSparrowAtlas('stages/waterfall/monsterkid');
	monsterkid.animation.addByPrefix('idle', 'idle0', 8, false);
	monsterkid.animation.addByPrefix('scared', 'agoner0001', 0);
	monsterkid.animation.addByPrefix('goner', 'agoner0000', 0);
	monsterkid.antialiasing = false;
	monsterkid.animation.play('idle', true);
	insert(members.indexOf(bgbottom) + 1, monsterkid);
	stage.stageSprites.set("monsterkid", monsterkid);
	
	insert(members.indexOf(monsterkid) - 1, tiles);
	if (FlxG.save.data.particlesEnabled == null) {
		FlxG.save.data.particlesEnabled = true;
	}
	if (FlxG.save.data.particlesEnabled) {
		for (i in 1...maxTiles) {
			tileNum++;
			if (tileNum > 7) {
				tileNum = 0;
				tileRow++;
			}
			TILE(340 + (20 * tileRow), -160 + (20 * tileNum));
		}
	}
	
	remove(monsterkid);
	insert(members.indexOf(bg) + 6, monsterkid);
	// player.cpu = true;
	
	if (FlxG.save.data.flashingLights == null) {
		FlxG.save.data.flashingLights = true;
	}
	if (FlxG.save.data.particlesEnabled == null) {
		FlxG.save.data.particlesEnabled = true;
	}
	if (FlxG.save.data.particlesEnabled && !Options.lowMemoryMode) {
		for (i in 0...100) {
			FlxTween.tween(monsterkid, {x: monsterkid.x}, 0.01, {startDelay: (i + 1) / 100, onComplete: function() {
				RAINDROP(random.int(406, 883), -190, random.int(-28, -84));
			}});
		}
	}
}

function postUpdate() {
	if (raindrops.length > 0) {
		for (drop in raindrops) {
			if (drop[0].y > drop[1]) {
				SPLASH(drop[0].x, drop[0].y, drop[0].ID);
				RAINDROP(random.int(406, 883), -190, random.int(-28, -84), drop[0]);
			}
		}
	}
}

var kidTimer:FlxTween;
var glitch:FlxTween;
function onEvent(event) {
	if (event.event.name == 'Stage Glitch') {
		if (!FlxG.save.data.flashingLights) {
			return;
		}
		var params = event.event.params;
		if (!params[0]) {
			monsterkid.shader = binary;
			kidTimer = FlxTween.tween(monsterkid, {x: monsterkid.x}, 0.01, {type: FlxTweenType.PINGPONG, onComplete: function() {
				if (random.bool(80)) {
					monsterkid.animation.play((random.bool(60) ? 'goner' : 'scared'));
				} else {
					monsterkid.animation.play('idle');
					monsterkid.animation.curAnim.curFrame = random.int(0, 3);
					binary.size = random.float(10, 22);
				}
			}});
			glitch = FlxTween.tween(monsterkid, {y: monsterkid.y}, 0.01, {type: FlxTweenType.PINGPONG, onComplete: function() {
				tiles.forEach(function(tile:FlxSprite) {
					tile.visible = true;
					tile.animation.play('tile', true, false, random.int(0, 9));
				});
			}});
		} else if (params[0]) {
			if (glitch != null && kidTimer != null) {
				glitch.cancel();
				kidTimer.cancel();
				tiles.forEach(function(tile:FlxSprite) {
					FlxTween.tween(tile, {x: tile.x}, random.float(0.01, 1.8), {onComplete: function() {
						tile.visible = false;
					}});
				});
			}
		}
	}
}

var whatToPlay:String = 'idle';
function beatHit(beat:Int) {
	if (beat % 2 == 0) {
		monsterkid.animation.play(whatToPlay);
	}
}

function setWhatToPlay(a:String) {
	whatToPlay = a;
	monsterkid.animation.play(a, true);
	monsterkid.shader = null;
}

function killKid() {
	monsterkid.visible = false;
}

/*
	Still leaks a little, guessing it's cause of the many array uses but it's fine.
	As long as it doesn't kill the game.
*/
var lay:Int = 3;
function RAINDROP(r_x:Int, r_y:Int, goal:Int, ?object:FlxSprite) {
	if (object != null) {
		object.setPosition(r_x, r_y);
		object.velocity.y = 0;
		remove(object);
		insert(members.indexOf(boyfriend) + (goal > -46 ? lay : -1), object);
	} else {
		var raindrop:FlxSprite = new FlxSprite();
		var dropId = raindrops.length + 1;
		raindrop.setPosition(r_x, r_y);
		raindrop.makeGraphic(1, 6, FlxColor.fromString('0xFFC0C0FF'));
		raindrop.acceleration.y = 200;
		raindrop.ID = dropId;
		insert(members.indexOf(boyfriend) + (goal > -46 ? lay : -1), raindrop);
		var drop:Array<Dynamic> = [raindrop, goal];
		raindrops.push(drop);
	}
}

function SPLASH(s_x:Int, s_y:Int, s_id:Int) {
	var rainSplashes:Array<Dynamic> = [];
	rainSplashes = drops[s_id];
	if (rainSplashes == null) { //If this raindrop doesn't have splashes, create them.
		var splashes:Array<Dynamic> = [];
		for (i in 0...2) {
			var drop:FlxSprite = new FlxSprite();
			drop.setPosition(s_x, s_y);
			drop.makeGraphic(1, 1, FlxColor.fromString('0xFFC0C0FF'));
			drop.velocity.x = random.int(-10, 10);
			drop.velocity.y = random.int(-20, -30);
			drop.acceleration.y = random.int(80, 100);
			FlxTween.tween(drop, {alpha: 0}, 0.8);
			splashes.push(drop);
			insert(members.indexOf(boyfriend) + (drop.y > -46 ? lay : -1), drop);
		}
		drops.push(splashes);
	} else { //If it does then just reuse them for the same drop instead of constantly making new ones.
		for (splashes in rainSplashes) {
			splashes.setPosition(s_x, s_y);
			splashes.velocity.set(0, 0); splashes.acceleration.set(0, 0);
			splashes.velocity.x = random.int(-10, 10);
			splashes.velocity.y = random.int(-20, -30);
			splashes.acceleration.y = random.int(80, 100);
			splashes.alpha = 1;
			FlxTween.tween(splashes, {alpha: 0}, 0.8);
			remove(splashes);
			insert(members.indexOf(boyfriend) + (splashes.y > -46 ? lay : -1), splashes);
		}
	}
}

function WATERFALL(w_x:Int) {
	var waterfall = new FlxBackdrop(Paths.image('stages/waterfall/waterfall'), FlxAxes.Y);
	waterfall.x = w_x;
	waterfall.antialiasing = false;
	waterfall.alpha = 0.35;
	waterfall.velocity.set(0, 100);
	waterfall.scale.set(2, 2);
	waterfall.scrollFactor.set(0.9, 1);
	add(waterfall);
}

var changed:Bool = false;
var lastChanged:Bool = false;
//ohh my fuckign god i do not want to place those events in the chart FUCK ITTTT
function onDadHit(e) {
	// if (e.noteType == 'Alt Anim Note') {
		// trace('hu0');
		// trace('aaw');
		// executeEvent({name: 'Change Icons', params: ['', (e.noteType == 'Alt Anim Note' ? 'squeezo' : 'frisk'), '', (e.noteType == 'Alt Anim Note' ? 'FFFF40' : '8F08F8')]});
		if (e.noteType == 'Alt Anim Note') {
			changed = true;
			// executeEvent({name: 'Stage Glitch', params: []});
		} else {
			if (changed) {
				changed = false;
			}
		}
		if (lastChanged != changed) {
			// trace('au');
			lastChanged = changed;
			executeEvent({name: 'Change Icons', params: ['', (e.noteType == 'Alt Anim Note' ? 'squeezo' : 'frisk'), '', (e.noteType == 'Alt Anim Note' ? 'FFFF40' : '8F08F8')]});
		}
	// }
}

function TILE(x, y) {
	var tile = new FlxSprite(x, y).loadGraphic(Paths.image('stages/waterfall/tiles'), true, 20, 20);
	tile.animation.add('tile', [0,1,2,3,4,5,6,7,8,9], 0, false);
	tile.antialiasing = false;
	tile.visible = false;
	tiles.add(tile);
}