import UndertaleText;
import TypedBitmapText;
import optiontypes.Slider;
import funkin.backend.system.Controls.Control;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;

var stateCamera:FlxCamera = new FlxCamera();
var uiCamera:FlxCamera;          // UI专用相机，不受缩放影响
var backBtn:FlxSprite;           // 返回按钮

//Visuals.
var bg:FlxBackdrop;
var chara:FlxSprite = new FlxSprite().loadGraphic();
//Other.
var offsetSlider:Slider;
var canExit:Bool = false;
var exiting:Bool = false;        // 防止重复触发退出动画

function create() {
	FlxG.cameras.add(stateCamera, false);
	stateCamera.bgColor = FlxColor.TRANSPARENT;
	this.cameras = [stateCamera];
	stateCamera.zoom = 4;

	// ------ 背景 ------
	var v:Int = 10;
	var tile:FlxSprite = FlxGridOverlay.create(15, 15, 30, 30, true, 0xFF68A8D8, 0xFF80D890);
	bg = new FlxBackdrop(tile.pixels, FlxAxes.XY);
	bg.alpha = 0.9;
	bg.velocity.set(v, v);
	add(bg);

	// ------ 角色动画 ------
	chara.frames = Paths.getSparrowAtlas('options/chara');
	chara.animation.addByPrefix('b', 'chara bop0', 11, false);
	chara.animation.play('b');
	chara.antialiasing = false;
	chara.screenCenter();
	add(chara);

	// ------ 文字和滑块 ------
	var currentOffset:UndertaleText = new UndertaleText(chara.x - 64, chara.y + 78, 'CURRENT OFFSET:', 'left', FlxG.width, 1, 'FFFF00', 'undertale-outline');
	currentOffset.autoSize = true;
	currentOffset.cameras = [stateCamera];
	add(currentOffset);

	offsetSlider = new Slider(0, 0, this, currentOffset, 'songOffset', 0, -999, 999, null, Options, null, 'ms');
	offsetSlider.cameras = [stateCamera];
	add(offsetSlider);

	// ------ 音乐 ------
	FlxG.sound.playMusic(Paths.music('sans'), Options.volumeMusic, true);
	Conductor.changeBPM(128);

	// ------ UI相机（独立于缩放）------
	uiCamera = new FlxCamera();
	uiCamera.bgColor = FlxColor.TRANSPARENT;
	uiCamera.zoom = 1;
	uiCamera.antialiasing = false;
	FlxG.cameras.add(uiCamera, false);

	// ------ 返回按钮 ------
	backBtn = new FlxSprite().loadGraphic(Paths.image('freeplay/backspace'));
	backBtn.antialiasing = false;
	backBtn.scale.set(6, 6);
	backBtn.updateHitbox();
	backBtn.setPosition(10, 10);
	backBtn.alpha = 1;
	backBtn.cameras = [uiCamera];
	add(backBtn);

	// ------ 入场动画 ------
	stateCamera.alpha = 0;
	FlxTween.tween(stateCamera, {alpha: 1}, 0.1, {ease: FlxEase.cubeInOut, onComplete: function() {
		canExit = true;
	}});
}

var lastBeat:Int = 0;
var beat:Int = 0;
var transitionTime:Float = 0.1;

function update(elapsed:Float) {
	// ------ 返回按钮交互 ------
	var mousePoint = FlxG.mouse.getWorldPosition(uiCamera);
	var isHover = backBtn.overlapsPoint(mousePoint, false, uiCamera);
	backBtn.color = isHover ? FlxColor.YELLOW : FlxColor.WHITE;
	if (FlxG.mouse.justReleased && isHover) {
		exitMenu();
		return;
	}

	// ------ 键盘返回 ------
	if (controls.BACK && canExit && !exiting) {
		exitMenu();
		return;
	}

	// ------ 节拍动画 ------
	beat = Conductor.getBeats(0, 2, 0);
	if (lastBeat != beat) {
		stateCamera.zoom += 0.1;
		chara.animation.play('b', true);
		lastBeat = beat;
	}
	stateCamera.zoom = CoolUtil.fpsLerp(stateCamera.zoom, 4, 0.025);

	// ------ 实时更新偏移 ------
	Conductor.songOffset = offsetSlider.currentValue;
}

// ------ 退出函数（含淡出动画）------
function exitMenu() {
	if (!canExit || exiting) return;
	exiting = true;
	FlxTween.tween(stateCamera, {alpha: 0}, transitionTime, {
		ease: FlxEase.cubeInOut,
		onComplete: function() {
			close();
			FlxG.sound.playMusic(Paths.music('menuthemes/mainmenu'), 1, true);
		}
	});
}