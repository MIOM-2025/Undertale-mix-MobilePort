import flixel.ui.FlxBar;
import flixel.ui.FlxBar.FlxBarFillDirection;
import flixel.util.FlxStringUtil;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import funkin.backend.utils.BitmapUtil;
import funkin.backend.utils.DiscordUtil;

import Date;
import Std;

import UndertaleText;
import TypedBitmapText;

import StringTools;
import Math;
/*
	Icons.
*/
var playerIconsFound:Array<String> = [];
var opponentIconsFound:Array<String> = [];
var playerIcons:Array<HealthIcon> = [];
var playerColors:Array<FlxColor> = [];
var opponentIcons:Array<HealthIcon> = [];
var opponentColors:Array<FlxColor> = [];
var icons:Array<HealthIcon> = [];
/*
	Texts.
*/
var timeText:UndertaleText;
var scoreText:UndertaleText;
/*
	Sprites.
*/
var timer:FlxSprite = new FlxSprite(0, 544).loadGraphic(Paths.image('hud/timer'));
var box:FlxSprite = new FlxSprite(0, 596).loadGraphic(Paths.image('hud/box'));
var bar:FlxBar;
/*
	Other.
*/
var hudObjects:Array<Dynamic> = [];
var ebHudObjects:Array<Dynamic> = [];
var hudScale:Float = 1.5;
var iconData:Array<Dynamic> = [];
var values:Dynamic;
var r:FlxRandom = new FlxRandom();
/*
	Earthbound.
*/
var numbers:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
var numFrames = [
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
var stats:FlxSprite = new FlxSprite().loadGraphic(Paths.image('hud/charstats'));
var bigTextbox:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameover/textbox-twolines-large'));
var boxText:TypedBitmapText;
var boxPrompt:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('gameover/boxproceed'), true, 7, 8);

function postCreate() {
	values = PlayState.SONG.meta.customValues;

	//Destroy existing UI.
	for (ui in [healthBar, healthBarBG, iconP1, iconP2, scoreTxt, missesTxt, accuracyTxt]) {
		ui.kill();
	}
	
	// camHUD.zoom = 0.5;
	
	box.scale.set(hudScale, hudScale);
	box.flipY = downscroll;
	box.antialiasing = false;
	box.screenCenter(FlxAxes.X);
	insert(0, box);
	hudObjects.push(box);
	
	timer.scale.set(hudScale, hudScale);
	timer.flipY = downscroll;
	timer.antialiasing = false;
	timer.screenCenter(FlxAxes.X);
	insert(0, timer);
	hudObjects.push(timer);
	
	timeText = new UndertaleText(timer.x, timer.y + (downscroll ? 7 : 0), '--:--', 'center', FlxG.width, 3.0, 'FFFFFF', 'crypt');
	timeText.updateHitbox();
	timeText.screenCenter(FlxAxes.X);
	timeText.setPosition(timeText.x + 3, timeText.y + 10);
	insert(members.indexOf(timer) + 1, timeText);
	hudObjects.push(timeText);
	timeText.text = '00:00';
	
	scoreText = new UndertaleText(0, box.y + 47, accuracyTxt.text + ' ' + missesTxt.text + ' ' + scoreTxt.text, 'center', FlxG.width, 1.5, 'FFFFFF', 'dotumche');
	scoreText.updateHitbox();
	scoreText.screenCenter(FlxAxes.X);
	insert(members.indexOf(box) + 1, scoreText);
	hudObjects.push(scoreText);

	opponentIconsFound = (values != null && values.opponentIcons != null ? values.opponentIcons.split(',') : getSongIconData('icon', false));
	opponentColors = (values != null && values.opponentColors != null ? values.opponentColors.split(',') : getSongIconData('color', false));
	if (values != null && values.opponentColors != null) {
		opponentColors = getColors(opponentColors);
	}
			
	playerIconsFound = (values != null && values.playerIcons != null ? values.playerIcons.split(',') : getSongIconData('icon', true));
	playerColors = (values != null && values.playerColors != null ? values.playerColors.split(',') : getSongIconData('color', true));
	if (values != null && values.playerColors != null) {
		playerColors = getColors(playerColors);
	}
	// trace('Opponent Icons: ' + opponentIconsFound + ' Opponent Colors: ' + opponentColors + '\nPlayer Icons: ' + playerIconsFound + ' Player Colors: ' + playerColors);
	
	bar = new FlxBar(0, 594, FlxBarFillDirection.RIGHT_TO_LEFT, 303, 25, this, 'health', 0, maxHealth);
	bar.screenCenter(FlxAxes.X);
	bar.scale.set(hudScale, hudScale);
	insert(members.indexOf(box) + 1, bar);
	hudObjects.push(bar);
	
	updateBar(null, null, true);

	for (obj in hudObjects) {
		obj.cameras = [camHUD];
	}
	
	if (!PlayState.opponentMode) {
		GameOverSubstate.script = 'data/scripts/death-new';
	} else {
		GameOverSubstate.script = 'data/scripts/death-opponent';
	}
	if (PlayState.SONG.meta.name == 'vent') {
		GameOverSubstate.script = 'data/scripts/death-opponent';
	}
	PauseSubState.script = 'data/scripts/pause-new';
	
	updateDiscordPresence = function() {
		DiscordUtil.changePresenceAdvanced({	
			details: 'Playing - ' + PlayState.SONG.meta.displayName + (PlayState.instance.paused ? ' (Paused)' : ''),
			smallImageKey: 'soul'
		});
	};
	// updateDiscordPresence = function() {
		// DiscordUtil.changePresenceAdvanced({	
			// details: 'MIND YOUR OWN BUSINESS',
			// smallImageKey: 'soul'
		// });
	// };
	updateDiscordPresence();
	
	// var begin:Float = Date.now().getTime();
	// var end:Float = begin + PlayState.inst.length;
	// updateDiscordPresence = function() {
		// DiscordUtil.changePresenceAdvanced({
			// details: 'Playing - ' + PlayState.SONG.meta.displayName,
			// startTimestamp: Std.int(begin / 1000),
			// endTimestamp: Std.int(end / 1000)
		// });
	// }
	// updateDiscordPresence();
	
	
	defaultDisplayRating = false;
	minDigitDisplay = -1;
}

/*
	Health variables.
*/
var center:Float;
var oldHP:Float;
/*
	Time variables.
*/
var oldTime:String;
var currentTime:Float;
var time:Int;
var timeString:String;

var deathProceed:Bool = false;
function postUpdate(elapsed:Float) {
	// if (playerIcons.length == 0) { return; }
	// trace(Conductor.songPosition);
	// camHUD.zoom = 0.5;
	if (earthboundActive && boxText != null) {
		boxText.textUpdate(elapsed);
		boxPrompt.visible = !boxText.active;
		if (!boxText.active) {
			if (controls.ACCEPT && !deathProceed) {
				boxPrompt.alpha = 0;
				// FlxTween.tween(camGame, {alpha: 0}, 1, {onComplete: function() {
				// }});
				camHUD.fade(FlxColor.BLACK, 1, false, function() {
					openSubState(new ModSubState('EarthboundDeathScreen'));
				}, true);
				deathProceed = true;
			}
		}
	}
	
	// if (initDeath) {
		// if (controls.ACCEPT) {
		// }
		// return;
	// }
	
	center = bar.x + bar.width * FlxMath.remapToRange(bar.percent, 0, 100, 1, 0);
	if (oldHP != health) {
		oldHP = health;
		onHealthChange();
	}
	
	if (Conductor.songPosition > 0) {
		currentTime = Math.max(0, Conductor.songPosition);
		time = Math.floor(currentTime / 1000);
		timeString =  CoolUtil.addZeros(FlxStringUtil.formatTime(time), 5);
		if (oldTime != timeString) {
			onTimeChange(timeString);
			oldTime = timeString;
		}
	}


	if (earthboundActive && initDeath) {
		bf.playAnim('death', true);
	}
}

function onInputUpdate(e) {
	if (initDeath) {
		e.cancel();
	}
}

function onRatingUpdate(e) {
	scoreText.text = accuracyTxt.text + ' ' + missesTxt.text + ' ' + scoreTxt.text;
	scoreText.updateHitbox();
	scoreText.screenCenter(FlxAxes.X);
}

//I hope doing updates like this is more performant. i odnt fukcing know i cant tell dude its been motnhs
var threeDigitHealth:Int = 0;
function onHealthChange() {
	if (numbers.length > 0) {
		threeDigitHealth = Math.floor((health / 2) * 100);
		
		updateDiscordPresence = function() {
			DiscordUtil.changePresenceAdvanced({	
				details: 'An annoying dog' + encounterMessage + (PlayState.instance.paused ? ' (Paused)' : '') + '\nHP: ' + threeDigitHealth + ' PP: 999',
			});
		};
		updateDiscordPresence();

		updateTrackers(threeDigitHealth);
	}
	for (icon in icons) {
		if (icon.isPlayer) {
			icon.x = center;
			icon.health = bar.percent / 100;
		} else {
			icon.x = center - (icon.width);
			icon.health = 1 - (bar.percent / 100);
		}
	}
}

function onTimeChange(time:String) {
	timeText.text = time;
}

function onEvent(e) {
	if (e.event.name == 'Change Character') {
		// var curIcon:HealthIcon = (strumLines.members[e.event.params[0]].cpu ? opponentIcons[0] : playerIcons[0]);
		// curIcon.setIcon(e.event.params[1]);
		// curIcon.scale.set(hudScale - 0.7, hudScale - 0.7);
		
		// var colorGroup = (strumLines.members[e.event.params[0]].cpu ? opponentColors : playerColors);
		// var iconBitmap:BitmapData = Assets.getBitmapData(Paths.image('icons/' + e.event.params[1]));
		// var iconColor:FlxColor = BitmapUtil.getMostPresentColor(iconBitmap);
		// colorGroup[0] = iconColor;
		// bar.createGradientBar(opponentColors, playerColors, 1);
		// onHealthChange();
	}
	
	if (e.event.name == 'Change Icons') {
		var props = {
			player: e.event.params[0],
			opponent: e.event.params[1],
			playerColors: e.event.params[2],
			opponentColors: e.event.params[3],
		}
		
		var playerUpdate:Bool = false;
		var oppUpdate:Bool = false;
		var colorUpdate:Bool = false;
		if (props.player != '') {
			playerIconsFound = props.player.split(',');
			playerUpdate = true;
		}
		if (props.opponent != '') {
			opponentIconsFound = props.opponent.split(',');
			oppUpdate = true;
		}
		if (props.playerColors != '') {
			playerColors = getColors(props.playerColors.split(','));
			colorUpdate = true;
		}
		if (props.opponentColors != '') {
			opponentColors = getColors(props.opponentColors.split(','));
			colorUpdate = true;
		}
		updateBar(playerUpdate, oppUpdate, colorUpdate);
	}
}

function updateBar(?updatePlayer:Bool, ?updateOpponent:Bool, ?updateColors:Bool) {
	if (updatePlayer) {
		for (icon in playerIcons) {
			icon.destroy();
			// playerIcons.remove(icon);
			icons.remove(icon);
		}
		playerIcons = [];
	}
	if (updateOpponent) {
		for (icon in opponentIcons) {
			icon.destroy();
			// opponentIcons.remove(icon);
			icons.remove(icon);
		}
		opponentIcons = [];
	}

	if (playerIcons.length == 0 || updatePlayer) {
		var playerIndex:Int = 0;
		for (icon in playerIconsFound) {
			i = generateIcon(icon, true);
			i.ID = playerIndex;
			playerIcons.push(i);
			var yP:Bool = (i.ID % 2 == 1);
			if (i.ID > 0) {
				i.offset.set(-(i.width / 2) + playerIcons[i.ID - 1].offset.x, (i.height / 2) * (yP ? 1 : 0));
			}
			i.cameras = [camHUD];
			insert(members.indexOf(bar) + 1, i);
			hudObjects.push(i);
			icons.push(i);
			playerIndex++;
		}
	}
	if (opponentIcons.length == 0 || updateOpponent) {
		var opponentIndex:Int = 0;
		for (icon in opponentIconsFound) {
			i = generateIcon(icon, false);
			i.ID = opponentIndex;
			opponentIcons.push(i);
			var yP:Bool = (i.ID % 2 == 1);
			if (i.ID > 0) {
				i.offset.set((i.width / 2) + opponentIcons[i.ID - 1].offset.x, (i.height / 2) * (yP ? 1 : 0));
			}
			i.cameras = [camHUD];
			insert(members.indexOf(bar) + 1, i);
			hudObjects.push(i);
			icons.push(i);
			opponentIndex++;
		}
	}
	
	if (updateColors) {
		bar.createGradientBar(opponentColors, playerColors, 1);
		bar.updateBar();
	}
	onHealthChange();
}

function getColors(colors:Array<String>) {
	var parsedColors:Array<FlxColor> = [];
	for (color in colors) {
		parsedColors.push(FlxColor.fromString('#' + color));
	}
	return parsedColors;
}

function generateIcon(image:String, player:Bool) {
	var icon:HealthIcon = new HealthIcon(image, player);
	icon.scale.set(hudScale - 0.7, hudScale - 0.7);
	icon.updateHitbox();
	icon.y = bar.y - 60;
	return icon;
}

function getSongIconData(dataType:String, player:Bool) {
	var strumType:Int = (player ? 1 : 0);
	var foundData:Array<Dynamic> = [];
	for (strumLine in strumLines) {
		// trace('[' + strumLines.length + ']');
		if (dataType == 'icon') {
			if (strumLine.data.type == strumType) {
				for (character in strumLine.characters) {
					foundData.push(character.icon);
				}
			}
		} else if (dataType == 'color') {
			if (strumLine.data.type == strumType) {
				for (character in strumLine.characters) {
					foundData.push(character.iconColor);
				}
			}
		} else {
			// trace('[icon] or [color], not ' + dataType);
			return;
		}
	}
	return foundData;
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

function setVisibility(v:Bool) {
	for (ui in hudObjects) {
		ui.visible = v;
	}
}

var earthboundActive:Bool = false;
var encounterMessages:Array<String> = [
	' attacked!',
	' blocked the way!',
	' came after you!', 
	' trapped you!',
];
var encounterMessage:String;
var activeBefore:Bool = false;
function earthboundCreate() {
	if (!activeBefore) {
		earthboundActive = true;
		
		activeBefore = true;
		
		encounterMessage = encounterMessages[r.int(0, encounterMessages.length - 1)];
		updateDiscordPresence = function() {
			DiscordUtil.changePresenceAdvanced({	
				details: 'An annoying dog' + encounterMessage + (PlayState.instance.paused ? ' (Paused)' : ''),
			});
		};
		updateDiscordPresence();

		stats.setPosition(100, (downscroll ? 440 : 492));
		stats.scale.set(3, 3);
		stats.updateHitbox();
		stats.screenCenter(FlxAxes.X);
		stats.antialiasing = false;
		ebHudObjects.push(stats);
		insert(0, stats);
		
		executeEvent({name: 'Change Character', params: [1, 'bf-earthbound' ]});
		bf.cameras = [camHUD];
		bf.scale.set(3, 3);
		bf.updateHitbox();
		remove(bf);
		insert(members.indexOf(stats), bf);
		bf.screenCenter();
		bf.setPosition(bf.x + 20, bf.y + (downscroll ? 276.4 : 127));
		
		var frames = [];
		for (i in 0...40) {
			frames.push(i);
		}
		
		for (i in 0...3) {
			var num:FlxSprite = new FlxSprite((stats.x + 72) + (24 * i), stats.y + 72).loadGraphic(Paths.image('hud/numbers'), true, 9, 16);
			num.scale.set(3, 3);
			num.updateHitbox();
			num.antialiasing = false;
			num.animation.add('i', frames, 0);
			num.animation.play('i', true);
			num.cameras = [camHUD];
			num.ID = i;
			numbers.add(num);
		}
		insert(members.indexOf(stats) + 1, numbers);
		ebHudObjects.push(numbers);
	} else {
		encounterMessage = encounterMessages[r.int(0, encounterMessages.length - 1)];
		updateDiscordPresence = function() {
			DiscordUtil.changePresenceAdvanced({	
				details: 'An annoying dog' + encounterMessage + (PlayState.instance.paused ? ' (Paused)' : ''),
			});
		};
		updateDiscordPresence();
	
		executeEvent({name: 'Change Character', params: [1, 'bf-earthbound' ]});
		bf.cameras = [camHUD];
		bf.scale.set(3, 3);
		bf.updateHitbox();
		remove(bf);
		insert(members.indexOf(stats), bf);
		bf.screenCenter();
		bf.setPosition(bf.x + 20, bf.y + (downscroll ? 276.4 : 127));
		
		earthboundActive = true;
		onHealthChange();
	}
	
	for (ui in ebHudObjects) {
		// ui.antialiasing = false;
		if (activeBefore) {
			ui.visible = true;
		}
		ui.cameras = [camHUD];
	}
	
	onHealthChange();
}

function returnNormal() {
	if (earthboundActive) {
		for (ui in ebHudObjects) {
			ui.visible = false;
		}
		setVisibility(true);
		earthboundActive = false;
	}
}

function updateTrackers(newValue:Int) {
	var splitNew = StringTools.lpad(Std.string(newValue), '0', 3);
	var splitted = splitNew.split();
	numbers.forEach(function(num:FlxSprite) {
		FlxTween.num(num.animation.curAnim.curFrame, numFrames[splitted[num.ID]], 0.1, null, number -> num.animation.curAnim.curFrame = number);
	});
}

var deathTheme:FlxSound = FlxG.sound.load(Paths.music('abaddream'), 1, true);
var initDeath:Bool = false;
function onGameOver(e){
	if (earthboundActive) {
		if (!initDeath) {
			// camGame.shake(0.01, 0.5);
			camHUD.shake(0.001, 0.5);
			bigTextbox.cameras = [camHUD];
			bigTextbox.scale.set(3, 3);
			bigTextbox.updateHitbox();
			bigTextbox.screenCenter();
			bigTextbox.setPosition(bigTextbox.x, bigTextbox.y - 232);
			add(bigTextbox);
			
			boxPrompt.animation.add('i', [0, 1], 4, true);
			boxPrompt.animation.play('i', true);
			boxPrompt.scale.set(3, 3);
			boxPrompt.updateHitbox();
			boxPrompt.cameras = [camHUD];
			boxPrompt.setPosition(bigTextbox.x + 531, bigTextbox.y + (downscroll ? 0 : 120));	
			add(boxPrompt);
			
			boxText = new TypedBitmapText(bigTextbox.x + 29, bigTextbox.y + (downscroll ? 81 : 45), '', timeText.getFont('earthbound'));
			boxText.parentState = this;
			boxText.cameras = [camHUD];
			boxText.setTextFormat(3, 'F88058', timeText.getAlignment('left'), FlxG.width);
			add(boxText);
			boxText.lineOffset = 1278;
			boxText.lineSpacing = (downscroll ? -48 : 48);
			boxText.resetAndChangeText('*Boyfriend got blueballed and died...   /*Boyfriend lost the rap battle...', true);
			boxText.startTyping(0.03, 'earthbound-textblip');
			
			bf.stunned = true;
			canPause = false;

			inst.pitch = 0;
			for (strumLine in strumLines.members) {
				strumLine.vocals.pitch = 0;
				strumLine.vocals.stop();
			}
			inst.pause();
			FlxG.sound.music.pause();
			vocals.stop();
			vocals.pitch = 0;
			FlxG.sound.play(Paths.sound('death-earthbound'), 1, false, null, true, function() {
				deathTheme.play();
			});
			stats.loadGraphic(Paths.image('hud/charstats-death'));
			stats.y += (downscroll ? 128 : 0);
			
			numbers.forEach(function(num:FlxSprite) {
				num.loadGraphic(Paths.image('hud/numbers-death'), true, 9, 16);
				num.y += (downscroll ? 32 : 0);
			});

			var add:Int = (downscroll ? -70 : 70);
			FlxTween.tween(bf, {y: bf.y + add}, 1, {ease: FlxEase.expoIn});
			
			initDeath = true;
			
			updateDiscordPresence = function() {
				DiscordUtil.changePresenceAdvanced({	
					state: '',
					details: FlxG.save.data.playerName + ' lost the battle...',
				});
			};
		}
		
		e.cancel();
		return;
	} else {
		updateDiscordPresence = function() {
			DiscordUtil.changePresenceAdvanced({	
				state: '',
				details: 'Game Over! - ' + PlayState.SONG.meta.displayName,
			});
		};
	}
	updateDiscordPresence();
}

// function postUpdate(

function updatePresenceStuff() {
	updateDiscordPresence();
}
