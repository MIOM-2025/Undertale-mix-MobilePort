import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;

//PlayState shortcut.
var game = PlayState.instance;
//Game over stuff.
var deathCamera = new FlxCamera();
var bigTextbox:FlxSprite = new FlxSprite(360, 30).loadGraphic(Paths.image('gameover/textbox-twolines-large'));
var bigBoxTextLines:Array<Dynamic> = [];
var smallTextbox:FlxSprite = new FlxSprite(575, 30).loadGraphic(Paths.image('gameover/textbox-threelines-small'));
var smallBoxTextLines:Array<Dynamic> = [];
var boxPrompt:FlxSprite = new FlxSprite(smallTextbox.x + 410, smallTextbox.y + 168).loadGraphic(Paths.image('gameover/boxproceed'), true, 7, 8);
var promptBlip:FlxSprite = new FlxSprite(smallTextbox.x + 106, smallTextbox.y + 129).loadGraphic(Paths.image('gameover/promptblip'), true, 4, 8);
var deathTheme:FlxSound = FlxG.sound.load(Paths.music('abaddream'), 1, true);
var deathSpotlight1:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameover/gameover_earthbound1'));
var deathSpotlight2:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameover/gameover_earthbound2'));
var deathSpotlight3:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameover/gameover_earthbound3'));
var deathSpotlight4:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameover/gameover_earthbound4'));
var spotlights = [deathSpotlight1, deathSpotlight2, deathSpotlight3, deathSpotlight4];
var fader:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
var gameOverTrans = false;
/*Just writing before coding all of it but,
 to mimic somewhat the Earthbound text typing I'll make the text an array
 each line being a different entry in this array.
 That way it should be easier for me to nail down the type text thing in Earthbound.
*/
var dialogues = [
	'*Boyfriend!/',
	'*It looks like you got your ass ',
	' handed to you.../',
	'*So how about giving it',
	' another shot?/',
	'ñ'
];
/*
var dialogues = [
	'*heres how ill torture you david',
	' number one the MARROW FURNACE/',
	' ill inject liquid metal into',
	' your bones     ',
	' boiling them from the inside/',
	'*number two THE NERVE HARVESTER',
	' each nerve fiber will be plucked',
	' and strung',
	' vibrating with agony/',
	'* number three THE ORGAN GRINDER',
	' your organs will be twisted and',
	' cranked',
	' a grotesque puppet of pain/',
	' number four THE SKIN WEAVER',
	' your skin will be peeled and',
	' rewoven a living tapestry of',
	' torment/',
	' number five THE EYEBALL CRUCIBLE',
	' your eyes will be roasted and', 
	' replaced with burning coals/',
	' number six THE MIND FLAYER',
	' your thoughts will be shredded',
	' echoes of endless torment/',
	'ñ'
];
*/
var waitForInput = false;
var choicePrompt = false;
var inGameOverScreen = false;
var initDialogue = '*Boyfriend got blueballed and died...      /*Boyfriend lost the rap battle...';
var currentDialogue = 0;
var promptSelection = 0;

var curCharacter = 0;
var currentLine = 0;
var splits = 0;
function create(event) {
	game.executeEvent({name: 'HScript Call', params: ['whenDead', '']});

	FlxTween.tween(game.player.characters[2], {y: (game.downscroll ? game.player.characters[2].y - 100 : game.player.characters[2].y + 100)}, 0.6, {ease: FlxEase.expoInOut});
	game.player.characters[2].playAnim('death', true);
	
	game.health = 0.01;
	game.persistentDraw = true;
	game.persistentUpdate = true;
	game.paused = true;
	game.canPause = false;
	event.cancel();
	
	FlxG.cameras.add(deathCamera, false);
	deathCamera.bgColor = FlxColor.TRANSPARENT;
	
	smallTextbox.visible = false;
	if (game.downscroll) {
		bigTextbox.y = 522;
	}
	
	var earthboundLetters:String = "ABCDEFGH" + "IJKLMNOP" + "QRSTUVWX" + "YZabcdef" + "ghijklmn" + "opqrstuv" + "wxyz!?. " + "*";
	var earthboundFont = getFont('earthbound-basic', earthboundLetters);
	
	smallBoxText = bitmapText(smallTextbox.x + 29, smallTextbox.y + 31, '', FlxTextAlign.LEFT, 'F88058', FlxG.width, 3.0, earthboundFont);
	smallBoxText.lineSpacing = 2;
	
	FlxG.sound.play(Paths.sound('death-earthbound'), 1, false, null, true, function() {
		deathTheme.play();
	});
	
	boxPrompt.animation.add('blip', [0, 1], 4, true);
	boxPrompt.animation.play('blip', true);
	
	promptBlip.animation.add('blip', [0, 1], 4, true);
	promptBlip.animation.play('blip', true);
	
	for (spot in spotlights) {
		spot.cameras = [deathCamera];
		spot.antialiasing = false;
		spot.scale.set(3, 3);
		spot.updateHitbox();
		spot.screenCenter();
		spot.alpha = 0;
		spot.y -= 14;
		add(spot);
	}
	
	for (thing in [bigTextbox, smallTextbox, smallBoxText, boxPrompt, promptBlip]) {
		thing.cameras = [deathCamera];
		thing.antialiasing = false;

		thing.scale.set(3, 3);
		thing.updateHitbox();
		
		add(thing);
	}
	
	fader.screenCenter();
	fader.cameras = [deathCamera];
	fader.alpha = 0;
	add(fader);
	
	for (i in 0...2) {
		bigTextLine = bitmapText(bigTextbox.x + 29, (bigTextbox.y + 45) + (48 * i), '', FlxTextAlign.LEFT, 'F88058', FlxG.width, 3.0, earthboundFont);
		bigTextLine.cameras = [deathCamera];
		add(bigTextLine);
		bigBoxTextLines.push(bigTextLine);
	}
	
	for (i in 0...3) {
		smallTextLine = bitmapText(smallTextbox.x + 29, (smallTextbox.y + 45) + (48 * i), '', FlxTextAlign.LEFT, 'F88058', FlxG.width, 3.0, earthboundFont);
		smallTextLine.cameras = [deathCamera];
		add(smallTextLine);
		smallBoxTextLines.push(smallTextLine);
	}
	
	var splittedText = getCharacters(initDialogue);
	curCharacter = 0;
	typeText = new FlxTimer().start(0.04, function() {
		bigBoxTextLines[currentLine].text = bigBoxTextLines[currentLine].text + splittedText[curCharacter];
		curCharacter++;
		if (splittedText[curCharacter] == '/') {
			currentLine++;
			curCharacter++;
		}
		if (curCharacter == splittedText.length - 1) {
			waitForInput = true;
			boxPrompt.setPosition(bigTextbox.x + 530, bigTextbox.y + 120);
		}
	}, splittedText.length);
	
	
	// wait = new FlxTimer().start(2, function() {
			// retryPrompt();
	// });
	// retryPrompt();
}

function bitmapText(x:Int, y:Int, text:String, alignment:FlxTextAlign, color:String, width:Int, scale:Float, font:FlxBitmapFont) {
	var text = new FlxBitmapText(x, y, text, font);
	text.alignment = alignment;
	text.autoSize = false;
	text.fieldWidth = width;
	text.color = FlxColor.fromString('#' + color);
	text.scale.set(scale, scale);
	text.updateHitbox();
	text.font = font;
	return text;
}

function getFont(image:String, letters:String) {
	return FlxBitmapFont.fromXNA(Assets.getBitmapData(Paths.image('fonts/' + image), true, false), letters);
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

function update() {
	game.player.characters[2].playAnim('death', true);

	boxPrompt.visible = waitForInput;
	promptBlip.visible = choicePrompt;
	
	if (FlxG.keys.justPressed.Z) {
		if (gameOverTrans) {
			gameOverTrans = false;
			fadeIntoWhite(false);
		}
	}
	
	if (choicePrompt) {
		promptBlip.x = smallTextbox.x + (promptSelection == 0 ? 106 : 312);
		if (controls.LEFT_P) {
			promptSelection = 0;
		} else if (controls.RIGHT_P) {
			promptSelection = 1;
		}
		if (FlxG.keys.justPressed.Z) {
			choicePrompt = false;
			if (promptSelection == 0) {
				curCharacter = 0;
				smallBoxTextLines[2].text = '';
				dialogues[currentDialogue] = '*Boyfriend decided to return';
				dialogues.push(' after remembering Girlfriend');
				dialogues.push(' giving him some mean head./');
				dialogues.push('*Good luck!/');
				retryPrompt();
			} else if (promptSelection == 1) {
				curCharacter = 0;
				smallBoxTextLines[2].text = '';
				dialogues[currentDialogue] = '*Oh well.../';
				dialogues.push(' You will have to enter the');
				dialogues.push(' song through the menu');
				dialogues.push(' if you want to try again./');
				dialogues.push('*See you later!/');
				retryPrompt();
			}
		}
	}
	
	if (waitForInput) {
		if (FlxG.keys.justPressed.Z) {
			if (inGameOverScreen) {
				proceedText();
			} else if (!inGameOverScreen) {
				//Reset variables.
				curCharacter = 0;
				currentLine = 0;
				currentDialogue = 0;
				waitForInput = false;
				//Fade into actual game over screen.
				bigTextbox.visible = false;
				for (line in bigBoxTextLines) {
					line.visible = false;
				}
				FlxTween.tween(game.camHUD, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
				FlxTween.tween(game.camGame, {alpha: 0}, 1, {ease: FlxEase.quadInOut, onComplete: function() {
					game.persistentDraw = false;
					game.persistentUpdate = false;
					inGameOverScreen = true;
					FlxTween.tween(deathSpotlight1, {alpha: 1}, 3, {ease: FlxEase.quadInOut, onComplete: function() {
						retryPrompt();
					}});
				}});
			}
		}
	}
}

var typeDialogue:FlxTimer = new FlxTimer();
var finishedAll = false;
function retryPrompt() {
	smallTextbox.visible = true;
	boxPrompt.setPosition(smallTextbox.x + 410, smallTextbox.y + 168);

	var splittedText = getCharacters(dialogues[currentDialogue]);
	if (splittedText[0] == 'ñ') {
		smallBoxTextLines[0].text = dialogues[currentDialogue - 2];
		smallBoxTextLines[1].text = dialogues[currentDialogue - 1];
		smallBoxTextLines[2].text = '        Yes             No';
		choicePrompt = true;
		return;
	}
	typeDialogue.start(0.04, function() {
		smallBoxTextLines[currentLine].text = smallBoxTextLines[currentLine].text + splittedText[curCharacter];
		FlxG.sound.play(Paths.sound('earthbound-textblip'), 1);
		curCharacter++;
		if (curCharacter == splittedText.length - 1) {
			trace('Reached end of dialogue.');
			if (splittedText[curCharacter] == '/') {
				waitForInput = true;
				if (currentDialogue == dialogues.length - 1) {
					finishedAll = true;
				}
			} else {
				curCharacter = 0;
				if (currentLine != 2) {
					currentLine++;
				} else {
					smallBoxTextLines[0].text = dialogues[currentDialogue - 1];
					smallBoxTextLines[1].text = dialogues[currentDialogue];
					smallBoxTextLines[2].text = '';
				}
				currentDialogue++;
				retryPrompt();
			}
			// if (currentDialogue == dialogues.length) {
				// trace('Reached end of dialogues.');
			// }
		}
	}, splittedText.length);
}

function proceedText() {
	if (!finishedAll) {
		//Reset vars.
		curCharacter = 0;
		waitForInput = false;
		//Advance to next line.
		if (currentLine != 2) {
			currentLine++;
		} else {
			smallBoxTextLines[0].text = dialogues[currentDialogue - 1];
			smallBoxTextLines[1].text = dialogues[currentDialogue];
			smallBoxTextLines[2].text = '';
		}
		currentDialogue++;
		retryPrompt();
	} else {
		if (promptSelection == 0) {
			beginSpotlightFade();
		} else if (promptSelection == 1) {
			waitForInput = false;
			smallTextbox.visible = false;
			for (line in smallBoxTextLines) {
				line.visible = false;
			}
			fadeIntoWhite(true);
		}
	}
}

var waitTimer:FlxTimer = new FlxTimer();
var fadeTween1:FlxTween;
var fadeTween2:FlxTween;
var fadeTween3:FlxTween;
var fadeTween4:FlxTween;
function beginSpotlightFade() {
	waitForInput = false;
	gameOverTrans = true;
	smallTextbox.visible = false;
	for (line in smallBoxTextLines) {
		line.visible = false;
	}

	waitTimer.start(1, function() {
		fadeTween1 = FlxTween.tween(deathSpotlight1, {alpha: 0}, 2, {ease: FlxEase.quintInOut});
		waitTimer.start(0.2, function() {
			fadeTween2 = FlxTween.tween(deathSpotlight2, {alpha: 1}, 2, {ease: FlxEase.quintInOut});
			waitTimer.start(2, function() {
				fadeTween2 = FlxTween.tween(deathSpotlight2, {alpha: 0}, 2, {ease: FlxEase.quintInOut});
				waitTimer.start(0.2, function() {
					fadeTween3 = FlxTween.tween(deathSpotlight3, {alpha: 1}, 2, {ease: FlxEase.quintInOut});
					waitTimer.start(2, function() {
						fadeTween3 = FlxTween.tween(deathSpotlight3, {alpha: 0}, 2, {ease: FlxEase.quintInOut});
						waitTimer.start(0.2, function() {
							fadeTween4 = FlxTween.tween(deathSpotlight4, {alpha: 1}, 2, {ease: FlxEase.quintInOut});
							waitTimer.start(2, function() {
								fadeTween4 = FlxTween.tween(deathSpotlight4, {alpha: 0}, 1, {ease: FlxEase.quintInOut, onComplete: function() {
									fadeIntoWhite(false);
								}});
							});
						});
					});
				});
			});
		});
	});
}

function fadeIntoWhite(exit:Bool) {
	for (tween in [fadeTween1, fadeTween2, fadeTween3, fadeTween4]) {
		if (tween != null) {
			tween.cancel();
		}
	}
	if (waitTimer != null) {
		waitTimer.cancel();
	}
	FlxTween.tween(fader, {alpha: 1}, 1, {ease: FlxEase.quadInOut, onComplete: function () {
		if (!exit) {
			FlxG.switchState(new PlayState());
		} else {
			FlxG.switchState(new MainMenuState());
		}
	}});
}