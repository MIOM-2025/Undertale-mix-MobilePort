import UndertaleText;
import TypedBitmapText;
import funkin.backend.utils.DiscordUtil;

var camera:FlxCamera = new FlxCamera();

// 模式变量
var inputMode:String = "keyboard"; // "keyboard" 或 "touch"
var modeSwitchedThisFrame:Bool = false;

// 右下角提示文本
var tapText:FlxText;

// 原有变量
var canProceed:Bool = false;
var hasToPick:Bool = false;
var currentIndex:Int = true;
var textIndex:Int = 0;
var yesOrNo:Bool = false;
var waitForInput:Bool = false;

// 鼠标点击 pending 状态（用于触摸模式）
var pendingYes:Bool = false;
var pendingNo:Bool = false;
var pendingAny:Bool = false;

var yesHitArea:FlxSprite;
var noHitArea:FlxSprite;
var yes:UndertaleText;
var no:UndertaleText;
var infoText:UndertaleText;
var typedText:TypedBitmapText;

function create() {
	DiscordUtil.changePresenceAdvanced({
		details: 'Getting started...',
	});

	FlxG.cameras.add(camera, false);
	camera.bgColor = FlxColor.TRANSPARENT;
	camera.antialiasing = false;
	camera.zoom = 3.0;
	camera.pixelPerfectRender = true;
	this.cameras = [camera];
	
	FlxG.sound.playMusic(Paths.music('menuthemes/startup'), 0.5, true);
	
	infoText = new UndertaleText(450, 280, '--Information--', 'left', FlxG.width, 1, 'FFFFFF', 'undertale-pixel');
	infoText.alpha = 0.5;
	add(infoText);
	
	// 完整对话（原样）
	var fullDialogue = '\n \n \n*Hi, thanks for playing Undertale Mix!\n\nñBefore you start to actually play\nñthe mod we have to ask a few quick\nñquestions.:\n \n \n*This mod uses heavy flashing lights\nñin some songs which could trigger a seizure\nñor affect anyone with photosensitivity.\n \n*Do you want to keep flashing lights on?:\n \n \n*Like any Friday Night Funkin\' mod ever this\nñmod uses shaders.\n \n*Do you want to keep shaders on?:\n \n \n*Some songs have particle effects that\nñdepending on the device could\nñcause performance issues.\n \n*Do you want to keep particles on?:\n \n \n*With that out of the way we,\nñthe Undertale Mix team hope\nñyou enjoy the mod!';
	
	typedText = new TypedBitmapText(450, 280, fullDialogue, infoText.getFont('undertale-pixel'));
	typedText.setTextFormat(1, 'FFFFFF', FlxTextAlign.LEFT, FlxG.width);
	typedText.alpha = infoText.alpha;
	add(typedText);
	typedText.startTyping(0.03, null, false);
	
	yes = new UndertaleText(0, 300, 'Yes', 'left', FlxG.width, 1, 'FFFFFF', 'undertale-pixel');
	yes.autoSize = true;
	yes.updateHitbox();
	add(yes);
	yes.alpha = 1;
	
	no = new UndertaleText(yes.x + 50, yes.y, 'No', 'left', FlxG.width, 1, 'FFFFFF', 'undertale-pixel');
	no.autoSize = true;
	no.updateHitbox();
	add(no);
	no.alpha = yes.alpha;
	
	var total:Int = yes.width + 100 + no.width;
	yes.setPosition((FlxG.width - total) / 2, 444);
	no.setPosition(yes.x + 100, yes.y);
	yes.visible = no.visible = false;
	
	// ---- 透明点击区域 for Yes/No ----
	yesHitArea = new FlxSprite(yes.x, yes.y);
	yesHitArea.makeGraphic(Std.int(yes.width), Std.int(yes.height), FlxColor.TRANSPARENT);
	yesHitArea.cameras = [camera];
	yesHitArea.alpha = 0;
	yesHitArea.visible = false;
	add(yesHitArea);
	
	noHitArea = new FlxSprite(no.x, no.y);
	noHitArea.makeGraphic(Std.int(no.width), Std.int(no.height), FlxColor.TRANSPARENT);
	noHitArea.cameras = [camera];
	noHitArea.alpha = 0;
	noHitArea.visible = false;
	add(noHitArea);
	
	// ---- 右下角提示文本 ----
	tapText = new FlxText(0, 0, 0, "Tap to continue", 20);
	tapText.setFormat(Paths.font("undertale-pixel"), 20, 0xFFFFFF, "right");
	tapText.antialiasing = true;
	tapText.cameras = [camera];
	tapText.alpha = 0.8;
	tapText.visible = false;
	add(tapText);
	updateTapTextPosition();
	
	// ---- 默认模式 ----
	#if mobile
		inputMode = "touch";
	#else
		inputMode = "keyboard";
	#end
}

function updateTapTextPosition() {
	if (tapText != null) {
		tapText.updateHitbox();
		tapText.x = FlxG.width - tapText.width - 2;
		tapText.y = FlxG.height - 2; // 引擎坐标原点在左下角
	}
}

function update(elapsed:Float) {
	updateTapTextPosition();
	
	// ========== 打字机跳过（仅当前段落） ==========
	if (typedText != null && typedText.typing && FlxG.mouse.justPressed) {
		// 立即完成当前段落的打字
		if (typedText.skipTyping != null) {
			typedText.skipTyping();
		} else {
			// 备用：将打字速度设到极小，下一帧完成
			typedText.typingSpeed = 0.001;
			// 或直接设置为全部可见（若存在 visibleChars）
			if (typedText.visibleChars != null) {
				typedText.visibleChars = typedText.text.length;
			}
			typedText.typing = false;
		}
		// 停止打字声音（若有）
		return; // 本次点击不触发其他事件
	}
	
	if (typedText != null) {
		typedText.textUpdate(elapsed);
	}
	
	// 打字完成后进入等待输入状态
	if (!typedText.typing && !waitForInput) {
		if (textIndex == 1 || textIndex == 2 || textIndex == 3) {
			hasToPick = true;
			yes.visible = no.visible = true;
			yesHitArea.visible = noHitArea.visible = true;
			tapText.visible = true;
			if (inputMode == "keyboard") {
				yesOrNo = true;
				yes.color = FlxColor.YELLOW;
				no.color = FlxColor.WHITE;
			} else { // touch
				yes.color = FlxColor.WHITE;
				no.color = FlxColor.WHITE;
				yesOrNo = false;
			}
		} else {
			canProceed = true;
		}
		waitForInput = true;
	}
	
	// ---- 模式切换 ----
	modeSwitchedThisFrame = false;
	if (inputMode == "keyboard") {
		// 鼠标左键点击 => 切换到触摸模式
		if (FlxG.mouse.justPressed) {
			inputMode = "touch";
			modeSwitchedThisFrame = true;
			pendingYes = false;
			pendingNo = false;
			pendingAny = false;
			if (hasToPick) {
				yes.color = FlxColor.WHITE;
				no.color = FlxColor.WHITE;
				yesOrNo = false;
			}
		}
	} else if (inputMode == "touch") {
		// 按下 LEFT 或 RIGHT 键时切换到键盘模式
		if (controls.LEFT || controls.RIGHT) {
			inputMode = "keyboard";
			modeSwitchedThisFrame = true;
			pendingYes = false;
			pendingNo = false;
			pendingAny = false;
			if (hasToPick) {
				yesOrNo = true;
				yes.color = FlxColor.YELLOW;
				no.color = FlxColor.WHITE;
			}
		}
	}
	if (modeSwitchedThisFrame) {
		return; // 跳过本次输入的进一步处理
	}
	
	// ===== 无选项时：点击任意处或按 Z/Enter 推进 =====
	if (canProceed) {
		if (FlxG.mouse.justPressed) {
			pendingAny = true;
		}
		if (pendingAny && FlxG.mouse.justReleased) {
			pendingAny = false;
			advanceDialogue();
		}
		if (controls.ACCEPT || FlxG.keys.justPressed.Z) {
			advanceDialogue();
		}
	}
	
	// ===== 有选项时：根据模式处理 =====
	if (hasToPick) {
		var mousePoint = FlxG.mouse.getScreenPosition(camera);
		var overYes = yesHitArea.visible && yesHitArea.overlapsPoint(mousePoint, true, camera);
		var overNo  = noHitArea.visible  && noHitArea.overlapsPoint(mousePoint, true, camera);
		
		if (inputMode == "keyboard") {
			// 键盘模式：左右切换，回车/Z确认
			if (controls.LEFT) {
				yesOrNo = true;
				yes.color = FlxColor.YELLOW;
				no.color = FlxColor.WHITE;
			} else if (controls.RIGHT) {
				yesOrNo = false;
				yes.color = FlxColor.WHITE;
				no.color = FlxColor.YELLOW;
			}
			if (controls.ACCEPT || FlxG.keys.justPressed.Z) {
				acceptChoice();
			}
		} else { // touch
			// 触摸模式：悬浮高亮，释放确认
			if (overYes) {
				yes.color = FlxColor.YELLOW;
				no.color = FlxColor.WHITE;
				yesOrNo = true;
			} else if (overNo) {
				yes.color = FlxColor.WHITE;
				no.color = FlxColor.YELLOW;
				yesOrNo = false;
			} else {
				// 无悬浮，白色，保留 yesOrNo 用于回车默认
				if (yes.color != FlxColor.WHITE || no.color != FlxColor.WHITE) {
					yes.color = FlxColor.WHITE;
					no.color = FlxColor.WHITE;
				}
			}
			// 鼠标释放确认
			if (FlxG.mouse.justPressed) {
				if (overYes) pendingYes = true;
				else if (overNo) pendingNo = true;
			}
			if (FlxG.mouse.justReleased) {
				if (pendingYes && yesHitArea.visible && yesHitArea.overlapsPoint(mousePoint, true, camera)) {
					yesOrNo = true;
					pendingYes = false;
					acceptChoice();
				} else if (pendingNo && noHitArea.visible && noHitArea.overlapsPoint(mousePoint, true, camera)) {
					yesOrNo = false;
					pendingNo = false;
					acceptChoice();
				} else {
					pendingYes = false;
					pendingNo = false;
				}
			}
			// 回车/Z确认（不切换模式）
			if (controls.ACCEPT || FlxG.keys.justPressed.Z) {
				if (overYes) {
					yesOrNo = true;
				} else if (overNo) {
					yesOrNo = false;
				} else {
					yesOrNo = true; // 默认 yes
				}
				acceptChoice();
			}
		}
	}
}

// ---- 推进到下一段（保留原逻辑） ----
function advanceDialogue() {
	textIndex++;
	typedText.advanceDialogue();
	canProceed = false;
	waitForInput = false;
	hasToPick = false;
	yes.visible = no.visible = false;
	yesHitArea.visible = noHitArea.visible = false;
	tapText.visible = false;
	if (textIndex == 5) {
		FlxTween.tween(infoText, {x: infoText.x - 500, alpha: 0}, 0.5, {ease: FlxEase.cubeInOut, onComplete: function() {
			FlxG.switchState(new ModState('StartUp', 'startup'));
		}});
	}
	trace(textIndex);
}

// ---- 确认选择 ----
function acceptChoice() {
	if (pendingYes || pendingNo) return; // 防止键盘与鼠标重复触发
	switch(textIndex) {
		case 1:
			FlxG.save.data.flashingLights = yesOrNo;
			FlxG.save.flush();
		case 2:
			Options.gameplayShaders = yesOrNo;
			FlxG.save.flush();
		case 3:
			FlxG.save.data.particlesEnabled = yesOrNo;
			FlxG.save.flush();
	}
	// 选项完成后推进到下一段
	advanceDialogue();
	trace('ACCEPTED OR NA: ' + yesOrNo);
}