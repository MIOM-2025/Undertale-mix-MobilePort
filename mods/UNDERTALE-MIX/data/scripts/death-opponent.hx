import funkin.editors.charter.Charter;

import UndertaleText;
import TypedBitmapText;
import StringTools;

var canPress:Bool = false;
var deathDialogue:TypedBitmapText;

var camera = new FlxCamera();
var exclude:String = '';

var soul:FlxSprite = new FlxSprite(PlayState.instance.dad.x + 44, PlayState.instance.dad.y + 50).loadGraphic(Paths.image('soul'), true, 20, 16);
function create(e) {
	e.cancel();
	
	FlxG.cameras.add(camera, false);
	camera.bgColor = FlxColor.TRANSPARENT;
	camera.alpha = 0;
	
	var songDeathTheme:String;
	if (PlayState.SONG.meta.customValues != null) {
		songDeathTheme = PlayState.SONG.meta.customValues.deathTheme;
	}
	if (songDeathTheme != null) {
		deathTheme = FlxG.sound.load(Paths.music('deaththemes/' + songDeathTheme), Options.volumeMusic, true);
	} else {
		deathTheme = FlxG.sound.load(Paths.music('deaththemes/basic'), Options.volumeMusic, true);
	}

	var gameOverText:FlxSprite = new FlxSprite(0, 60).loadGraphic(Paths.image('gameover/gameover'));
	gameOverText.antialiasing = false;
	gameOverText.cameras = [camera];
	gameOverText.scale.set(1.5, 1.5);
	gameOverText.updateHitbox();
	gameOverText.screenCenter(FlxAxes.X);
	add(gameOverText);
	
	var lines:Array<String> = [
		'You cannot give up/just yet...',
		'It cannot end now!',
		'Don\'t lose hope!',
		'You\'re going to/be alright!'
	];
	var determined:String = '<n>!/Stay determined...';
	var full:String = lines[FlxG.random.int(0, lines.length - 1)] + ':' + StringTools.replace(determined, '<n>', FlxG.save.data.playerName);
	
	var fontGetter:UndertaleText = new UndertaleText(0, 0, '', 'left', 0, 0);
	deathDialogue = new TypedBitmapText(398, 476, full, fontGetter.getFont('undertale-pixel'));
	deathDialogue.parentState = this;
	deathDialogue.cameras = [camera];
	deathDialogue.lineOffset = 1278;
	deathDialogue.lineSpacing = 58;
	deathDialogue.setTextFormat(3, 'FFFFFF', fontGetter.getAlignment('left'), FlxG.width);
	add(deathDialogue);
	
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
	
	soul.animation.add('soul', [0, 1], 0);
	soul.animation.play('soul', true);
	soul.antialiasing = false;
	soul.scale.set(0.4, 0.4);
	soul.color = FlxColor.fromString('#' + soulColor);
	soul.updateHitbox();
	add(soul);
	
	PlayState.instance.camFollow.setPosition(soul.getMidpoint().x, soul.getMidpoint().y);
	FlxG.sound.play(Paths.sound('break'), Options.volumeSFX, false, FlxG.sound.defaultSoundGroup, true, function() {
		soul.visible = false;
		var difference:Array<Dynamic> = [[-5, -5], [-5, 0], [-5, 5], [5, -5], [5, 0], [5, 5]];
		for (diff in difference) {
			soulShard(soul.x + diff[0], soul.y + diff[1]);
		}
		FlxG.sound.play(Paths.sound('shatter'), Options.volumeSFX);
		deathTheme.play();
		canPress = true;
		FlxTween.tween(camera, {alpha: 1}, 0.3, {ease: FlxEase.cubeIn, onComplete: function() {
			deathDialogue.startTyping(0.03, 'text-blip', true);
		}});
	});
	soul.animation.curAnim.curFrame = 1;
}

var dropped:Bool = false;
function update(elapsed:Float) {
	if (deathDialogue != null) {
		deathDialogue.textUpdate(elapsed);
	}

	if (canPress) {
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
}

function soulShard(s_x, s_y) {
	var shard:FlxSprite = new FlxSprite(s_x, s_y).loadGraphic(Paths.image('shard'), true, 7, 8);
	shard.antialiasing = false;
	shard.color = soul.color;
	shard.animation.add('anim', [0, 1, 2, 3], 8);
	shard.animation.play('anim', true);
	shard.scale.set(soul.scale.x, soul.scale.y);
	shard.velocity.set(FlxG.random.int(200, -250, exclude), FlxG.random.int(200, -250, exclude));
	shard.acceleration.y = 600;
	add(shard);
}

function endScreen(exiting:Bool) {
	canPress = false;
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