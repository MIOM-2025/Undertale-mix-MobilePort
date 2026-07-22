import funkin.backend.FunkinText;
import flixel.util.FlxStringUtil;
import UndertaleText;
import flixel.text.FlxTextAlign;
import flixel.text.FlxTextBorderStyle;
import Reflect;
import funkin.options.PlayerSettings;
import funkin.backend.utils.ControlsUtil;
import flixel.input.keyboard.FlxKey;

var trackedTime = 0;
var timeText:FunkinText;

public var switched = false;
public var keyString:String = '';
var switchText:FunkinText;
var timeText:FunkinText;
var switchAlert:FunkinText;

var nSwitch:FlxSprite = new FlxSprite();
var switchText:UndertaleText = new UndertaleText(0, 0, 'SWITCH', 'center', FlxG.width, 1, 'FFFFFF', 'undertale-outline');
var switchTimer:UndertaleText = new UndertaleText(0, 0, '0:00', 'center', FlxG.width, 1.2, 'FFFFFF', 'crypt');
var switchCamera:FlxCamera = new FlxCamera();
var switchKey:FlxKey;

// ----- 触摸矩形相关 -----
var touchCamera:FlxCamera;
var touchRect:FlxSprite;
var rectRaised:Bool = false;
var rectMoving:Bool = false;
var rectTargetY:Float;
var countdownActive:Bool = false;
var targetSwitchState:Bool = false;
var countdownEnded:Bool = false;
var rectClicked:Bool = false;

// ===== Botplay 检测（通过歌曲存档字段 shrine_botplay）=====
public var isBotPlay:Bool = false;   // 新增全局变量

// ===== 切换延迟（毫秒） =====
var switchDelayMs:Int = 1000;

// ===== 倒计时水平偏移量（受 MiddleScroll 控制）=====
var extraOffset:Int = 108;

function postCreate() {
	// ----- 读取当前歌曲的 Botplay 开关 -----
	try {
		isBotPlay = Reflect.field(FlxG.save.data, 'shrine_botplay') == true;
	} catch (e:Dynamic) {
		isBotPlay = false;
	}

	// 非 Botplay 模式直接返回，不初始化任何内容
	if (!isBotPlay) return;

	if (!FlxG.save.data.shrine_mechanics_allowed) {
		return;
	}

	// ----- 根据 MiddleScroll 决定倒计时是否居中 -----
	var middleScroll = FlxG.save.data.middleScroll == true;
	extraOffset = middleScroll ? 0 : 108;

	if (!playerStrums.cpu) {
		// 原有注释代码（可忽略）
	}
	
	FlxG.cameras.add(switchCamera, false);
	switchCamera.bgColor = FlxColor.TRANSPARENT;
	switchCamera.zoom = 3;
	switchCamera.visible = false;
	
	nSwitch.frames = Paths.getAsepriteAtlas('stages/dogshrine-switch/switch');
	nSwitch.animation.addByPrefix('s', 'Tag0', 8, false);
	nSwitch.animation.timeScale = 1.5;
	nSwitch.animation.play('s', true);
	nSwitch.cameras = [switchCamera];
	nSwitch.screenCenter();
	nSwitch.setPosition((nSwitch.x + 0.5) + extraOffset, nSwitch.y - 14.2);
	add(nSwitch);
	
	switchText.cameras = [switchCamera];
	switchText.screenCenter();
	switchText.setPosition(switchText.x + extraOffset, switchText.y);
	add(switchText);
	
	switchTimer.setPosition(switchText.x, switchText.y + 15.2);
	switchTimer.cameras = [switchCamera];
	switchTimer.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1, 1);
	add(switchTimer);
	
	updateNoteVisibility();

	switchKey = FlxKey.SPACE;
	if (Reflect.field(FlxG.save.data, 'P1_MECH_SWITCH')[0] != null) {
		switchKey = Reflect.field(FlxG.save.data, 'P1_MECH_SWITCH')[0];
	}
	ControlsUtil.addKeysToCustomControl(PlayerSettings.solo.controls, 'MECH_SWITCH', [switchKey, 0]);
	keyString = CoolUtil.keyToString(switchKey);
	trace(keyString);

	// ----- 创建触摸切换图片（SP.png）-----
	touchCamera = new FlxCamera();
	touchCamera.bgColor = FlxColor.TRANSPARENT;
	touchCamera.zoom = 1;
	touchCamera.antialiasing = false;
	FlxG.cameras.add(touchCamera, false);

	touchRect = new FlxSprite();
	touchRect.loadGraphic(Paths.image('SP'));
	touchRect.scale.x = FlxG.width / touchRect.width;
	touchRect.scale.y = touchRect.scale.x;
	touchRect.updateHitbox();
	touchRect.alpha = 1;
	touchRect.color = FlxColor.WHITE;
	touchRect.cameras = [touchCamera];
	touchRect.screenCenter(FlxAxes.X);
	touchRect.y = FlxG.height;
	rectTargetY = FlxG.height - touchRect.height;
	touchRect.visible = false;
	add(touchRect);
}

// ----- 工具函数 -----
function getNextNoteTimeOfColor(color:Bool):Float {
	if (!isBotPlay) return 0;  // 安全起见
	var lookingFor = color ? 'Blue Side Note' : 'Red Side Note';
	for (note in playerStrums.notes) {
		if (note != null && note.noteType == lookingFor && note.strumTime > inst.time) {
			return note.strumTime;
		}
	}
	return 0;
}

function nextNoteTime() {
	if (!isBotPlay) return 0;
	var lookingFor = (switched ? 'Red Side Note' : 'Blue Side Note');
	var closestTime:Float = Math.POSITIVE_INFINITY;
	var found:Bool = false;
	for (note in playerStrums.notes) {
		if (note != null && note.noteType == lookingFor && note.strumTime > inst.time) {
			if (note.strumTime < closestTime) {
				closestTime = note.strumTime;
				found = true;
			}
		}
	}
	return found ? closestTime : 0;
}

function getNextSpecialNote():{time:Float, isBlue:Bool} {
	if (!isBotPlay) return null;
	var closestTime:Float = Math.POSITIVE_INFINITY;
	var closestIsBlue:Bool = false;
	var found:Bool = false;
	for (note in playerStrums.notes) {
		if (note != null && (note.noteType == 'Red Side Note' || note.noteType == 'Blue Side Note')) {
			if (note.strumTime > inst.time && note.strumTime < closestTime) {
				closestTime = note.strumTime;
				closestIsBlue = (note.noteType == 'Blue Side Note');
				found = true;
			}
		}
	}
	if (!found) return null;
	return {time: closestTime, isBlue: closestIsBlue};
}

function updateNoteVisibility() {
	if (!isBotPlay) return;
	if (!FlxG.save.data.shrine_mechanics_allowed) return;
	for (note in playerStrums.notes) {
		if (note != null) {
			if (note.noteType == 'Red Side Note') { note.canBeHit = !switched; note.alpha = (switched ? 0.5 : 1); }
			if (note.noteType == 'Blue Side Note') { note.canBeHit = switched; note.alpha = (switched ? 1 : 0.5); }
		}
	}
}

function onNoteHit(e) {
	if (!isBotPlay) return;
	if (!FlxG.save.data.shrine_mechanics_allowed) return;
	if (!e.note.strumLine.cpu) {
		if (e.note.noteType == 'Red Side Note') {
			if (switched) {
				e.cancel();
				e.preventDeletion();
				e.note.wasGoodHit = false;
				playerStrums.notes.remove(e.note.strumID);
			}
		} else if (e.note.noteType == 'Blue Side Note') {
			if (!switched) {
				e.cancel();
				e.preventDeletion();
				e.note.wasGoodHit = false;
				playerStrums.notes.remove(e.note.strumID);
			}
		}
		updateTime();
	}
}

var timeLeft = 0;
var switchThreshold = 1000;
var timeAlertPart = 0;
var oldPart = 4;
var thresholdQuarter = switchThreshold / 4;
var part:Int = 0;
var playOnce = false;

function startRise() {
	if (!isBotPlay) return;
	if (!rectMoving && !rectRaised) {
		touchRect.visible = true;
		touchRect.alpha = 1;
		touchRect.color = FlxColor.WHITE;
		rectMoving = true;
		rectClicked = false;
		FlxTween.tween(touchRect, {y: rectTargetY}, 0.4, {
			ease: FlxEase.quartOut,
			onComplete: function() {
				rectRaised = true;
				rectMoving = false;
			}
		});
	}
}

function startFall() {
	if (!isBotPlay) return;
	if (!rectMoving && rectRaised) {
		rectMoving = true;
		FlxTween.tween(touchRect, {y: FlxG.height}, 0.4, {
			ease: FlxEase.quartOut,
			onComplete: function() {
				rectRaised = false;
				rectMoving = false;
				touchRect.visible = false;
			}
		});
	}
}

function doSwitch() {
	if (!isBotPlay) return;
	if (!playerStrums.cpu && switchCamera.visible) {
		if (part != 0) {
			switchText.text = 'oh okay :(';
		}
		switched = !switched;
		updateSwitch();
		if (rectRaised && !rectMoving) {
			startFall();
		}
	}
}

function update() {
	if (!isBotPlay) return;
	if (!FlxG.save.data.shrine_mechanics_allowed) return;
	
	if (timeText != null) {
		switchAlert.updateHitbox();
		switchAlert.screenCenter();
		switchTimer.y = switchAlert.y - 30;
	}

	timeLeft = trackedTime - inst.time;
	countdownActive = (timeLeft > 0 && timeLeft < switchThreshold);
	
	if (countdownActive) {
		switchCamera.alpha = 1;
	} else {
		if (switchCamera.alpha >= 1) {
			FlxTween.tween(switchCamera, {alpha: 0}, (Conductor.stepCrochet / 1000) * 2, {onComplete: function() {
				switchText.text = 'READY. . .';
			}});
		}
	}
	
	if (countdownActive) {
		if (!isBotPlay) {
			if (!rectMoving && !rectRaised) {
				startRise();
			}
		} else {
			if (touchRect.visible) touchRect.visible = false;
		}
		
		timeAlertPart = switchThreshold - (switchThreshold - timeLeft);
		part = Math.round(timeAlertPart / thresholdQuarter);
		switchCamera.visible = true;
		if (oldPart != part) {
			oldPart = part;
			switch(part) {
				case 3:
					switchText.text = 'READY. . .';
				case 2:
					switchText.text = 'READY. . .';
				case 1:
					switchText.text = 'SET. . .';
				case 0:
					switchText.text = 'SWITCH!';
			}
			
			if (switchTimer != null) { 
				switchTimer.text = part; 
			}
			if (part != 0) {
				if (!playerStrums.cpu) { FlxG.sound.play(Paths.sound('switchpull')); }
			}
		}
		
		if (part == 0 && !playOnce) {
			FlxG.sound.play(Paths.sound('switchpull'));
			if (isBotPlay) {
				switched = !switched;
				updateSwitch();
				touchRect.visible = false;
				rectRaised = false;
				rectMoving = false;
			} else if (playerStrums.cpu) {
				switched = !switched;
				updateSwitch();
			}
			playOnce = true;
			countdownEnded = true;
			oldPart = 4;
		}
	} else {
		if (!isBotPlay) {
			if (rectRaised && !rectMoving) {
				var nextNote = getNextSpecialNote();
				if (nextNote != null) {
					if (switched == nextNote.isBlue) {
						startFall();
					}
				} else {
					startFall();
				}
			}
		}
	}

	if (!isBotPlay && rectRaised && !rectMoving && touchRect.visible && !rectClicked) {
		for (touch in FlxG.touches.list) {
			if (touch.justReleased) {
				var touchPoint = touch.getWorldPosition(touchCamera);
				if (touchRect.overlapsPoint(touchPoint, false, touchCamera)) {
					rectClicked = true;
					touchRect.color = FlxColor.YELLOW;
					doSwitch();
					break;
				}
			}
		}
	}

	if (!isBotPlay && controls.getJustPressed('MECH_SWITCH') && !playerStrums.cpu && switchCamera.visible) {
		doSwitch();
	}
	
	if (controls.getJustPressed('MECH_SWITCH')) {
		trace('hey');
	}
}

function stepHit(curStep:Int) {
	if (!isBotPlay) return;
	if (!FlxG.save.data.shrine_mechanics_allowed) return;
	updateTime();
}

function updateTime() {
	if (!isBotPlay) return;
	playOnce = false;
	trackedTime = nextNoteTime() + switchDelayMs - switchThreshold;
	if (timeText != null) { timeText.text = trackedTime; }
}

function updateSwitch() {
	if (!isBotPlay) return;
	FlxG.sound.play(Paths.sound('snd_lightswitch'));
	var color:FlxColor = (switched ? FlxColor.fromString('#00CCFF') : FlxColor.fromString('#FF0033'));
	nSwitch.animation.play('s', true, !switched);
	for (t in [nSwitch, switchTimer, switchText]) {
		t.color = color;
		FlxTween.color(t, (Conductor.stepCrochet / 1000) * 4, color, FlxColor.WHITE);
	}
	updateNoteVisibility();
}

// ----- 外部调用的位置重置函数 -----
function strumChange() {
	if (!isBotPlay) return;
	// 无论 MiddleScroll 状态，都强制居中（没有额外偏移）
	for (t in [nSwitch, switchText, switchTimer]) {
		t.screenCenter(FlxAxes.X);
	}
}

function strumNormal() {
	if (!isBotPlay) return;
	// 根据当前 extraOffset 恢复位置（MiddleScroll 开启时 extraOffset = 0，即保持居中）
	nSwitch.setPosition((nSwitch.x + 0.5) + extraOffset, nSwitch.y - 14.2);
	switchText.setPosition(switchText.x + extraOffset, switchText.y);
	switchTimer.setPosition(switchText.x, switchText.y + 15.2);
}

function okDone() {
	if (!isBotPlay) return;
	switchCamera.visible = false;
}