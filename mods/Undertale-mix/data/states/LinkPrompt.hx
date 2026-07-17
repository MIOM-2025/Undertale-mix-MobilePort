import UndertaleText;
import funkin.backend.system.Controls.Control;

var website:String;
var warn:UndertaleText;
var info:UndertaleText;
var link:UndertaleText;
var linkCamera:FlxCamera = new FlxCamera();

// ---- Yes/No 变量 ----
var yes:UndertaleText;
var no:UndertaleText;
var yesHitArea:FlxSprite;
var noHitArea:FlxSprite;
var inputMode:String = "keyboard";
var pendingYes:Bool = false;
var pendingNo:Bool = false;

function create() {
	website = data;
	
	FlxG.cameras.add(linkCamera, false);
	linkCamera.bgColor = FlxColor.TRANSPARENT;
	this.cameras = [linkCamera];

	var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	bg.alpha = 0.9;
	bg.screenCenter();
	add(bg);
	
	// 所有 y 坐标整体上移 100 像素
	var offsetY:Float = -100;
	
	warn = new UndertaleText(0, 268 + offsetY, 'WARNING!', 'center', FlxG.width, 1.6, 'FF0000');
	add(warn);
	
	info = new UndertaleText(0, warn.y + (24 * 2), 'Do you want to open this link?', 'center', FlxG.width, 1.6);
	add(info);
	
	link = new UndertaleText(0, info.y + (24 * 2), 'about:blank', 'center', FlxG.width, 1.6);
	link.text = website;
	link.updateHitbox();
	link.screenCenter(FlxAxes.X);
	add(link);

	// ---- Yes / No 按钮（下移 100 像素） ----
	yes = new UndertaleText(0, 0, 'Yes', 'left', FlxG.width, 1.6, 'FFFFFF');
	yes.autoSize = true;
	yes.updateHitbox();
	add(yes);
	yes.alpha = 1;
	yes.visible = true;

	no = new UndertaleText(0, 0, 'No', 'left', FlxG.width, 1.6, 'FFFFFF');
	no.autoSize = true;
	no.updateHitbox();
	add(no);
	no.alpha = 1;
	no.visible = true;

	// 居中放置（水平排列，间距 100），y 下移 100 像素
	var totalWidth = yes.width + 100 + no.width;
	// 原来按钮在 keyInfo.y + 48，现在 keyInfo 已移除，基于 link.y 再加 100
	yes.setPosition((FlxG.width - totalWidth) / 2, link.y + 85 + 100);
	no.setPosition(yes.x + yes.width + 100, yes.y);

	// ---- 透明点击区域 ----
	yesHitArea = new FlxSprite(yes.x, yes.y);
	yesHitArea.makeGraphic(Std.int(yes.width), Std.int(yes.height), FlxColor.TRANSPARENT);
	yesHitArea.visible = true;
	add(yesHitArea);

	noHitArea = new FlxSprite(no.x, no.y);
	noHitArea.makeGraphic(Std.int(no.width), Std.int(no.height), FlxColor.TRANSPARENT);
	noHitArea.visible = true;
	add(noHitArea);

	// ---- 默认模式 ----
	#if mobile
		inputMode = "touch";
	#else
		inputMode = "keyboard";
	#end

	if (inputMode == "keyboard") {
		yes.color = FlxColor.YELLOW;
		no.color = FlxColor.WHITE;
	} else {
		yes.color = FlxColor.WHITE;
		no.color = FlxColor.WHITE;
	}
}

function update(elapsed:Float) {
	// ---- 模式切换 ----
	if (inputMode == "keyboard") {
		if (FlxG.mouse.justPressed) {
			inputMode = "touch";
			pendingYes = false;
			pendingNo = false;
			yes.color = FlxColor.WHITE;
			no.color = FlxColor.WHITE;
		}
	} else if (inputMode == "touch") {
		if (controls.ACCEPT || controls.BACK) {
			inputMode = "keyboard";
			pendingYes = false;
			pendingNo = false;
			yes.color = FlxColor.YELLOW;
			no.color = FlxColor.WHITE;
		}
	}

	// ---- 键盘模式 ----
	if (inputMode == "keyboard") {
		if (controls.ACCEPT) {
			CoolUtil.openURL(website);
			close();
		} else if (controls.BACK) {
			close();
		}
		// 左右键切换高亮（视觉反馈，不影响功能）
		if (controls.LEFT || controls.RIGHT) {
			if (yes.color == FlxColor.YELLOW) {
				yes.color = FlxColor.WHITE;
				no.color = FlxColor.YELLOW;
			} else {
				yes.color = FlxColor.YELLOW;
				no.color = FlxColor.WHITE;
			}
		}
	}

	// ---- 触摸模式 ----
	if (inputMode == "touch") {
		var mousePoint = FlxG.mouse.getScreenPosition(linkCamera);
		var overYes = yesHitArea.visible && yesHitArea.overlapsPoint(mousePoint, true, linkCamera);
		var overNo  = noHitArea.visible  && noHitArea.overlapsPoint(mousePoint, true, linkCamera);

		if (overYes) {
			yes.color = FlxColor.YELLOW;
			no.color = FlxColor.WHITE;
		} else if (overNo) {
			yes.color = FlxColor.WHITE;
			no.color = FlxColor.YELLOW;
		} else {
			yes.color = FlxColor.WHITE;
			no.color = FlxColor.WHITE;
		}

		if (FlxG.mouse.justPressed) {
			if (overYes) pendingYes = true;
			else if (overNo) pendingNo = true;
		}

		if (FlxG.mouse.justReleased) {
			if (pendingYes && overYes) {
				pendingYes = false;
				CoolUtil.openURL(website);
				close();
			} else if (pendingNo && overNo) {
				pendingNo = false;
				close();
			} else {
				pendingYes = false;
				pendingNo = false;
			}
		}
	}
}