import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import UndertaleText;
import TypedBitmapText;
import flixel.text.FlxText.FlxTextAlign;

import flixel.math.FlxRandom;

import funkin.backend.utils.DiscordUtil;

var r:FlxRandom = new FlxRandom();
//Information stuff.
var typedText:TypedBitmapText;
var text:UndertaleText;
//Naming screen stuff.
var playerName:UndertaleText;
var namingTitle:UndertaleText;
var letters = [
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
];
var titles = [
	"What's your name?",
	"How do we call you?",
	"Any name you prefer?",
	"Name yourself.",
	"Who are you?",
	"Who's playing now?",
	"Pick a name, any name!",
	"You can do like 56^6 combinations here.",
	"The limit is still 6 letters.",
	"Pray that you can fit your name here.",
	"I hope it's something cool.",
	"Not sure where we're using this.",
	'Put "Chara" if you want I wont judge you.',
	"Press done to agree to sell your data.",
	"They're killing me tonight."
];
var lettersArray = [];
var seeingText:Bool = false;
function create() {
	//Just in case I fuck it up again.
	// FlxG.save.data.utmStartUp = null;
	if (FlxG.sound.music == null) {
		FlxG.sound.playMusic(Paths.music('startmenu'), 1, true);
	}

	if (FlxG.save.data.utmStartUp == null) {
		FlxG.save.data.utmStartUp = true;
		seeingText = true;
		text = new UndertaleText(568, 115, '---Information---', 'left', FlxG.width, 1.8);
		text.alpha = 0;
		add(text);
		FlxTween.tween(text, {x: text.x + 20, alpha: 0.5}, 0.5, {ease: FlxEase.cubeInOut, onComplete: function() {
			typedText.startTyping(0.023);
		}});	
	
	
		typedText = new TypedBitmapText(157, 177, "As most Friday Night Funkin'/mods do this mod contains/flashing lights!:If you're in any way sensitive/to this you can disable/them in the options.:With that we,/the Undertale Mix team thank you/for playing our mod!/ /We hope you enjoy everything/we have in store!", text.font);
		typedText.setTextFormat(1.8, 'FFFFFF', FlxTextAlign.LEFT, FlxG.width);
		typedText.lineOffset = 511;
		typedText.lineSpacing = 55;
		typedText.parentState = this;
		typedText.alpha = 0.5;
		add(typedText);	
	} else {
		generateMenu();
	}
}

var curSelected = 0;
var row = 0;
var pos = 0;
function generateMenu() {
	namingTitle = new UndertaleText(-6, 60, titles[r.int(0, titles.length - 1)], 'center', FlxG.width, 1.8);
	add(namingTitle);
	
	DiscordUtil.changePresence('Naming themselves.', namingTitle.text);
	
	playerName = new UndertaleText(1052, 131, '', 'left', FlxG.width, 1.8);
	if (FlxG.save.data.playerName != null) {
		playerName.text = FlxG.save.data.playerName;
	}
	add(playerName);
	
	var index = 0;
	for (letter in letters) {
		if (pos > 6) {
			pos = 0;
			row++;
		}
		if (letter == 'a') {
			pos = 0;
			row += 1.36;
		}
		var let = new UndertaleText(847 + (102 * pos), 201 + (49 * row), letter, 'left', FlxG.width, 1.8);
		let.ID = index;
		add(let);
		lettersArray.push(let);
		pos++;
		index++;
	}
	
	var backspace = new UndertaleText(895, 642, 'Backspace', 'left', FlxG.width, 1.8);
	lettersArray.push(backspace);
	backspace.ID = lettersArray.length - 1;
	add(backspace);

	var done = new UndertaleText(backspace.x + 400, backspace.y, 'Done', 'left', FlxG.width, 1.8);
	lettersArray.push(done);
	done.ID = lettersArray.length - 1;
	add(done);
	
	updateSelection();
	
	nameMenu = true;
}

//I'm coding everything like this I don't give a damn.
//I wont waste my time figuring this kind of menu again.
var lastIndex:Int = 0;
var nameAccept:Bool = false;
var oldOriginX = 0;
var oldOriginY = 0;
var nameMenu = false;
function update(elapsed:Float) {
	if (nameMenu) {
		if (controls.LEFT_P) {
			updateSelection(-1);
		} else if (controls.RIGHT_P) {
			updateSelection(1);
		} else if (controls.UP_P) {
			if (curSelected >= 26 && curSelected <= 30) {
				updateSelection(-5);
			} else if (curSelected >= 31 && curSelected <= 32) {
				updateSelection(-12);
			} else if (curSelected == 52 || curSelected == 53) {
				if (curSelected == 53 && lastIndex >= 47 && lastIndex <= 50) {
					curSelected = 51;
				} else if (curSelected == 52 && lastIndex == 51 || lastIndex == 45 || lastIndex == 46) {
					curSelected = 50;
				} else {
					curSelected = lastIndex;
				}
				updateSelection();
			} else {
				updateSelection(-7);
			}
		} else if (controls.DOWN_P) {
			if (curSelected >= 21 && curSelected <= 25) {
				updateSelection(5);
			} else if (curSelected >= 19 && curSelected <= 20) {
				updateSelection(12);
			} else if (curSelected >= 47 && curSelected <= 50) {
				lastIndex = curSelected;
				curSelected = 52;
				updateSelection();
			} else if (curSelected == 45 || curSelected == 46 || curSelected == 51) {
				lastIndex = curSelected;
				curSelected = 53;
				updateSelection();
			} else {
				updateSelection(7);
			}	
		}
	
		for (i in 0...52) {
			var line = lettersArray[i];
			line.x = line.originX + r.int(1, -1);
			line.y = line.originY + r.int(1, -1);
		}
		
		if (nameAccept) {
			if (playerName.scale.x < 5) {
				playerName.scale.x += 0.01;
				playerName.scale.y += 0.01;
				playerName.y += 1;
			}
			playerName.originX = 540;
			playerName.angle = r.float(1, -1);
			playerName.x = playerName.originX + r.int(1, -1);
			playerName.origin.set(0, 0);
		}
	}
	
	if (typedText != null) {
		typedText.textUpdate(elapsed);
	}
	
	if (controls.ACCEPT) { 
		if (nameMenu) {
			if (curSelected <= 51) { //Any valid letter.
				if (!nameAccept && playerName.text.length < 6) {
					playerName.text = playerName.text + lettersArray[curSelected].text;
				}	
			}
			if (curSelected == 52) { //Backspace.
				if (!nameAccept) {
					playerName.text = playerName.text.substring(0, playerName.text.length - 1);
				} else {
					for (i in 0...52) {
						letter = lettersArray[i];
						letter.visible = true;
					}	
					nameAccept = false;
					playerName.scale.set(1.8, 1.8);
					playerName.origin.set(oldOriginX, oldOriginY);
					playerName.x = 1052;
					playerName.y = 131;
					playerName.angle = 0;
					lettersArray[52].text = 'Backspace';
					lettersArray[53].text = 'Done';
					namingTitle.text = titles[r.int(0, titles.length - 1)];
					DiscordUtil.changePresence('Naming themselves.', namingTitle.text);
				}
			} else if (curSelected == 53 && playerName.text != '') { //Done.
				if (!nameAccept) {
					oldOriginX = playerName.origin.x; oldOriginY = playerName.origin.y;
					nameAccept = true;
					for (i in 0...52) {
						letter = lettersArray[i];
						letter.visible = false;
					}
					lettersArray[52].text = 'No';
					lettersArray[53].text = 'Yes';
					namingTitle.text = 'Is this correct?';
				} else {
					FlxG.save.data.playerName = playerName.text;
					FlxG.switchState(new MainMenuState());
				}
			}
		}
	
		if (seeingText) {
			if (typedText.active) {
				typedText.advanceDialogue();
			} else {
				if (!nameMenu) {
					FlxTween.tween(text, {x: text.x - 20, alpha: 0}, 0.5, {ease: FlxEase.cubeInOut, onComplete: function() {
						generateMenu();
					}});
					for (line in typedText.lines) {
						FlxTween.tween(line, {x: line.x - 20, alpha: 0}, 0.5, {ease: FlxEase.cubeInOut});
					}
				}
				seeingText = false;
			}
		}
	}
}

var bottomLimit;
function updateSelection(?v:Int) {
	bottomLimit = (!nameAccept ? 0 : 52);
	if (v != null) {
		curSelected += v;
		// trace(lettersArray[curSelected].text);
		if (curSelected > lettersArray.length - 1) {
			// trace('hello abovel imit');
			curSelected = lettersArray.length - 1;
		} else if (curSelected < bottomLimit) {
			// trace('hello belove imit');
			curSelected = bottomLimit;
		}
	}
	for (letter in lettersArray) {
		letter.color = (letter.ID == curSelected ? FlxColor.YELLOW : FlxColor.WHITE);
	}
}