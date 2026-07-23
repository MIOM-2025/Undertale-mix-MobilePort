import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.backend.utils.DiscordUtil;
import flixel.tweens.FlxEase;
import flixel.math.FlxRandom;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTweenType;
import flixel.util.FlxStringUtil;
import funkin.game.PlayState;
import StringTools;

var undertaleFont:FlxBitmapFont;

// Stuff.
var random:FlxRandom = new FlxRandom();
var deathCamera = new FlxCamera();
var game = PlayState.instance;
//Sprites.
var soul:FlxSprite;
var deathSprite:FlxSprite;
var mic:FlxSprite;
var spotlight:FlxSprite;
var gameover:FlxSprite;
var deathQuote:FlxBitmapText;
// Other menu stuff.
var theme:FlxSound;
var options = ['Restart', 'Quit'];
var optionTexts:FlxTypedSpriteGroup<FlxBitmapText> = new FlxTypedSpriteGroup();
var selected = 0;
//Death line stuff.
var text = '';
var texts = [];
var splitText = [];
var curDialogue = 0;
var curLetter = 0;
var pickedText = 0;
var textLines:Array<Dynamic> = [];
var addLetter:FlxTimer;
var themeExists = false;
//Soul color stuff
var colors = [
	'determination' => 'FF0000',
	'patience' => '42FCFF',
	'bravery' => 'FCA600',
	'integrity' => '003CFF',
	'perseverance' => 'D535D9',
	'kindness' => '00C000',
	'justice' => 'FFFF00'
];

function create(event) {
	event.cancel();

	//This doesn't account for any other characters than BF. Hopefully there aren't that many.
	undertaleFont = getFont('ut-text', 'AaBbCcDdEeFf' + 'GgHhIiJjKkLl' + 'MmNnOoPpQqRr' + 'SsTtUuVvWwXx' + 'YyZz01234567' + '89!#%&$*"/@?' + '+>}{<_~=-])[' + "(,.|'^;: ");
	
	var pickedColor = FlxG.save.data.soulColor;
	if (pickedColor == null) {
		pickedColor = 'determination';
	}
	
	var themePath = 'deaththeme-' + game.SONG.meta.name;
	themeExists = Assets.exists(Paths.music(themePath));
	if (themeExists) {
		theme = FlxG.sound.load(Paths.music(themePath), 0.5, true);
	} else {
		theme = FlxG.sound.load(Paths.music('deaththeme'), 0.5, true);
	}
	
	soul = new FlxSprite(game.boyfriend.x + 44, game.boyfriend.y + 50).loadGraphic(Paths.image('soul'), true, 20, 16);
	soul.animation.add('soul', [0, 1], 0);
	soul.animation.play('soul');
	
	deathSprite = new FlxSprite(game.boyfriend.x + 12, game.boyfriend.y + 16);
	deathSprite.frames = Paths.getSparrowAtlas('gameover/bf_death');
	deathSprite.animation.addByPrefix('start', 'death0', 8, false);
	deathSprite.animation.addByPrefix('twitch', 'twitch0', 8, false);
	deathSprite.antialiasing = false;
	
	spotlight = new FlxSprite(deathSprite.x + 16, deathSprite.y - 145).loadGraphic(Paths.image('gameover/spotlight'));
	spotlight.antialiasing = false;
	spotlight.visible = false;
	add(spotlight);
	
	mic = new FlxSprite(deathSprite.x + 22, deathSprite.y + 30).loadGraphic(Paths.image('gameover/mic'));
	mic.antialiasing = false;
	
	soul.antialiasing = false;
	soul.scale.set(0.4, 0.4);
	soul.color = FlxColor.fromString('#' + colors[pickedColor]);
	soul.updateHitbox();
	
	add(deathSprite);
	add(mic);
	add(soul);
	// add(textLines);
	// game.camGame.pixelPerfectRender = false;
	
	game.camFollow.x = soul.getMidpoint().x;
	game.camFollow.y = soul.getMidpoint().y;
	FlxG.sound.play(Paths.sound('break'), 1);
	FlxG.sound.play(Paths.sound('death'), 1);
	soul.animation.curAnim.curFrame = 1;
	deathSprite.animation.play('start', true);
	
	timer = new FlxTimer().start(1, function() {
		mic.angularVelocity = 250;
		mic.acceleration.y = 500;
	});
	
	FlxG.cameras.add(deathCamera, false);
	deathCamera.bgColor = FlxColor.TRANSPARENT;
	deathCamera.alpha = 0;
	// deathCamera.zoom = 0.95;
	
	gameover = new FlxSprite(0, 60).loadGraphic(Paths.image('gameover/gameover'));
	gameover.antialiasing = false;
	gameover.cameras = [deathCamera];
	gameover.scale.set(1.5, 1.5);
	gameover.updateHitbox();
	gameover.screenCenter(FlxAxes.X);
	// gameover.y -= 150;
	add(gameover);
	
	var index = 0;
	for (option in options) {
		var optionText = bitmapText((500 * index), 0, option, FlxTextAlign.CENTER, 'FFFFFF', FlxG.width, 2, undertaleFont);
		optionText.screenCenter(FlxAxes.Y);
		// optionText.y += 100;
		optionText.ID = index;
		optionTexts.add(optionText);
		index++;
	}
	
	optionTexts.cameras = [deathCamera];
	optionTexts.screenCenter();
	optionTexts.y = 280;
	// add(optionTexts);
	
	texts = getLines(game.SONG.meta.name);
	// pickedText = random.int(0, texts.length - 1);
	pickedText = random.int(0, texts.length - 1);
	
	// deathQuote = bitmapText(900, 0, text, FlxTextAlign.LEFT, 'FFFFFF', FlxG.width, 2,  undertaleFont);
	// deathQuote.autoSize = false;
	// deathQuote.cameras = [deathCamera];
	// deathQuote.screenCenter(FlxAxes.Y);
	// deathQuote.y += 34;
	// add(deathQuote);
	deathCamera.zoom = 1;
	// trace(deathQuote.y);
	// deathQuote.numSpacesInTab = 0;
	// textLines.add(deathQuote);
	
	for (i in 0...3) {
		line = bitmapText(900, 393 + (52 * i), '', FlxTextAlign.LEFT, 'FFFFFF', FlxG.width, 2, undertaleFont);
		line.autoSize = false;
		line.cameras = [deathCamera];
		add(line);
		textLines.push(line);
	}
	textLines.cameras = [deathCamera];
}

var dropped = false;
var lines = 0;
var canPress = false;
var exitingScreen = false;
var floatTween:FlxTween;
var soulFade:FlxTween;
function update(elapsed:Float) {
	if (mic.y > (deathSprite.y) + 44 && !dropped) {
		mic.acceleration.y = 0;
		mic.velocity.y = 0;
		mic.angularVelocity = 0;
		mic.angle = 90;
		FlxG.sound.play(Paths.sound('micdrop'), 1);
		FlxG.sound.play(Paths.sound('shatter'), 1);
		SHARD(soul.x - 5, soul.y - 5);
		SHARD(soul.x - 5, soul.y);
		SHARD(soul.x - 5, soul.y + 5);
		SHARD(soul.x + 5, soul.y - 5);
		SHARD(soul.x + 5, soul.y);
		SHARD(soul.x + 5, soul.y + 5);
		FlxFlicker.flicker(spotlight, 0.3, 0.05, true, false);
		timer = new FlxTimer().start(1, function() {
			// game.camFollow.y = soul.getMidpoint().y - 65;
			FlxTween.tween(game.camFollow, {x: soul.getMidpoint().x, y: soul.getMidpoint().y - 65}, 1, {ease: FlxEase.quadInOut, onComplete: function() {
				theme.play();
				soul.visible = true;
				soul.y -= 2;
				soul.alpha = 0;
				floatTween = FlxTween.tween(soul, {y: soul.y + 3}, 2, {ease: FlxEase.cubeInOut, type: FlxTweenType.PINGPONG});
				soulFade = FlxTween.tween(soul, {alpha: 0.5}, 0.3, {ease: FlxEase.cubeIn});
				canPress = true;
				FlxTween.tween(deathCamera, {alpha: 1}, 0.3, {ease: FlxEase.cubeIn, onComplete: function() {
					startDialogue();
				}});
			}});
		});
		soul.visible = false;
		dropped = true;
	}
	
	if (dropped) {
		if (random.bool(1)) {
			deathSprite.animation.play('twitch', true);
		}
	}
	
	if (canPress) {
		if (controls.ACCEPT) {
			END(false);
		} else if (controls.BACK) {
			END(true);
		}
	}
	
	// if (controls.ACCEPT && !exiting) {
		// var option = options[selected];
		// exiting = true;
		// FlxG.sound.play(Paths.sound('select'));
		// if (option == 'Restart') {
		// } else if (option == 'Exit') {
		// }
	
	// deathQuote.y = 393 + (5 * lines);
}

function SHARD(s_x, s_y) {
	var shard = new FlxSprite(s_x, s_y).loadGraphic(Paths.image('shard'), true, 7, 8);
	shard.antialiasing = false;
	shard.color = soul.color;
	shard.animation.add('anim', [0, 1, 2, 3], 8);
	shard.animation.play('anim', true);
	shard.scale.set(soul.scale.x, soul.scale.y);
	var exclude = '';
	for (i in random.int(-50, -100)...random.int(50, 100)) {
		exclude = exclude + ',' + i;
	}
	shard.velocity.set(random.int(200, -250, exclude), random.int(200, -250, exclude));
	shard.acceleration.y = 600;
	add(shard);
}

function END(exiting:Bool) {
	canPress = false;
	exitingScreen = true;
	if (floatTween != null) {
		floatTween.cancel();
	}
	if (soulFade != null) {
		soulFade.cancel();
	}
	if (!exiting) {
		soul.alpha = 1;
		soul.animation.curAnim.curFrame = 0;
		FlxG.sound.play(Paths.sound('break'));
	} else {
		FlxTween.tween(soul, {alpha: 0}, 1, {ease: FlxEase.cubeOut});
	}
	if (theme.fadeTween != null) {
		theme.fadeTween.cancel();
	}
	theme.fadeOut(0.5, 0);
	deathCamera.fade(FlxColor.BLACK, 1, false, function() {
		if (exiting) {
			FlxG.switchState(new FreeplayState());
		} else {
			FlxG.switchState(new PlayState());
		}
	});
}

// function updateSelection(?v:Int) {
	// if (v != null) {
		// selected += v;
		// FlxG.sound.play(Paths.sound('squeak'));
		// if (selected > optionTexts.length - 1) {
			// selected = 0;
		// } else if (selected < 0) {
			// selected = optionTexts.length - 1;
		// }
	// }
	// optionTexts.forEach(function(option:FlxSprite) {
		// var hovering = option.ID == selected;
		// option.color = (hovering ? FlxColor.YELLOW : FlxColor.WHITE);
	// });
// }

var letter = '';
var splits = 0;
var blipPath = (Assets.exists(Paths.sound(game.SONG.meta.name + '-blip')) ? Paths.sound(game.SONG.meta.name + '-blip') : Paths.sound('text-blip'));
function startDialogue() {
	var pickedDialogue = texts[pickedText][curDialogue];
	splitText = getCharacters(pickedDialogue);			
	addLetter = new FlxTimer().start(0.06, function() {
		letter = splitText[curLetter];
		if (letter == '/') {
			curLetter++;
			letter = splitText[curLetter];
			text = '';
			lines++;
		}
		text = text + letter;
		textLines[lines].text = text;
		if (letter != ' ') {
			FlxG.sound.play(blipPath);
		}
		curLetter++;
		if (curLetter == splitText.length - 1) {
			anotherTimer = new FlxTimer().start(1, function() {
				if (curDialogue != texts[pickedText].length - 1) {
					curDialogue++;
					splitText = [];
					curLetter = 0;
					lines = 0;
					splits = 0;
					text = '';
					for (text in textLines) {
						text.text = '';
					}
					startDialogue();
				} else {
					for (text in textLines) {
						text.visible = false;
						if (!exitingScreen) {
							theme.fadeIn(0.5, 0.5, 1);
						}
					}
				}
			});
		}
	}, splitText.length - splits);
}

function getLines(song:String) {
	var index = 0;
	var songPath = 'gameoverlines/' + song;
	var content = (Assets.exists(Paths.txt(songPath)) ? Assets.getText(Paths.txt(songPath)) : 'ok so this is a REAL/error message:this means theres no/file for the lines/and this is the fallback:PLEASE tell me, xpsxexp/TO FIX IT!!!!');
	var lines = content.split('\n');
	var linesFormatted:Array<String> = [];
	for (line in lines) {
		if (index == pickedText) {
			line = line + (!themeExists ? ':HEY SO the song playing/in the bg SHOULD/NOT BE PLAYING:this means theres no/game over theme for/this song specifically:SO PLEASEPLEASPL TELL ME,/XPSXEXP TO FIX IT' : '');
		}
		linesFormatted.push(line.split(':'));
		index++;
	}
	return linesFormatted;
}

function getCharacters(text:String) {
	var split = text.split();
	for (letter in split) {
		if (letter == '/') {
			splits++;
		}
	}
	return split;
}

function bitmapText(x:Int, y:Int, text:String, alignment:FlxTextAlign, color:String, width:Int, scale:Float, font:FlxBitmapFont) {
	var text = new FlxBitmapText(x, y, text, font);
	text.alignment = alignment;
	text.fieldWidth = width;
	text.color = FlxColor.fromString('#' + color);
	text.scale.set(scale, scale);
	text.font = font;
	return text;
}

function getFont(image:String, letters:String) {
	return FlxBitmapFont.fromXNA(Assets.getBitmapData(Paths.image('fonts/' + image), true, false), letters);
}