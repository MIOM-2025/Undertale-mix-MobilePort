import UndertaleText;
import Math;
import funkin.editors.charter.Charter;
import flixel.util.FlxStringUtil;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.addons.display.FlxBackdrop;

var pause:FlxCamera = new FlxCamera();
var pauseButtons:Array<Dynamic> = [];
var buttonSelected:Int = 0;
var options:Array<String> = [
	'resume',
	'restart',
	'settings',
	'exit'
];
var theme:FlxSound;
var themeVolume:Float = 1;
var pauseTween:FlxTween;

// ========== 键盘/触摸模式管理 ==========
var inputMode:String = "keyboard";     // "keyboard" 或 "touch"
var touchSelectedID:Int = -1;          // 触摸模式下选中的按钮ID，-1表示无选中

// 存储每个按钮的原始X（未选中时组居中的位置）和宽度
var originalX:Array<Float> = [];
var buttonWidths:Array<Float> = [];

function create(e) {
    #if mobile	
    try { removeTouchPad(); } catch (e:Dynamic) { try { removeMobilePad(); } catch (e:Dynamic) { } }
    #end
	e.cancel();
	e.music = 's';
	
	themeVolume = Options.volumeMusic;
	theme = FlxG.sound.load(Paths.music('menuthemes/pause'), themeVolume, true);
	theme.play();
	theme.volume = 0;
	FlxG.sound.defaultMusicGroup.add(theme);
	
	FlxG.cameras.add(pause, false);
	cameras = [pause];
	
	pause.bgColor = 0x7F000000;
	pause.zoom = 1.5;
	pause.alpha = 0;
	pause.antialiasing = false;
	pauseTween = FlxTween.tween(pause, {alpha: 1, zoom: 2}, 0.5, {ease: FlxEase.cubeOut});
	
	var backdrop:FlxBackdrop = new FlxBackdrop(Paths.image('pause/bg'));
	backdrop.velocity.set(20, 20);
	add(backdrop);
	
	var titleBack:FlxText = new FlxText(0, 0, FlxG.width, PlayState.SONG.meta.displayName.toLowerCase());
	titleBack.setFormat(Paths.font('title_B.ttf'), 48, FlxColor.GRAY, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE);
	titleBack.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
	titleBack.screenCenter();
	titleBack.y -= 111;
	add(titleBack);
	
	var titleTop:FlxText = new FlxText(titleBack.x, titleBack.y, FlxG.width, PlayState.SONG.meta.displayName.toLowerCase());
	titleTop.setFormat(Paths.font('title_F.ttf'), 48, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.NONE);
	add(titleTop);
	
	var time:UndertaleText = new UndertaleText(0, titleTop.y + 40, '(' + getTime() + ' - ' + getSongLength() + ')', 'left', FlxG.width, 2, 'FFFFFF', 'crypt');
	time.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1, 1);
	time.autoSize = true;
	time.updateHitbox();
	time.screenCenter(FlxAxes.X);
	add(time);
	
	// ---------- 创建按钮（y固定为434） ----------
	var distance:Int = 10; // 间距缩小至10
	var buttonY:Float = 434;
	var totalWidth:Float = 0;
	var tempButtons:Array<FlxSprite> = [];
	
	// 先创建所有按钮，获取宽度
	for (option in options) {
		var button:FlxSprite = new FlxSprite(0, buttonY).loadGraphic(Paths.image('pause/' + option));
		button.ID = tempButtons.length;
		tempButtons.push(button);
		totalWidth += button.width;
	}
	// 加上间距
	totalWidth += (tempButtons.length - 1) * distance;
	
	// 计算第一个按钮的x，使整体居中
	var firstX:Float = (FlxG.width - totalWidth) / 2;
	var curX:Float = firstX;
	
	for (i in 0...tempButtons.length) {
		var btn = tempButtons[i];
		btn.x = curX;
		// 保存原始x和宽度
		originalX.push(curX);
		buttonWidths.push(btn.width);
		pauseButtons.push([
			btn,
			curX,   // 原始x
			i       // id
		]);
		add(btn);
		curX += btn.width + distance;
	}
	
	// ---------- 初始模式设置 ----------
	#if mobile
		inputMode = "touch";
	#else
		inputMode = "keyboard";
	#end
	initializeMode();
}

// ========== 模式初始化 ==========
function initializeMode() {
	if (inputMode == "keyboard") {
		buttonSelected = 0;
		touchSelectedID = -1;
		updateSelection(0);
	} else {
		buttonSelected = -1;
		touchSelectedID = -1;
		// 所有按钮恢复原始位置，白色，正常大小
		for (i in 0...pauseButtons.length) {
			var btn = pauseButtons[i][0];
			btn.x = originalX[i];
			btn.scale.set(1, 1);
			btn.color = FlxColor.WHITE;
		}
	}
}

// ========== 模式切换 ==========
function switchToTouch() {
	if (inputMode == "touch") return;
	inputMode = "touch";
	// 清除键盘选中状态
	buttonSelected = -1;
	touchSelectedID = -1;
	// 所有按钮回到原始位置（动画会在循环中处理）
}

function switchToKeyboard() {
	if (inputMode == "keyboard") return;
	inputMode = "keyboard";
	// 清除触摸选中
	touchSelectedID = -1;
	buttonSelected = 0;
	updateSelection(0);
}

var lerp:Float = 0;
var distance:Int = 10; // 与上方保持一致
var baseScale:Float = 0.8;
var volumeCap:Float = 0.7;
var fadeTime:Int = 0.1;
var exiting:Bool = false;

function update(elapsed) {
    #if mobile	
    try { removeTouchPad(); } catch (e:Dynamic) { try {removeMobilePad(); } catch (e:Dynamic) { } }
    #end
	// ========== 模式切换检测 ==========
	if (inputMode == "keyboard") {
		if (FlxG.mouse.justPressed) {
			switchToTouch();
		}
	} else { // touch
		if (controls.LEFT_P || controls.RIGHT_P || controls.UP_P || controls.DOWN_P || controls.ACCEPT) {
			switchToKeyboard();
		}
	}
	
	if (exiting) {
		return;
	}
	
	if (theme.volume < volumeCap * Options.volumeMusic && !exiting) {
		theme.volume += (volumeCap / 4) * elapsed;
	}
	
	// ==========================================
	// 键盘模式
	// ==========================================
	if (inputMode == "keyboard") {
		if (controls.ACCEPT) {
			var curOption:String = options[buttonSelected];
			// 添加选择音效（与Freeplay进入卡片时相同）
			FlxG.sound.play(Paths.sound('select'), Options.volumeSFX);
			exiting = true;
			theme.fadeOut(fadeTime, 0);
			switch(curOption) {
				case 'resume':
					if (pauseTween != null) pauseTween.cancel();
					pauseTween = FlxTween.tween(pause, {alpha: 0, zoom: 1.5}, fadeTime, {ease: FlxEase.cubeOut, onComplete: function() {
						close();
					}});
				case 'restart':
					pause.fade(FlxColor.BLACK, fadeTime, false, function() {
						PlayState.instance.camGame.visible = PlayState.instance.camHUD.visible = false;
						FlxG.resetState();
					}, false);
				case 'settings':
					pause.fade(FlxColor.BLACK, fadeTime, false, function() {
						PlayState.instance.camGame.visible = PlayState.instance.camHUD.visible = false;
						FlxG.switchState(new ModState('MixedOptions', true));
					}, false);
				case 'exit':
					if (PlayState.chartingMode && Charter.undos.unsaved) {
						game.saveWarn(false);
						exiting = false;
					} else {
						pause.fade(FlxColor.BLACK, fadeTime, false, function() {
							PlayState.instance.camGame.visible = PlayState.instance.camHUD.visible = false;
							FlxG.switchState(PlayState.isStoryMode ? new StoryMenuState() : new ModState('MixedFreeplayState'));
						}, false);
					}
			}
		} else if (controls.LEFT_P) {
			updateSelection(-1);
		} else if (controls.RIGHT_P) {
			updateSelection(1);
		}
	}
	
	// ==========================================
	// 触摸模式
	// ==========================================
	if (inputMode == "touch") {
		var mousePoint = FlxG.mouse.getWorldPosition(pause);
		
		// 检测点击（justReleased）
		if (FlxG.mouse.justReleased) {
			var clickedID:Int = -1;
			for (i in 0...pauseButtons.length) {
				var btn = pauseButtons[i][0];
				if (btn.visible && btn.overlapsPoint(mousePoint, false, pause)) {
					clickedID = i;
					break;
				}
			}
			
			if (clickedID != -1) {
				if (touchSelectedID == -1) {
					touchSelectedID = clickedID;
					FlxG.sound.play(Paths.sound('squeak'), Options.volumeSFX);
				} else if (touchSelectedID == clickedID) {
					var curOption:String = options[clickedID];
					// 添加选择音效（与Freeplay进入卡片时相同）
					FlxG.sound.play(Paths.sound('select'), Options.volumeSFX);
					exiting = true;
					theme.fadeOut(fadeTime, 0);
					switch(curOption) {
						case 'resume':
							if (pauseTween != null) pauseTween.cancel();
							pauseTween = FlxTween.tween(pause, {alpha: 0, zoom: 1.5}, fadeTime, {ease: FlxEase.cubeOut, onComplete: function() {
								close();
							}});
						case 'restart':
							pause.fade(FlxColor.BLACK, fadeTime, false, function() {
								PlayState.instance.camGame.visible = PlayState.instance.camHUD.visible = false;
								FlxG.resetState();
							}, false);
						case 'settings':
							pause.fade(FlxColor.BLACK, fadeTime, false, function() {
								PlayState.instance.camGame.visible = PlayState.instance.camHUD.visible = false;
								FlxG.switchState(new ModState('MixedOptions', true));
							}, false);
						case 'exit':
							if (PlayState.chartingMode && Charter.undos.unsaved) {
								game.saveWarn(false);
								exiting = false;
							} else {
								pause.fade(FlxColor.BLACK, fadeTime, false, function() {
									PlayState.instance.camGame.visible = PlayState.instance.camHUD.visible = false;
									FlxG.switchState(PlayState.isStoryMode ? new StoryMenuState() : new ModState('MixedFreeplayState'));
								}, false);
							}
					}
				} else {
					touchSelectedID = clickedID;
					FlxG.sound.play(Paths.sound('squeak'), Options.volumeSFX);
				}
			} else {
				if (touchSelectedID != -1) {
					touchSelectedID = -1;
					FlxG.sound.play(Paths.sound('squeak'), Options.volumeSFX);
				}
			}
		}
	}
	
	// ========== 统一动画更新 ==========
	var selectedID:Int = -1;
	if (inputMode == "keyboard") {
		selectedID = buttonSelected;
	} else {
		selectedID = touchSelectedID;
	}
	
	var targetX:Array<Float> = [];
	if (selectedID == -1) {
		for (i in 0...pauseButtons.length) {
			targetX.push(originalX[i]);
		}
	} else {
		var centerX:Float = (FlxG.width - buttonWidths[selectedID]) / 2;
		var offset:Float = centerX - originalX[selectedID];
		for (i in 0...pauseButtons.length) {
			targetX.push(originalX[i] + offset);
		}
	}
	
	lerp = Math.exp(-elapsed * 24.6);
	for (i in 0...pauseButtons.length) {
		var btn = pauseButtons[i][0];
		var isSelected = (i == selectedID);
		btn.x = FlxMath.lerp(targetX[i], btn.x, lerp);
		var targetScale = isSelected ? 1.0 : baseScale;
		btn.scale.set(
			FlxMath.lerp(targetScale, btn.scale.x, lerp / 2),
			FlxMath.lerp(targetScale, btn.scale.y, lerp / 2)
		);
		btn.color = isSelected ? FlxColor.YELLOW : FlxColor.WHITE;
	}
}

function updateSelection(?v:Int) {
	if (exiting) return;
	if (inputMode != "keyboard") return;
	
	if (v != null) {
		buttonSelected += v;
	}
	if (buttonSelected > pauseButtons.length - 1) {
		buttonSelected = 0;
	} else if (buttonSelected < 0) {
		buttonSelected = pauseButtons.length - 1;
	}
	FlxG.sound.play(Paths.sound('squeak'), Options.volumeSFX);
}

function getTime() {
	if (Conductor.songPosition > 0) {
		var currentTime:Float = Math.max(0, Conductor.songPosition);
		var time:Int = Math.floor(currentTime / 1000);
		return CoolUtil.addZeros(FlxStringUtil.formatTime(time), 5);
	} else {
		return '00:00';
	}
}

function getSongLength() {
	return CoolUtil.addZeros(FlxStringUtil.formatTime(PlayState.instance.inst.length / 1000), 5);
}