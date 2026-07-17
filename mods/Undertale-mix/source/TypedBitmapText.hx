import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.graphics.frames.FlxBitmapFont;
import funkin.backend.system.Controls;
import funkin.backend.system.Control;

class TypedBitmapText extends FlxBitmapText {
	/* 原有属性保持不变 */
	var talker:FlxSprite;
	var parentState;
	var active:Bool = false;
	var typing:Bool = false;
	var waiting:Bool = false;
	var isSkippable:Bool = false;
	var soundBlip:String;
	var typeSound:FlxSound;
	var lineSpacing = 30;
	var lineOffset = 0;
	var typeDelay:Float = 0;
	var textContent:String;
	var textSplit:Array = [];
	var lines:Array = [];
	var dialogues:Array = [];
	var splits:Int = 1;
	var dialogue:Int = 0;
	var line:Int = 0;
	var letter:Int = 0;
	var waitTime:Float = 0;
	var talkTime:Int = 5;

	public function new(x, y, text, font) {
		super(x, y, '', font);
		this.autoSize = false;
		textContent = text;
		lines.push(this);
		setupLines(textContent);
	}

	function textUpdate(elap:Float) {
		/* 原样保留 */
		if (typing) {
			if (waiting) {
				waitTime += elap;
				if (waitTime > typeDelay) {
					waiting = false;
				}
			} else {
				var currentLine = lines[line];
				var currentLetter = splitText[letter];
				if (splitText[letter + 1] == '/') {
					letter++;
					line++;
				}
				currentLine.text = currentLine.text + currentLetter;
				if (currentLetter != ' ') {
					if (typeSound != null) {
						typeSound.play(true);
					}
				}
				letter++;
				waiting = true;
				waitTime = 0;
				if (letter == splitText.length) {
					if (dialogue == dialogues.length - 1) {
						active = false;
					}
					typing = false;
					waiting = false;
				}
			}
		}
	}

	function setTextFormat(scale:Float, color:String, alignment:FlxTextAlign, width:Float) {
		this.fieldWidth = width;
		this.scale.set(scale, scale);
		this.updateHitbox();
		this.color = FlxColor.fromString('#' + color);
		this.alignment = alignment;
	}

	function advanceDialogue() {
		/* 原样保留 */
		if (active) {
			if (!typing) {
				dialogue++;
				resetAndChangeText(dialogues[dialogue]);
				startTyping(typeDelay, soundBlip, isSkippable);
			} else if (typing && isSkippable) {
				// 快速显示当前段落（不推进对话）
				typing = false;
				waiting = false;
				line = 0;
				for (line in lines) { line.text = ''; }
				for (letter in splitText) {
					var currentLine = lines[line];
					currentLine.visible = this.visible;
					if (letter == '/') {
						line++;
					} else {
						currentLine.text = currentLine.text + letter;
					}
				}
				if (dialogue == dialogues.length - 1) {
					active = false;
				}
			}
		} else {
			for (line in lines) {
				line.text = ''; 
			}
		}
		return active;
	}

	function setupLines(text:String) {
		dialogues = getLines(text);
	}

	function startTyping(delay:Float, ?sound:String, ?skippable:Bool) {
		resetAndChangeText(dialogues[dialogue]);
		typeDelay = delay;
		typing = true;
		active = true;
		isSkippable = (skippable != null ? skippable : false);
		if (sound != null) {
			soundBlip = sound;
			typeSound = FlxG.sound.load(Paths.sound(sound), Options.volumeSFX);
		}
	}

	function resetAndChangeText(newText:String, ?overrideText:Bool) {
		if (overrideText) {
			dialogue = 0;
			setupLines(newText);
		}
		this.text = '';
		line = 0;
		letter = 0;
		splits = 1;
		splitText = [];
		splitText = getCharacters(newText);
		for (line in lines) { line.text = ''; }
		if (splits > 1) {
			for (i in 0...splits) {
				var curLine = lines[i];
				if (curLine != null) {
					curLine.text = '';
				} else {
					var line = new FlxBitmapText(this.x + lineOffset, this.y + (lineSpacing * i), '', this.font);
					line.autoSize = false;
					line.scale.set(this.scale.x, this.scale.y);
					line.scrollFactor.set(this.scrollFactor.x, this.scrollFactor.y);
					line.updateHitbox();
					line.alignment = this.alignment;
					line.color = this.color;
					line.cameras = this.cameras;
					line.fieldWidth = this.fieldWidth;
					line.alpha = this.alpha;
					parentState.add(line);
					lines.push(line);
				}
			}
		}
	}

	function getLines(content:String) {
		return content.split(':');
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

	// ================= 新增跳过方法 =================
	/**
	 * 立即完成当前段落的打字，显示全部文字。
	 * 不推进对话索引（dialogue 不变）。
	 */
	public function skipTyping():Void {
		if (!typing) return;
		typing = false;
		waiting = false;
		// 重置所有行
		for (l in lines) l.text = '';
		// 重新组装当前段落全文，按 '/' 分割行
		var lineIndex = 0;
		var currentLineText = "";
		for (i in 0...splitText.length) {
			var c = splitText[i];
			if (c == '/') {
				if (lineIndex < lines.length) {
					lines[lineIndex].text = currentLineText;
				}
				lineIndex++;
				currentLineText = "";
			} else {
				currentLineText += c;
			}
		}
		// 最后一行
		if (lineIndex < lines.length) {
			lines[lineIndex].text = currentLineText;
		}
		// 如果当前段落是最后一段，且没有更多 ':' 对话，则标记完成
		if (dialogue == dialogues.length - 1) {
			active = false;
		}
	}
}