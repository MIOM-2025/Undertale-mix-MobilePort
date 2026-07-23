import UndertaleText;
import TypedBitmapText;

import flixel.math.FlxRandom;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTweenType;
import flixel.effects.FlxFlicker;
import funkin.editors.charter.Charter;
import funkin.menus.FreeplayState;
import funkin.menus.StoryMenuState;

//Tweens.
var floatTween:FlxTween;
var soulFade:FlxTween;

var deathTheme:FlxSound;
var options:Array<String> = ['Restart', 'Quit'];
var optionObjects:FlxTypedGroup<UndertaleText> = new FlxTypedGroup();
var selected:Int = 0;
var canPress:Bool = false;
var deathDialogue:TypedBitmapText;

var r = new FlxRandom();
var camera = new FlxCamera();
var exclude:String = '';

//Other sprites.
var soul:FlxSprite = new FlxSprite(PlayState.instance.boyfriend.x + 44, PlayState.instance.boyfriend.y + 50).loadGraphic(Paths.image('soul'), true, 20, 16);
var deathSprite:FlxSprite = new FlxSprite(PlayState.instance.boyfriend.x + 12, PlayState.instance.boyfriend.y + 16);
var spotlight:FlxSprite = new FlxSprite(deathSprite.x + 16, deathSprite.y - 145).loadGraphic(Paths.image('gameover/spotlight'));
var mic:FlxSprite = new FlxSprite(deathSprite.x + 22, deathSprite.y + 30).loadGraphic(Paths.image('gameover/mic'));
function create(e) {
	e.cancel();
	
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
	
	var songDeathTheme:String;
	if (PlayState.SONG.meta.customValues != null) {
		songDeathTheme = PlayState.SONG.meta.customValues.deathTheme;
	}
	if (songDeathTheme != null) {
		deathTheme = FlxG.sound.load(Paths.music('deaththemes/' + songDeathTheme), Options.volumeMusic, true);
	} else {
		deathTheme = FlxG.sound.load(Paths.music('deaththemes/basic'), Options.volumeMusic, true);
	}
	
	spotlight.antialiasing = false;
	spotlight.visible = false;
	add(spotlight);
	
	deathSprite.frames = Paths.getSparrowAtlas('gameover/bf_death');
	deathSprite.animation.addByPrefix('start', 'death0', 8, false);
	deathSprite.animation.addByPrefix('twitch', 'twitch0', 8, false);
	deathSprite.antialiasing = false;
	add(deathSprite);
	
	mic.antialiasing = false;
	add(mic);
	
	soul.animation.add('soul', [0, 1], 0);
	soul.animation.play('soul', true);
	soul.antialiasing = false;
	soul.scale.set(0.4, 0.4);
	soul.color = FlxColor.fromString('#' + soulColor);
	soul.updateHitbox();
	add(soul);
	
	PlayState.instance.camFollow.setPosition(soul.getMidpoint().x, soul.getMidpoint().y);
	FlxG.sound.play(Paths.sound('break'), Options.volumeSFX);
	FlxG.sound.play(Paths.sound('death'), Options.volumeSFX);
	deathSprite.animation.play('start', true);
	soul.animation.curAnim.curFrame = 1;
	
	timer = new FlxTimer().start(1, function() {
		mic.angularVelocity = 250;
		mic.acceleration.y = 500;
	});
	
	FlxG.cameras.add(camera, false);
	camera.bgColor = FlxColor.TRANSPARENT;
	camera.alpha = 0;
	
	var gameOverText:FlxSprite = new FlxSprite(0, 60).loadGraphic(Paths.image('gameover/gameover'));
	gameOverText.antialiasing = false;
	gameOverText.cameras = [camera];
	gameOverText.scale.set(1.5, 1.5);
	gameOverText.updateHitbox();
	gameOverText.screenCenter(FlxAxes.X);
	add(gameOverText);
	
	var fontGetter:UndertaleText = new UndertaleText(0, 0, '', 'left', 0, 0);
	deathDialogue = new TypedBitmapText(300, 393, getDialogue(PlayState.SONG.meta.name), fontGetter.getFont('undertale-pixel'));
	deathDialogue.parentState = this;
	deathDialogue.cameras = [camera];
	deathDialogue.lineOffset = 1278;
	deathDialogue.lineSpacing = 58;
	deathDialogue.setTextFormat(3, 'FFFFFF', fontGetter.getAlignment('left'), FlxG.width);
	add(deathDialogue);
	
	//For shards.
	for (i in r.int(-50, -100)...r.int(50, 100)) {
		exclude = exclude + ',' + i;
	}
	
	PlayState.instance.camGame.targetOffset.set(0, 0);
	FlxTween.tween(PlayState.instance.camGame, {zoom: 4}, 1, {onComplete: function() {
		PlayState.instance.defaultCamZoom = 4;
	}});
}

var dropped:Bool = false;
function update(elapsed:Float) {
	if (deathDialogue != null) {
		deathDialogue.textUpdate(elapsed);
	}

	if (mic.y > deathSprite.y + 44 && !dropped) {
		micDrop();
		dropped = true;
	}
	
	if (canPress) {
		// --- 新增：点击屏幕触发与 ACCEPT 相同的行为 ---
		if (FlxG.mouse.justPressed) {
			if (deathDialogue.active) {
				deathDialogue.advanceDialogue();
			} else {
				endScreen(false);
			}
		}
		// ------------------------------------------------
		
		if (controls.ACCEPT) {
			if (deathDialogue.active) {
				deathDialogue.advanceDialogue();
			} else {
				endScreen(false);
			}
		} else if (controls.BACK) {
			endScreen(true);
		}
	}
	
	if (dropped) {
		if (r.bool(1)) {
			deathSprite.animation.play('twitch', true);
		}
	}
}

function micDrop() {
	mic.acceleration.y = 0;
	mic.velocity.y = 0;
	mic.angularVelocity = 0;
	if (mic.angle != 90) { mic.angle = 90; }
	FlxG.sound.play(Paths.sound('micdrop'), Options.volumeSFX);
	FlxG.sound.play(Paths.sound('shatter'), Options.volumeSFX);
	soul.visible = false;
	var difference:Array<Dynamic> = [[-5, -5], [-5, 0], [-5, 5], [5, -5], [5, 0], [5, 5]];
	for (diff in difference) {
		soulShard(soul.x + diff[0], soul.y + diff[1]);
	}
	FlxFlicker.flicker(spotlight, 0.3, 0.05, true, false);
	var textBlip:String = 'text-blip';
	if (Assets.exists(Paths.sound(PlayState.SONG.meta.name + '-blip'))) {
		textBlip = PlayState.SONG.meta.name + '-blip';
	}
	timer = new FlxTimer().start(1, function() {
		FlxTween.tween(PlayState.instance.camFollow, {x: soul.getMidpoint().x, y: soul.getMidpoint().y - 65}, 1, {ease: FlxEase.quadInOut, onComplete: function() {
			deathTheme.play();
			soul.visible = true;
			soul.y -= 2;
			soul.alpha = 0;
			floatTween = FlxTween.tween(soul, {y: soul.y + 3}, 2, {ease:FlxEase.cubeInOut, type: FlxTweenType.PINGPONG});
			soulFade = FlxTween.tween(soul, {alpha: 0.5}, 0.3, {ease: FlxEase.cubeIn});
			canPress = true;
			FlxTween.tween(camera, {alpha: 1}, 0.3, {ease: FlxEase.cubeIn, onComplete: function() {
				deathDialogue.startTyping(0.03, textBlip, true);
			}});
		}});
	});
}

var noLinesError:String = "THERE'S NO LINES FOR/THIS SONG THIS/SHOULDN'T APPEAR:PLEASE TELL ME,/XPSXEXP TO FIX THIS!";
function getDialogue(song:String) {
	var path:String = 'gameoverlines/' + song;
	var content:String = (Assets.exists(Paths.txt(path)) ? Assets.getText(Paths.txt(path)) : noLinesError);
	var lines:Array<String> = content.split('\n');
	// trace(lines);
	if (lines.length > 0) {
		return lines[r.int(0, lines.length - 1)];
	} else {
		return content;
	}
}

function soulShard(s_x, s_y) {
	var shard:FlxSprite = new FlxSprite(s_x, s_y).loadGraphic(Paths.image('shard'), true, 7, 8);
	shard.antialiasing = false;
	shard.color = soul.color;
	shard.animation.add('anim', [0, 1, 2, 3], 8);
	shard.animation.play('anim', true);
	shard.scale.set(soul.scale.x, soul.scale.y);
	shard.velocity.set(r.int(200, -250, exclude), r.int(200, -250, exclude));
	shard.acceleration.y = 600;
	add(shard);
}

function endScreen(exiting:Bool) {
	canPress = false;
	if (floatTween != null) { floatTween.cancel(); }
	if (soulFade != null) { soulFade.cancel(); }
	if (!exiting) {
		soul.alpha = 1;
		soul.animation.curAnim.curFrame = 0;
		FlxG.sound.play(Paths.sound('break'), Options.volumeSFX);
	} else {
		FlxTween.tween(soul, {alpha: 0}, 1, {ease: FlxEase.cubeOut});
	}
	deathTheme.fadeOut(0.5, 0);
	camera.fade(FlxColor.BLACK, 1, false, function() {
		if (!exiting) {
			FlxG.switchState(new PlayState());
		} else {
			if (PlayState.chartingMode && Charter.undos.unsaved) {
				game.saveWarn(false);
			} else {
				if (Charter.instance != null) Charter.instance.__clearStatics();

				if (FlxG.sound.music != null) FlxG.sound.music.stop();
				FlxG.sound.music = null;

				FlxG.switchState(PlayState.isStoryMode ? new StoryMenuState() : new FreeplayState());
			}
		}
	});
}