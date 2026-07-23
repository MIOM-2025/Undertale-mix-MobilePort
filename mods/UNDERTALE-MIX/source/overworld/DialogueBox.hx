import UndertaleText;

class DialogueBox extends FlxSprite {
	var dialogueBox:FlxCamera = new FlxCamera();
	
	var boxText:UndertaleText;
	var boxPortrait:FlxSprite;
	
	var stateParent:Dynamic;
	var hasPortrait:Bool = false;
	var textSound:Bool = true;
	var lastPortrait:String = '';
	var dialogueIndex:Int = 0;
	var dialogues:Array<Dynamic> = [];
	var dialogueSpecial:Void->Void = null;
	var typeSound:FlxSound;

	override function new(x:Int, y:Int, parent:Dynamic) {
		super(x, y);
		FlxG.cameras.add(dialogueBox, false);
		dialogueBox.bgColor = FlxColor.TRANSPARENT;
		dialogueBox.antialiasing = false;
		dialogueBox.zoom = 3;
		dialogueBox.visible = false;
	
		loadGraphic(Paths.image('overworld/box'));
		screenCenter();
		cameras = [dialogueBox];
		
		boxText = new UndertaleText(0, 0, "*mog\n", 'left', FlxG.width, 1, 'FFFFFF', 'undertale-pixel');
		boxText.lineSpacing = 3;
		boxText.updateHitbox();
		boxText.cameras = [dialogueBox];
		
		stateParent = parent;
	}
	
	var currentLetter:Int = 0;
	var waitTimer:Float = 0;
	var textTypeSpeed:Float = 0;
	var typing:Bool = false;
	var active:Bool = false;
	var typed:Int = 0;
	var typeText:Array<String> = [];
	
	override function update(elapsed:Float) {
		if (active) {
			// ===== 点击/触摸检测（跳过或推进） =====
			var clicked = false;
			if (FlxG.mouse.justPressed) clicked = true;
			if (FlxG.touches.length > 0 && FlxG.touches[0].justPressed) clicked = true;
			
			if (clicked) {
				if (typing) {
					skipTyping();
				} else {
					if (dialogueIndex < dialogues.length) {
						advanceDialogue();
						typing = true;
					} else {
						dialogueBox.visible = false;
						active = false;
					}
				}
				// 防止与键盘冲突
				return;
			}
			
			// 键盘控制（保留原逻辑）
			if (typing) {
				if (FlxG.keys.justPressed.X) {
					skipTyping();
					return;
				}
				waitTimer += elapsed;
				var cl = typeText[currentLetter];
				if (waitTimer > textTypeSpeed) {
					if (cl != ' ' || cl != '.' || cl != 'ñ' || cl != '¬' || cl != '?' || cl != ',' || cl != '!' || cl != '*') {
						if (textSound) {
							if (lastPortrait != null) {
								FlxG.sound.play(Paths.sound('txt_' + lastPortrait), 0.6 * Options.volumeSFX);
							} else {
								FlxG.sound.play(Paths.sound('txt'), 0.6 * Options.volumeSFX);
							}
						}
					}
					boxText.text = boxText.text + cl;
					if (cl == ',' || cl == '°') {
						waitTimer = -0.195;
					} else {
						waitTimer = 0;
					}
					currentLetter++;
				}
				if (currentLetter == typeText.length) {
					typing = false;
				}
			} else {
				if (FlxG.keys.justPressed.Z || FlxG.keys.justPressed.ENTER) {
					if (dialogueIndex < dialogues.length) {
						advanceDialogue();
						typing = true;
					} else {
						dialogueBox.visible = false;
						active = false;
					}
				}
			}
		}
	}
	
	// ===== 跳过打字（显示全文） =====
	function skipTyping() {
		if (!typing) return;
		var fullString = '';
		for (letter in typeText) {
			fullString += letter;
		}
		boxText.text = fullString;
		typing = false;
		// 如果当前段落是最后一段，标记为不活跃（但保留对话框，等待点击推进）
		if (dialogueIndex >= dialogues.length) {
			// 实际上advanceDialogue会在点击时推进，这里不处理
		}
	}
	
	function setupBox() {
		x += 0.1;
		y += 79;
		stateParent.add(boxText);
		boxPortrait = new FlxSprite(x + 14, y + 12);
		stateParent.add(boxPortrait);
		boxPortrait.cameras = [dialogueBox];
	}

	function setupDialogue(newDialogues:Array<Dynamic>) {
		if (newDialogues == null) {
			trace('Dialogues are null');
			return;
		}
		dialogueIndex = 0;
		dialogueBox.visible = true;
		dialogues = newDialogues;
		if (newDialogues[0][1] != null) {
			hasPortrait = true;
			setupSpeaker(newDialogues[0][1], newDialogues[0][2]);
		} else {
			boxPortrait.visible = false;
			lastPortrait = null;
			hasPortrait = false;
		}
		boxText.setPosition(x + (hasPortrait ? 72 : 14), y + 11);
		startTyping(newDialogues[0][0], newDialogues[0][3]);
		dialogueIndex++;
	}
	
	function setupSpeaker(speaker:String, expression:String) {
		lastPortrait = speaker;
		if (speaker != null) {
			if (speaker == 'noelle') {
				boxPortrait.offset.set(5, 7);
			} else {
				boxPortrait.offset.set(0, 0);
			}
			typeSound = FlxG.sound.load(Paths.sound('txt_' + speaker), 1);
			boxPortrait.visible = true;
			boxPortrait.frames = Paths.getAsepriteAtlas('overworld/portraits/' + speaker + 'face');
			setSpeakerExpression(expression);
			hasPortrait = true;
		} else {
			typeSound = FlxG.sound.load(Paths.sound('txt'), 1);
			boxPortrait.visible = false;
			hasPortrait = false;
		}
		boxText.setPosition(x + (hasPortrait ? 72 : 14), y + 11);
	}
	
	function setSpeakerExpression(expression:String) {
		var frameIndex:String = CoolUtil.addZeros(expression, 4);
		boxPortrait.animation.addByPrefix('face', frameIndex);
		boxPortrait.animation.play('face', true);
	}
	
	function advanceDialogue() {
		var currentDialogue:Array<Dynamic> = dialogues[dialogueIndex];
		startTyping(currentDialogue[0], currentDialogue[3]);
		if (lastPortrait != currentDialogue[1]) {
			setupSpeaker(currentDialogue[1], currentDialogue[2]);
		} else {
			setSpeakerExpression(currentDialogue[2]);
		}
		dialogueIndex++;
	}
	
	function startTyping(text:String, typeSpeed:Float) {
		dialogueSpecial = dialogues[dialogueIndex] != null ? dialogues[dialogueIndex][4] : null;
		if (dialogueSpecial != null) {
			dialogueSpecial();
		}
		currentLetter = 0;
		boxText.text = '';
		typeText = splitText(text);
		textTypeSpeed = typeSpeed;
		active = true;
		typing = true;
	}
	
	function splitText(text:String) {
		var splitText:Array<String> = text.split();
		var realSplitText:Array<String> = [];
		for (i in 0...splitText.length) {
			if (splitText[i] == "\\" && splitText[i + 1] == "n") {
				realSplitText.push('\n');
			} else if (splitText[i - 1] != '\\') {
				realSplitText.push(splitText[i]);
			}
		}
		return realSplitText;
	}
}