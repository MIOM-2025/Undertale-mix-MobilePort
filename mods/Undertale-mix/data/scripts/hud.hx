import flixel.ui.FlxBar;
import flixel.ui.FlxBar.FlxBarFillDirection;
import flixel.math.FlxMath;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.util.FlxStringUtil;
import funkin.backend.utils.DiscordUtil;

//Hud stuff.
var s:Int = 1.5;
var bar:FlxBar;
var player:HealthIcon;
var opponent:HealthIcon;
var timeText:FlxBitmapText;
var scoreText:FlxBitmapText;
var timer:FlxSprite;
var box:FlxSprite;
var songMeta = SONG.meta;
var dead = false;
var hudObjects = [];

//Odometer stuff and Earthbound hud stuff.
var numbers:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
var numberFrames = [
	0 => 0,
	1 => 4,
	2 => 8,
	3 => 12,
	4 => 16,
	5 => 20,
	6 => 24,
	7 => 28,
	8 => 32,
	9 => 36
];
var active = false; //Whether the hud is on or not.
var statBox:FlxSprite = new FlxSprite(0, (downscroll ? 441 : 491)).loadGraphic(Paths.image('hud/charstats'));
var battleBox:FlxSprite = new FlxSprite(0, 40).loadGraphic(Paths.image('hud/earthbound-box'));

function postCreate() {
	for (ui in [healthBar, healthBarBG, iconP1, iconP2, scoreTxt, missesTxt, accuracyTxt]) {
		ui.kill();
	}
	
	timer = new FlxSprite(0, 544).loadGraphic(Paths.image('hud/timer'));
	timer.antialiasing = false;
	timer.scale.set(s, s);
	timer.flipY = downscroll;
	timer.screenCenter(FlxAxes.X);
	insert(0, timer);
	
	var cryptLetters:String = "abcdefgh" + "ijklmnop" + "qrstuvwx" + "yz123456" + "789.,:;'" + '"()!?+-/' + "=0% ";
	timeText = bitmapText(timer.x + 22, timer.y + (downscroll ? 10 : 18), '--:--', FlxTextAlign.CENTER, 'FFFFFF', FlxG.width, 3.0, getFont('cryptoftomorrow', cryptLetters));
	insert(members.indexOf(timer) + 1, timeText);
	
	box = new FlxSprite(0, 596).loadGraphic(Paths.image('hud/box'));
	box.antialiasing = false;
	box.scale.set(s, s);
	box.flipY = downscroll;
	box.screenCenter(FlxAxes.X);
	insert(0, box);
	
	var dotumcheLetters:String = 'AaBbCcDdEeFf' + 'GgHhIiJjKkLl' + 'MmNnOoPpQqRr' + 'SsTtUuVvWwXx' + 'YyZz01234567' + '89!#%&$*"/@?' + '+>}{<_~=-])[' + "(,.|^;: ";
	scoreText = bitmapText(0, box.y + 50, '', 'CENTER', 'FFFFFF', FlxG.width, 1.5, getFont('dotumche', dotumcheLetters));
	scoreText.text = accuracyTxt.text + ' ' + missesTxt.text + ' ' + scoreTxt.text;
	scoreText.updateHitbox();
	scoreText.screenCenter(FlxAxes.X);
	insert(members.indexOf(box) + 1, scoreText);
	
	bar = new FlxBar(0, 594, FlxBarFillDirection.RIGHT_TO_LEFT, 303, 25, this, 'health', 0, maxHealth);
	bar.screenCenter(FlxAxes.X);
	bar.scale.set(s, s);
	bar.createFilledBar(dad.iconColor, boyfriend.iconColor);
	insert(members.indexOf(box) + 1, bar);
	
	player = new HealthIcon(boyfriend.getIcon(), true);
	player.scale.set(s - 0.7, s - 0.7);
	player.updateHitbox();
	player.y = bar.y - 60;
	add(player);
	
	opponent = new HealthIcon(dad.getIcon(), true);
	opponent.flipX = true;
	opponent.scale.set(s - 0.7, s - 0.7);
	opponent.updateHitbox();
	opponent.y = bar.y - 60;
	add(opponent);
	
	hudObjects = [timer, box, bar, timeText, scoreText, player, opponent];
	for (ui in hudObjects) {
		ui.cameras = [camHUD];
	}
	
	updateDiscordPresence = function() {
		DiscordUtil.changePresenceAdvanced({	
			details: 'Playing - ' + songMeta.displayName + (PlayState.instance.paused ? ' (Paused)' : ''),
			smallImageKey: 'soul'
		});
	};
	updateDiscordPresence();
	
	PauseSubState.script = 'data/scripts/pause';
	GameOverSubstate.script = 'data/scripts/death-new';
	
	// earthboundHud();
}

var oldHp = 0;
function update() {
	if (active && oldHp != health) {
		oldHp = health;
		healthChange();
	}
	
	var center:Float = bar.x + bar.width * FlxMath.remapToRange(bar.percent, 0, 100, 1, 0);
	player.x = center; opponent.x = center - (opponent.width);
	player.health = bar.percent / 100; opponent.health = 1 - (bar.percent / 100);
	
	if (Conductor.songPosition > 0) {
		var currentTime:Float = Math.max(0, Conductor.songPosition);
		var time:Int = Math.floor(currentTime / 1000);
		timeText.text = CoolUtil.addZeros(FlxStringUtil.formatTime(time), 5);
	}
}
f
var hpPercent = 0;
function healthChange() {
	hpPercent = (health / 2) * 100;
	updateTrackers(Math.floor(hpPercent));
}

function onGameOver(event){
	updateDiscordPresence = function() {
		DiscordUtil.changePresenceAdvanced({	
			state: 'This is a game over text!',
			details: 'Game Over - ' + songMeta.displayName,
			smallImageKey: 'soulbroken'
		});
	};
	updateDiscordPresence();
}

function updatePresenceStuff() {
	updateDiscordPresence();
}

function onRatingUpdate(event) {
	scoreText.text = accuracyTxt.text + ' ' + missesTxt.text + ' ' + scoreTxt.text;
	scoreText.x = (FlxG.width - scoreText.width) / 2;
}

function bitmapText(x:Int, y:Int, text:String, alignment:FlxTextAlign, color:String, width:Int, scale:Float, font:FlxBitmapFont) {
	var text = new FlxBitmapText(x, y, text, font);
	text.alignment = alignment;
	text.fieldWidth = width;
	text.color = FlxColor.fromString('0xFF' + color);
	text.scale.set(scale, scale);
	text.font = font;
	return text;
}

function getFont(image:String, letters:String) {
	return FlxBitmapFont.fromXNA(Assets.getBitmapData(Paths.image('fonts/' + image), true, false), letters);
}

var time = 0.4;
function fadeInHud() {
	hudObjects = [timer, box, bar, timeText, scoreText, player, opponent];
	for (ui in hudObjects) {
		FlxTween.tween(ui, {alpha: 1}, time, {ease: FlxEase.expoInOut});
	}
	for (eUi in [statBox, battleBox, PlayState.instance.playerStrums.characters[2]]) {
		FlxTween.tween(eUi, {alpha: 0}, time, {ease: FlxEase.expoInOut});
	}
	numbers.forEach(function(num:FlxSprite) {
		FlxTween.tween(num, {alpha: 0}, time, {ease: FlxEase.expoInOut});
	});
	for (strumLine in strumLines) {
		for (strum in strumLine) {
			FlxTween.tween(strum, {alpha: 1}, time, {ease: FlxEase.expoInOut});
		}
	}
	cpu.visible = true;
	for (strum in playerStrums) {
		// strum.y += 24;
		FlxTween.tween(strum, {x: strum.x + 320}, 1, {ease: FlxEase.expoInOut});
	}
	// trace('hi');
	updateNotes('default');
}

function earthboundHud() {
	active = true;
	
	GameOverSubstate.script = 'data/scripts/death-earthbound';
	
	// for (ui in hudObjects) {
		// ui.visible = false;
	// }
	
	var earthboundBoyfriend = PlayState.instance.playerStrums.characters[2];
	earthboundBoyfriend.visible = true;
	earthboundBoyfriend.cameras = [camHUD];
	earthboundBoyfriend.setPosition(statBox.x + 70, statBox.y - (downscroll ? -146 : 41));
	earthboundBoyfriend.screenCenter(FlxAxes.X);
	earthboundBoyfriend.scale.set(3, 3);
	earthboundBoyfriend.updateHitbox();
	
	updateNotes('earthboundNotes');

	cpu.visible = false;

	statBox.scale.set(3, 3);
	statBox.updateHitbox();
	statBox.screenCenter(FlxAxes.X);
	insert(0, statBox);

	var frames = [];
	for (i in 0...40) {
		frames.push(i);
	}
	for (i in 0...3) {
		var num = new FlxSprite((stats.x + 72) + (24 * i), stats.y + 72).loadGraphic(Paths.image('numbers'), true, 9, 16);
		num.scale.set(3, 3);
		num.updateHitbox();
		num.animation.add('scroll', frames, 0);
		num.animation.play('scroll', true);
		num.cameras = [camHUD];
		num.ID = i;
		numbers.add(num);
	}
	insert(1, numbers);
	
	// battleBox.screenCenter();
	// battleBox.y -= 241;
	// battleBox.scale.set(3, 3);
	// battleBox.updateHitbox();
	// add(battleBox);
	
	for (ui in [statBox, numbers, battleBox]) {
		ui.cameras = [camHUD];
	}
	
	remove(earthboundBoyfriend);
	insert(0, earthboundBoyfriend);
	earthboundBoyfriend.setPositon(earthboundBoyfriend.x - 2, earthboundBoyfriend.y + 2);
}

function whenDead() {
	var frames = [];
	for (i in 0...40) {
		frames.push(i);
	}
	numbers.forEach(function(num:FlxSprite) {
		num.loadGraphic(Paths.image('numbers-death'), true, 9, 16);
		num.animation.add('scroll', frames, 0);
		num.animation.play('scroll', true);
		if (downscroll) {
			num.y += 32;
		}
	});
	statBox.loadGraphic(Paths.image('hud/charstats-death'));
	// statB(downscroll ? 441 : 491)
	
	if (downscroll) {
		statBox.y += 128;
	}
}

function updateTrackers(newValue:Int) {
	var splitNew = StringTools.lpad(Std.string(newValue), '0', 3);
	var splitted = splitNew.split();
	numbers.forEach(function(num:FlxSprite) {
		FlxTween.num(num.animation.curAnim.curFrame, numberFrames[splitted[num.ID]], 0.1, null, number -> num.animation.curAnim.curFrame = number);
	});
	trace(newValue);
}

function fadeAwayBullshit() {
	for (ui in hudObjects) {
		FlxTween.tween(ui, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
	}
	for (strum in cpuStrums) {
		FlxTween.tween(strum, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
	}
}

var middle = [412, 524, 636, 748];
var originalValuesPlayer = [];
var originalValuesOpponent = [];
function setMiddle() {
	for (ui in hudObjects) {
		FlxTween.tween(ui, {alpha: 0.1}, 1, {ease: FlxEase.quadInOut});
	}

	for (strumLine in strumLines.members) {
		if (strumLine.cpu) {
			for (note in strumLine.notes) {
				note.alpha = 0;
			}
		}
		for (strum in strumLine) {
			if (strum.strumLine.cpu) {
				strum.alpha = 0.1;
				originalValuesOpponent.push(strum.x);
			} else {
				originalValuesPlayer.push(strum.x);
			}
			strum.x = middle[strum.ID];
		}
	}
}

function setUnMiddle() {
	for (ui in hudObjects) {
		FlxTween.tween(ui, {alpha: 1}, 1, {ease: FlxEase.quadInOut});
	}
	
	for (strumLine in strumLines.members) {
		if (strumLine.cpu) {
			for (note in strumLine.notes) {
				note.alpha = 1;
			}
		}
		for (strum in strumLine) {
			if (strum.strumLine.cpu) {
				strum.x = originalValuesOpponent[strum.ID];
				strum.alpha = 1;
			} else {
				strum.x = originalValuesPlayer[strum.ID];
			}
		}
	}
	// for (i in 0...3) {
		// playerStrums[i].x = originalValuesPlayer[i];
		// cpuStrums[i].x = originalValuesOpponent[i];
	// }
}

function updateNotes(noteSkin:String) {
	var skinPath = 'game/notes/' + noteSkin;
	for (strumLine in strumLines.members) {
		for (strum in strumLine) {
			var anim = strum.animation.name;
			strum.frames = Paths.getSparrowAtlas(skinPath);
			strum.animation.addByPrefix('green', 'arrowUP');
			strum.animation.addByPrefix('blue', 'arrowDOWN');
			strum.animation.addByPrefix('purple', 'arrowLEFT');
			strum.animation.addByPrefix('red', 'arrowRIGHT');

			switch (strum.ID % 4) {
				case 0:
					strum.animation.addByPrefix("static", 'arrowLEFT0');
					strum.animation.addByPrefix("pressed", 'left press', 24, false);
					strum.animation.addByPrefix("confirm", 'left confirm', 24, false);
				case 1:
					strum.animation.addByPrefix("static", 'arrowDOWN0');
					strum.animation.addByPrefix("pressed", 'down press', 24, false);
					strum.animation.addByPrefix("confirm", 'down confirm', 24, false);
				case 2:
					strum.animation.addByPrefix("static", 'arrowUP0');
					strum.animation.addByPrefix("pressed", 'up press', 24, false);
					strum.animation.addByPrefix("confirm", 'up confirm', 24, false);
				case 3:
					strum.animation.addByPrefix("static", 'arrowRIGHT0');
					strum.animation.addByPrefix("pressed", 'right press', 24, false);
					strum.animation.addByPrefix("confirm", 'right confirm', 24, false);
			}
			strum.animation.play(anim, true);
			strum.updateHitbox();
		}
		
		for (note in strumLine.notes) {
			var anim = note.animation.name;
			note.frames = Paths.getSparrowAtlas(skinPath);
			switch (note.strumID) {
				case 0:
					note.animation.addByPrefix('scroll', 'purple0');
					note.animation.addByPrefix('hold', 'purple hold piece');
					note.animation.addByPrefix('holdend', 'pruple end hold');
				case 1:
					note.animation.addByPrefix('scroll', 'blue0');
					note.animation.addByPrefix('hold', 'blue hold piece');
					note.animation.addByPrefix('holdend', 'blue hold end');
				case 2:
					note.animation.addByPrefix('scroll', 'green0');
					note.animation.addByPrefix('hold', 'green hold piece');
					note.animation.addByPrefix('holdend', 'green hold end');
				case 3:
					note.animation.addByPrefix('scroll', 'red0');
					note.animation.addByPrefix('hold', 'red hold piece');
					note.animation.addByPrefix('holdend', 'red hold end');
			}

			note.animation.play(anim, true);
			note.updateHitbox();
		}
	}
}