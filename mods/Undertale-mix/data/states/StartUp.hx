import flixel.math.FlxRandom;
import flixel.tweens.FlxTweenType;

import funkin.backend.utils.DiscordUtil;

import UndertaleText;
import Sys;

// ========== 可调整的触控点击宽度（单位：像素） ==========
var touchWidthLetter:Int = 20;      // 字母（A-Z，a-z）的点击宽度
var touchWidthBackspace:Int = 60;   // "Backspace" 按钮的点击宽度
var touchWidthDone:Int = 35;        // "Done" 按钮的点击宽度
var touchWidthYes:Int = 20;         // 命名确认时的 "Yes" 按钮宽度
var touchWidthNo:Int = 20;          // 命名确认时的 "No" 按钮宽度

// ========== 原有变量 ==========
var letterLanes:Map<Int, Array<String>> = [];
var letterObjects:Map<Int, Array<UndertaleText>> = [];
var lettersArray:Array<UndertaleText> = [];
var mapLength:Int = 0;
var letters:String = 'ABCDEFG/HIJKLMN/OPQRSTU/VWXYZ/abcdefg/hijklmn/opqrstu/vwxyz/';
var offsetValue:Int = 0.3;

// 特殊名字字典（保留原始大小写，匹配时忽略大小写）
var specialNames = [
	'frisk' => ['WARNING: This name will\nmake your life hell.\nProceed anyway?'],
	'chara' => ['The true name.'],
	'' => ['You must choose a name.', false],
	'asgore' => ['You cannot.', false],
	'toriel' => ['I think you should\nthink of your own\nname, my child', false],
	'sans' => ['nope.', false],
	'undyne' => ['Get your OWN name!', false],
	'flowey' => ['I already CHOSE\nthat name.', false],
	'alphys' => ['D-don\'t do that.'],
	'alphy' => ['Uh.... OK?'],
	'papyru' => ['I\'LL ALLOW IT!!!!'],
	'napsta' => ['............\n(They\'re powerless to\nstop you.)'],
	'blooky' => ['............\n(They\'re powerless to\nstop you.)'],
	'murder' => ['That\'s a little on-\nthe-nose, isn\'t it...?'],
	'mercy' => ['That\'s a little on-\nthe-nose, isn\'t it...?'],
	'singin' => ['That\'s a little on-\nthe-nose, isn\'t it...?'],
	'funkin' => ['On a friday night.'],
	'clover' => ['You don\'t look the type\nto truly deliver justice.', false],
	'dlover' => ['What kind of name is that?'],
	'dlowey' => ['What kind of name is that?'],
	'lucky' => ['Taken.', false],
	'venus' => ['Thats MY name, idiot!', false],
	'gerson' => ['I\'m old!'],
	'catty' => ['Bratty! Bratty!\nThat\'s MY name!'],
	'bratty' => ['Like, OK I guess.'],
	'MTT' => ['OOOOH!!! ARE YOU\nPROMOTING MY BRAND?'],
	'metta' => ['OOOOH!!! ARE YOU\nPROMOTING MY BRAND?'],
	'mett' => ['OOOOH!!! ARE YOU\nPROMOTING MY BRAND?'],
	'shyren' => ['...?'],
	'aaron' => ['Is this name correct? ; )'],
	'temmie' => ['h0I!'],
	'woshua' => ['Clean name.'],
	'jerry' => ['Jerry.'],
	'bpants' => ['You are really scraping the\nbottom of the barrel.'],
	'asriel' => ['...', false],
	'parchy' => ['UM... I GUESS I\'LL\nALLOW IT?'],
	'toby' => ['(Bark, bark!)'],
	'cakie' => ['Shoo, FROGGIT.', false],
	'dragon' => ['That\'s a cool name.'],
	'drago' => ['That\'s a cool name.'],
	'yeetus' => ['Fuh nah...', false],
	'bug' => [':eyes:'],
	'goku' => ['Hey, it\'s me, Goku!'],
	'frieza' => ['Filthy, MONKEY!', false],
	'pepz' => ['NO!!! >:  (', false],
	'awsome' => ['hey so like that name is already\nin use or something lmao\ngo choose something else', false],
	'julio' => ['empanadas'],
	'MIOM' => ['Uh, you have no idea how hard it is to add touch to this UI.'],
	// ---------- 新增两个名字（大小写均可匹配） ----------
	'Luzew' => ['I\'d love to see you come undone ^p^'],   // 允许使用
	'Xenith' => ['Whoa, are you going for the SFC rank too?'] // 允许使用
];
var nameAllowed:Bool = true;
var texts:Array<String>;
var prompts:Array<String>;

var curSelected:Int = 0;
var laneSelected:Int = 0;

var name:UndertaleText;
var topText:UndertaleText;
var flavorText:UndertaleText;

var camera:FlxCamera = new FlxCamera();
var camZoom:Float = 3.0;
var r:FlxRandom = new FlxRandom();

// ========== 模式管理 ==========
var inputMode:String = "keyboard"; // "keyboard" 或 "touch"
var hoveredObject:UndertaleText = null; // 触控模式下悬停的对象

function create() {
	DiscordUtil.changePresenceAdvanced({
		details: 'Picking a name',
	});
	
	FlxG.cameras.add(camera, false);
	camera.bgColor = FlxColor.TRANSPARENT;
	camera.antialiasing = false;
	camera.zoom = camZoom;
	this.cameras = [camera];
	
	// ---------- 解析字母矩阵 ----------
	var splits:Array<String> = letters.split('');
	var index:Int = 0;
	var row:Int = 0;
	var letterRow:Array<String> = [];
	for (letter in splits) {
		if (letter == '/') {
			letterLanes.set(row, letterRow);
			letterRow = [];
			row++;
			index = 0;
		}
		if (letter != '/') { letterRow.push(letter); }
		index++;
	}
	
	// ---------- 创建字母对象 ----------
	var mapIndex:Int = 0;
	for (key in letterLanes) {
		var letterIndex:Int = 0;
		var letters:Array<UndertaleText> = [];
		for (l in letterLanes.get(mapIndex)) {
			var letter:UndertaleText = new UndertaleText(550 + (27 * letterIndex), 310 + (14 * mapIndex), l, 'left', FlxG.width, 1, 'FFFFFF', 'undertale-pixel');
			letter.ID = letterIndex;
			letter.fieldWidth = touchWidthLetter; // 使用字母触控宽度
			add(letter);
			lettersArray.push(letter);
			letters.push(letter);
			letterIndex++;
		}
		letterObjects.set(mapIndex, letters);
		mapIndex++;
	}
	mapLength = mapIndex;
	
	// ---------- 名字输入框 ----------
	name = new UndertaleText(610, 290, (FlxG.save.data.playerName == null ? '' : FlxG.save.data.playerName), 'left', FlxG.width, 1, 'FFFFFF', 'undertale-pixel');
	add(name);
	
	// ---------- 顶部随机提示 ----------
	texts = CoolUtil.coolTextFile(Paths.txt('nameflavortext'));
	topText = new UndertaleText(2, 264, texts[r.int(0, texts.length - 1)], 'center', FlxG.width, 1, 'FFFFFF', 'undertale-pixel');
	add(topText);
	
	// ---------- 功能按钮 ----------
	var backspace:UndertaleText = new UndertaleText(556, 428, 'Backspace', 'left', FlxG.width, 1, 'FFFFFF', 'undertale-pixel');
	backspace.ID = 0;
	backspace.fieldWidth = touchWidthBackspace; // 回退按钮宽度
	add(backspace);
	
	var done:UndertaleText = new UndertaleText(658, 428, 'Done', 'left', FlxG.width, 1, 'FFFFFF', 'undertale-pixel');
	done.ID = 1;
	done.fieldWidth = touchWidthDone; // 结束按钮宽度
	add(done);
	letterObjects.set(8, [backspace, done]);
	mapLength += 1;
	
	prompts = letterObjects.get(8);
	
	// ---------- 初始模式设置（根据平台） ----------
	#if mobile
		inputMode = "touch";
	#else
		inputMode = "keyboard";
	#end
	initializeMode();
	
	// ---------- 飘动动画 ----------
	FlxTween.tween(done, {x: done.x}, 0.03, {type: FlxTweenType.PINGPONG, onComplete: function() {
		for (letter in lettersArray) {
			letter.offset.set(r.float(offsetValue, -offsetValue), r.float(offsetValue, -offsetValue));
		}
	}});
}

// ========== 模式初始化 ==========
function initializeMode() {
	// 清除所有高亮
	for (row in letterObjects) {
		for (obj in row) {
			obj.color = FlxColor.WHITE;
		}
	}
	// 重置选中为 A（第0行第0列）
	curSelected = 0;
	laneSelected = 0;
	if (inputMode == "keyboard") {
		updateSelection(0, 0); // 键盘模式高亮 A
	} else {
		hoveredObject = null; // 触控模式无高亮
	}
}

// ========== 模式切换函数 ==========
function switchToTouch() {
	if (inputMode == "touch") return;
	inputMode = "touch";
	// 清除所有高亮
	for (row in letterObjects) {
		for (obj in row) {
			obj.color = FlxColor.WHITE;
		}
	}
	curSelected = 0;
	laneSelected = 0;
	hoveredObject = null;
}

function switchToKeyboard() {
	if (inputMode == "keyboard") return;
	inputMode = "keyboard";
	for (row in letterObjects) {
		for (obj in row) {
			obj.color = FlxColor.WHITE;
		}
	}
	curSelected = 0;
	laneSelected = 0;
	hoveredObject = null;
	updateSelection(0, 0); // 高亮 A
}

var namingMenu:Bool = false;

function update(elapsed:Float) {
	// ========== 模式切换检测 ==========
	if (inputMode == "keyboard") {
		// 鼠标左键（点击任意位置）→ 切换到触控模式
		if (FlxG.mouse.justPressed) {
			switchToTouch();
			return; // 本次不处理其他输入
		}
	} else { // touch
		// 按下方向键或回车键 → 切换到键盘模式
		if (controls.LEFT_P || controls.RIGHT_P || controls.UP_P || controls.DOWN_P || controls.ACCEPT) {
			switchToKeyboard();
			// 切换后继续执行后续键盘逻辑，以便本次按键生效
		}
	}
	
	// ==========================================
	// 键盘模式
	// ==========================================
	if (inputMode == "keyboard") {
		if (controls.ACCEPT) {
			var letter:UndertaleText = letterObjects.get(laneSelected)[curSelected];
			if (!namingMenu) {
				switch(letter.text) {
					case 'Backspace':
						name.text = name.text.substring(0, name.text.length - 1);
					case 'Done':
						nameAccept();
					default:
						if (name.text.length < 6) {
							name.text = name.text + letter.text;
							if (name.text.toLowerCase() == 'gaster') {
								Sys.exit();
							}
						}
				}
			} else {
				switch(letter.text) {
					case 'Yes':
						FlxG.save.data.playerName = name.text;   // 保存原始输入（保留大小写）
						FlxG.save.flush();
						if (data != null) {
							FlxG.switchState(new ModState('ModMainMenu', data));
						} else {
							FlxG.switchState(new MainMenuState());
						}
					case 'No':
						returnName();
				}
			}
		}
		
		if (controls.LEFT_P) {
			updateSelection(-1);
		} else if (controls.RIGHT_P) {
			updateSelection(1);
		} else if (controls.UP_P) {
			updateSelection(null, -1);
		} else if (controls.DOWN_P) {
			updateSelection(null, 1);
		}
	}
	
	// ==========================================
	// 触控模式（悬停高亮 + 松手触发）
	// ==========================================
	if (inputMode == "touch") {
		var mousePoint = FlxG.mouse.getScreenPosition(camera);
		var newHover:UndertaleText = null;
		
		// 检测所有可见交互对象
		for (row in letterObjects) {
			for (obj in row) {
				if (obj.visible && obj.overlapsPoint(mousePoint, false, camera)) {
					newHover = obj;
					break;
				}
			}
			if (newHover != null) break;
		}
		
		// 更新悬停高亮
		if (newHover != hoveredObject) {
			if (hoveredObject != null) {
				hoveredObject.color = FlxColor.WHITE;
			}
			if (newHover != null) {
				newHover.color = FlxColor.YELLOW;
			}
			hoveredObject = newHover;
		}
		
		// 松手触发（justReleased）
		if (FlxG.mouse.justReleased) {
			if (hoveredObject != null) {
				var clicked = hoveredObject;
				if (!namingMenu) {
					switch(clicked.text) {
						case 'Backspace':
							name.text = name.text.substring(0, name.text.length - 1);
						case 'Done':
							nameAccept();
						default:
							if (name.text.length < 6) {
								name.text = name.text + clicked.text;
								if (name.text.toLowerCase() == 'gaster') {
									Sys.exit();
								}
							}
					}
				} else {
					switch(clicked.text) {
						case 'Yes':
							FlxG.save.data.playerName = name.text;
							FlxG.save.flush();
							if (data != null) {
								FlxG.switchState(new ModState('ModMainMenu', data));
							} else {
								FlxG.switchState(new MainMenuState());
							}
						case 'No':
							returnName();
					}
				}
			}
		}
	}
}

function postUpdate(elapsed:Float) {
	if (!namingMenu) {
		// 飘动效果（保留原逻辑）
	} else {
		name.angle = r.float(offsetValue, -offsetValue);
	}
}

// ========== 键盘模式专用：更新选中高亮 ==========
var lane:Array<UndertaleText>;
function updateSelection(?v:Int, ?l:Int) {
	if (inputMode != "keyboard") return;
	
	var oldLane = letterObjects.get(laneSelected);
	if (oldLane != null && oldLane[curSelected] != null) {
		oldLane[curSelected].color = FlxColor.WHITE;
	}
	
	if (l != null && !namingMenu) {
		laneSelected += l;
		if (laneSelected < 0) {
			laneSelected = 0;
		} else if (laneSelected > mapLength - 1) {
			laneSelected = mapLength - 1;
		}
		lane = letterObjects.get(laneSelected);
		if (curSelected > lane.length - 1) {
			curSelected = lane.length - 1;
		}
	}
	if (v != null && nameAllowed) {
		curSelected += v;
		if (curSelected > lane.length - 1) {
			curSelected = lane.length - 1;
		} else if (curSelected < 0) {
			curSelected = 0;
		}
	}
	var finalLane = letterObjects.get(laneSelected);
	if (finalLane != null && finalLane[curSelected] != null) {
		finalLane[curSelected].color = FlxColor.YELLOW;
	}
}

// ========== nameAccept：确认名字（匹配时忽略大小写） ==========
var nameTween:FlxTween;
var namePosition:FlxTween;
function nameAccept() {
	// 获取用户输入（原始字符串）
	var inputRaw = name.text;
	// 转为小写用于匹配
	var inputLower = inputRaw.toLowerCase();
	
	// 遍历 specialNames 的所有键，转小写后比较
	var special:Array<Dynamic> = null;
	for (key in specialNames.keys()) {
		if (key.toLowerCase() == inputLower) {
			special = specialNames.get(key);
			break;
		}
	}
	
	// 如果找到特殊名字，则设置 nameAllowed
	if (special != null) {
		nameAllowed = (special[1] == null || special[1] != false ? true : false);
	}
	
	// ---- 修改顶部提示文字为确认信息，并居中显示 ----
	topText.text = (special != null ? special[0] : (unoriginalName(inputRaw) ? 'Not very creative...?' : 'Is this name correct?'));
	topText.alignment = 'center';
	topText.x = 2;
	
	// ---- 名字放大并移动到屏幕正中心 ----
	var tw:Float = name.textWidth;
	var th:Float = name.textHeight;
	var targetScale:Float = 2.8;
	var targetX:Float = (FlxG.width - tw * targetScale) / 2;
	var targetY:Float = (FlxG.height - th * targetScale) / 2;
	
	name.origin.set(0, 0);
	nameTween = FlxTween.tween(name.scale, {x: targetScale, y: targetScale}, 4);
	namePosition = FlxTween.tween(name, {x: targetX, y: targetY}, 4);
	
	// ---- 将 Backspace / Done 按钮改为 No / Yes ----
	var btnNo:UndertaleText = prompts[0];
	var btnYes:UndertaleText = prompts[1];
	btnNo.text = 'No';
	btnNo.fieldWidth = touchWidthNo;
	btnYes.text = 'Yes';
	btnYes.fieldWidth = touchWidthYes;
	btnYes.visible = nameAllowed;
	
	if (!nameAllowed) {
		curSelected = 0;
		updateSelection(0, 0);
	}
	
	// ---- 隐藏字母 ----
	for (letter in lettersArray) {
		letter.visible = false;
	}
	
	namingMenu = true;
}

// ========== returnName：取消确认，返回输入界面 ==========
function returnName() {
	// 恢复顶部提示为随机文本
	topText.text = texts[r.int(0, texts.length - 1)];
	topText.alignment = 'center';
	topText.x = 2;
	
	DiscordUtil.changePresence('Naming themselves.', topText.text);
	
	// 恢复按钮文字和触控宽度
	prompts[0].text = 'Backspace';
	prompts[0].fieldWidth = touchWidthBackspace;
	prompts[1].text = 'Done';
	prompts[1].fieldWidth = touchWidthDone;
	prompts[1].visible = true;
	
	nameAllowed = true;
	
	// 显示字母
	for (letter in lettersArray) {
		letter.visible = true;
	}
	
	// 取消名字动画，重置位置和缩放
	nameTween.cancel();
	namePosition.cancel();
	name.scale.set(1, 1);
	name.setPosition(610, 290);
	name.angle = 0;
	
	namingMenu = false;
	
	// 恢复键盘高亮（若处于键盘模式）
	if (inputMode == "keyboard") {
		var lane = letterObjects.get(laneSelected);
		if (lane != null && lane[curSelected] != null) {
			lane[curSelected].color = FlxColor.YELLOW;
		}
	}
}

// ========== 辅助函数：判断名字是否过于重复 ==========
function unoriginalName(name:String) {
	var firstLetter:String = name.charAt(0);
	var repeats:Int = 0;
	for (i in 1...name.length) {
		if (name.charAt(i) == firstLetter) {
			repeats++;
		}
	}
	return (repeats + 1) == name.length;
}