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

// ===== Botplay 检测 =====
public var isBotPlay:Bool = false;

// ===== Middle Scroll 偏移量 =====
var extraOffset:Int = 108;

// ===== 允许下一次倒计时 =====
var allowNextCountdown:Bool = true;

// ===== 实时检测开关和冷却 =====
var realTimeCheckEnabled:Bool = true;   // 是否允许实时检测
var cooldownTimer:FlxTimer = null;      // 冷却定时器

function postCreate() {
	// 读取 Botplay
	try {
		isBotPlay = Reflect.field(FlxG.save.data, 'shrine_botplay') == true;
	} catch (e:Dynamic) {
		isBotPlay = false;
	}
	if (isBotPlay) return;

	if (!FlxG.save.data.shrine_mechanics_allowed) return;

	// 根据 Middle Scroll 设置偏移
	var middleScroll = FlxG.save.data.middleScroll == true;
	extraOffset = middleScroll ? 0 : 108;

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

	// 触摸图片
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

	// 默认启用实时检测
	realTimeCheckEnabled = true;
}

// ----- 工具函数 -----
function getNextNoteTimeOfColor(color:Bool):Float {
	if (isBotPlay) return 0;
	var lookingFor = color ? 'Blue Side Note' : 'Red Side Note';
	var groupLength = playerStrums.notes.length - 1;
	for (i in 0...groupLength) {
		var id = groupLength - i;
		var note = playerStrums.notes.members[id];
		if (note != null && note.noteType == lookingFor) {
			return note.strumTime;
		}
	}
	return 0;
}

function nextNoteTime() {
	if (isBotPlay) return 0;
	var lookingFor = (switched ? 'Red Side Note' : 'Blue Side Note');
	var groupLength = playerStrums.notes.length - 1;
	for (i in 0...groupLength) {
		var id = groupLength - i;
		var note = playerStrums.notes.members[id];
		if (note != null && note.noteType == lookingFor) {
			return note.strumTime;
		}
	}
	return 0;
}

function getNextSpecialNote():{time:Float, isBlue:Bool} {
	if (isBotPlay) return null;
	var groupLength = playerStrums.notes.length - 1;
	var closestTime:Float = Math.POSITIVE_INFINITY;
	var closestIsBlue:Bool = false;
	var found:Bool = false;
	var currentTime = inst.time;
	for (i in 0...groupLength) {
		var id = groupLength - i;
		var note = playerStrums.notes.members[id];
		if (note != null && (note.noteType == 'Red Side Note' || note.noteType == 'Blue Side Note')) {
			if (note.strumTime > currentTime + 0.001) {
				if (note.strumTime < closestTime) {
					closestTime = note.strumTime;
					closestIsBlue = (note.noteType == 'Blue Side Note');
					found = true;
				}
			}
		}
	}
	if (!found) return null;
	return {time: closestTime, isBlue: closestIsBlue};
}

function updateNoteVisibility() {
	if (isBotPlay) return;
	if (!FlxG.save.data.shrine_mechanics_allowed) return;
	var groupLength = playerStrums.notes.length - 1;
	for (i in 0...groupLength) {
		var id = groupLength - i;
		var note = playerStrums.notes.members[id];
		if (note != null) {
			if (note.noteType == 'Red Side Note') { note.canBeHit = !switched; note.alpha = (switched ? 0.5 : 1); }
			if (note.noteType == 'Blue Side Note') { note.canBeHit = switched; note.alpha = (switched ? 1 : 0.5); }
		}
	}
}

function onNoteHit(e) {
	if (isBotPlay) return;
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

// ----- 上升 -----
function startRise() {
	if (isBotPlay) return;
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

// ----- 下降（SP 落下）-----
function startFall() {
	if (isBotPlay) return;
	if (!rectMoving && rectRaised) {
		rectMoving = true;
		FlxTween.tween(touchRect, {y: FlxG.height}, 0.4, {
			ease: FlxEase.quartOut,
			onComplete: function() {
				rectRaised = false;
				rectMoving = false;
				touchRect.visible = false;
				// 下降完成后允许新的倒计时
				allowNextCountdown = true;
				playOnce = false;
				countdownEnded = false;
			}
		});
	}
}

// ----- 执行切换（玩家按 SP）-----
function doSwitch() {
	if (isBotPlay) return;
	// 如果玩家主动切换，取消冷却定时器（不影响实时检测状态，但避免冲突）
	if (cooldownTimer != null) {
		cooldownTimer.cancel();
		cooldownTimer = null;
		// 无需重新启用 realTimeCheckEnabled，因为接下来会下降或保持
	}
	if (!playerStrums.cpu && switchCamera.visible) {
		if (part != 0) {
			switchText.text = 'oh okay :(';
		}
		switched = !switched;
		updateSwitch();
		if (rectRaised && !rectMoving) {
			startFall();  // 下降并重置 allowNextCountdown
		}
	}
}

// ----- 启动冷却（倒计时结束后禁用实时检测 1 秒）-----
function startCooldown() {
	if (cooldownTimer != null) {
		cooldownTimer.cancel();
		cooldownTimer = null;
	}
	realTimeCheckEnabled = false;   // 禁止实时检测
	cooldownTimer = new FlxTimer().start(1.0, function(t) {
		cooldownTimer = null;
		realTimeCheckEnabled = true; // 恢复实时检测
	});
}

function update() {
	if (isBotPlay) return;
	if (!FlxG.save.data.shrine_mechanics_allowed) return;
	
	if (timeText != null) {
		switchAlert.updateHitbox();
		switchAlert.screenCenter();
		switchTimer.y = switchAlert.y - 30;
	}

	// 计算倒计时状态
	timeLeft = trackedTime - inst.time;
	countdownActive = (timeLeft > 0 && timeLeft < switchThreshold);
	
	// 显示/隐藏倒计时 UI
	if (countdownActive && allowNextCountdown) {
		switchCamera.alpha = 1;
	} else {
		if (switchCamera.alpha >= 1) {
			FlxTween.tween(switchCamera, {alpha: 0}, (Conductor.stepCrochet / 1000) * 2, {onComplete: function() {
				switchText.text = 'READY. . .';
			}});
		}
	}
	
	// 倒计时逻辑（只在允许且活跃时）
	if (countdownActive && allowNextCountdown) {
		// 上升 SP
		if (!rectMoving && !rectRaised) {
			startRise();
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
		
		// 倒计时结束（part == 0）
		if (part == 0 && !playOnce) {
			FlxG.sound.play(Paths.sound('switchpull'));
			if (playerStrums.cpu) {
				// CPU 模式自动切换
				switched = !switched;
				updateSwitch();
			}
			playOnce = true;
			countdownEnded = true;
			// 禁止下一次倒计时，直到 SP 下降
			allowNextCountdown = false;
			oldPart = 4;
			
			// 启动冷却：禁用实时检测 1 秒
			startCooldown();
		}
	} else {
		// ----- 非倒计时状态：实时检测 -----
		// 条件：SP 已升起、未在移动、实时检测开启
		if (rectRaised && !rectMoving && realTimeCheckEnabled) {
			var nextNote = getNextSpecialNote();
			if (nextNote != null) {
				// 如果当前颜色与下一个音符的颜色匹配（即不需要切换），则下降
				if (switched == nextNote.isBlue) {
					startFall(); // 下降，其 complete 中会重置 allowNextCountdown = true
				}
			} else {
				// 没有后续特殊音符，也可以下降（结束提示），根据设计决定
				// 这里保持原逻辑：下降
				startFall();
			}
		}
	}

	// 触摸检测（点击 SP 图片）
	if (rectRaised && !rectMoving && touchRect.visible && !rectClicked) {
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

	// 键盘/手柄切换
	if (controls.getJustPressed('MECH_SWITCH') && !playerStrums.cpu && switchCamera.visible) {
		doSwitch();
	}
	
	if (controls.getJustPressed('MECH_SWITCH')) {
		trace('hey');
	}
}

function stepHit(curStep:Int) {
	if (isBotPlay) return;
	if (!FlxG.save.data.shrine_mechanics_allowed) return;
	updateTime();
}

function updateTime() {
	if (isBotPlay) return;
	playOnce = false;
	trackedTime = nextNoteTime() - thresholdQuarter;
	if (timeText != null) { timeText.text = trackedTime; }
}

function updateSwitch() {
	if (isBotPlay) return;
	FlxG.sound.play(Paths.sound('snd_lightswitch'));
	var color:FlxColor = (switched ? FlxColor.fromString('#00CCFF') : FlxColor.fromString('#FF0033'));
	nSwitch.animation.play('s', true, !switched);
	for (t in [nSwitch, switchTimer, switchText]) {
		t.color = color;
		FlxTween.color(t, (Conductor.stepCrochet / 1000) * 4, color, FlxColor.WHITE);
	}
	updateNoteVisibility();
}

function strumChange() {
	if (isBotPlay) return;
	for (t in [nSwitch, switchText, switchTimer]) {
		t.screenCenter(FlxAxes.X);
	}
}

function strumNormal() {
	if (isBotPlay) return;
	var middleScroll = FlxG.save.data.middleScroll == true;
	extraOffset = middleScroll ? 0 : 108;
	nSwitch.setPosition((nSwitch.x + 0.5) + extraOffset, nSwitch.y - 14.2);
	switchText.setPosition(switchText.x + extraOffset, switchText.y);
	switchTimer.setPosition(switchText.x, switchText.y + 15.2);
}

function okDone() {
	if (isBotPlay) return;
	switchCamera.visible = false;
}