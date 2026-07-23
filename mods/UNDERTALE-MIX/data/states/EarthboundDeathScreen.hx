import UndertaleText;

var c:FlxCamera = new FlxCamera();

var smallTextbox:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameover/textbox-threelines-small'));
var boxPrompt:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameover/boxproceed'), true, 7, 8);
var promptBlip:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameover/promptblip'), true, 4, 8);
var deathSpotlight1:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameover/gameover_earthbound1'));
var deathSpotlight2:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameover/gameover_earthbound2'));
var deathSpotlight3:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameover/gameover_earthbound3'));
var deathSpotlight4:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameover/gameover_earthbound4'));

//Dialogue stuff.
var dialogues:Array<String> = [
];
//Typer.
var active:Bool = false;
var typing:Bool = false;

var currentText:Array<Array<String>> = [];
var wholeText:Array<Array<String>> = [];
var curDialogue:Int = 0;
var curLetter:Int = 0;
var curLine:Int = 0;

var playerInputOnEnd:Bool = false;
var playerChoice:Bool = false;
var playerChoiceInput:Bool = true;
var lines:Array<UndertaleText> = [];

function create() {
	FlxG.cameras.add(c, false);
	c.bgColor = FlxColor.TRANSPARENT;
	c.zoom = 3.12;
	c.antialiasing = false;
	this.cameras = [c];
	
	deathSpotlight1.alpha = 0;
	deathSpotlight1.screenCenter();
	add(deathSpotlight1);
	FlxTween.tween(deathSpotlight1, {alpha: 1}, 3, {onComplete: function() {
		typeText([
			'*Boyfriend!/',
			'*Looks like you got',
			' your ass handed to you./',
			'*So how about giving it',
			' another shot, hm?/',
			'ñ',
		]);
	}});
	
	deathSpotlight2.alpha = 0;
	deathSpotlight2.screenCenter();
	add(deathSpotlight2);
	
	deathSpotlight3.alpha = 0;
	deathSpotlight3.screenCenter();
	add(deathSpotlight3);
	
	deathSpotlight4.alpha = 0;
	deathSpotlight4.screenCenter();
	add(deathSpotlight4);
	
	smallTextbox.screenCenter();
	smallTextbox.setPosition(smallTextbox.x + 55, smallTextbox.y - 72);
	smallTextbox.visible = false;
	add(smallTextbox);
	
	boxPrompt.setPosition(smallTextbox.x + 137, smallTextbox.y + 56);
	boxPrompt.animation.add('i', [0, 1], 4, true);
	boxPrompt.animation.play('i', true);
	boxPrompt.visible = false;
	add(boxPrompt);
	
	promptBlip.setPosition(smallTextbox.x, smallTextbox.y + 43);
	promptBlip.animation.add('i', [0, 1], 4, true);
	promptBlip.animation.play('i', true);
	promptBlip.visible = false;
	add(promptBlip);
	
	//redoing it all again cause im not bloating the typed text class just to add a different type method
	for (i in 0...3) {
		var line:UndertaleText = new UndertaleText(smallTextbox.x + 9, (smallTextbox.y + 12) + (15 * i), '', 'left', FlxG.width, 1, 'F88058', 'earthbound');
		add(line);
		lines.push(line);
	}
}

var gameOverTransition:Bool = false;
var waitTimer:FlxTimer = new FlxTimer();
var fadeTween1:FlxTween;
var fadeTween2:FlxTween;
var fadeTween3:FlxTween;
var fadeTween4:FlxTween;

var typeElapsed:Float = 0;
var typeSpeed:Float = 0.03;
function update(elapsed:Float) {
	if (active) {
	// trace(curDialogue);
		if (playerChoice) {
			if (controls.ACCEPT) {
				lines[1].text = wholeText[curDialogue - 2];
				lines[2].text = wholeText[curDialogue - 1];
				// lines[2].text = '';
				typeText((playerChoiceInput ? 
					['',
					 '*Boyfriend decided to return',
					 ' after thinking about',
					 ' Girlfriend giving him some',
					 ' mean head./',
					 '*Good luck!/',]
				: 
					['',
					 '*Oh well.../',
					 ' You can always try again',
					 ' later./',
					 '*Goodbye!/']
				));
				curDialogue = 0;
				playerChoice = false;
				promptBlip.visible = false;
			} else if (controls.LEFT_P) {
				playerChoiceInput = true;
			} else if (controls.RIGHT_P) {
				playerChoiceInput = false;
			}
			promptBlip.x = smallTextbox.x + (playerChoiceInput ? 35 : 103);
		}
		
		boxPrompt.visible = !typing;
		boxPrompt.alpha = (playerChoice ? 0 : 1);
		if (playerInputOnEnd) { //On player input.
			if (controls.ACCEPT) {
				if (curDialogue != currentText.length - 1 && !playerChoice) {
					if (curLine != 2) {
						curLine++;
					} else {
						lines[0].text = lines[1].text;
						lines[1].text = lines[2].text;
						lines[2].text = '';
					}
					curDialogue++;
					curLetter = 0;
					typing = true;
				} else {
					leaveScreen(!playerChoiceInput);
					smallTextbox.visible = false;
					for (line in lines) {
						line.visible = false;
					}
					remove(boxPrompt);
					active = false;
				}
			}
		}

		if (typing) {
			if (currentText[curDialogue][0] == 'ñ') {
				lines[0].text = wholeText[curDialogue - 2];
				lines[1].text = wholeText[curDialogue - 1];
				lines[2].text = '        Yes             No';
				
				promptBlip.visible = true;
				playerChoice = true;
				typing = false;
				return;
			}
			
			if (typeElapsed < typeSpeed) {
				typeElapsed += elapsed;
			} else {
				if (curLetter != currentText[curDialogue].length) {
					lines[curLine].text = lines[curLine].text + currentText[curDialogue][curLetter];
					if (currentText[curDialogue][curLetter] != ' ') {
						FlxG.sound.play(Paths.sound('earthbound-textblip'), 1);
					}
					curLetter++;
				} else { //Normally going through text until player input is needed.
					if (currentText[curDialogue][currentText[curDialogue].length - 1] != '/') {
						if (curLine != 2) {
							curLine++;
						} else {
							lines[0].text = lines[1].text;
							lines[1].text = lines[2].text;
							lines[2].text = '';
						}
						curDialogue++;
						curLetter = 0;
						playerInputOnEnd = false;
					} else {
						typing = false;
						playerInputOnEnd = true;
					}
				}
				typeElapsed = 0;
			}
		}
	}
}

function leaveScreen(e:Bool) {
	gameOverTransition = true;
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
									c.fade(FlxColor.WHITE, 1, false, function() {
										FlxG.switchState((e ? new FreeplayState() : new PlayState()));
									});
								}});
							});
						});
					});
				});
			});
		});
	});
}

//Text typer.
function typeText(lines:Array<String>) {
	if (smallTextbox.visible != true) {
		smallTextbox.visible = true;
	}

	wholeText = [];
	currentText = [];
	for (line in lines) {
		wholeText.push(line);
		currentText.push(getCharacters(line));
	}
	curDialogue = 0;
	curLetter = 0;
	
	active = true;
	typing = true;
}

function getCharacters(t:String) {
	return t.split();
}