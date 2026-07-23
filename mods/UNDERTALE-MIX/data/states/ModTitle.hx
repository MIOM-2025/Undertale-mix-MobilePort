import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.util.FlxTimer;

import funkin.backend.system.Controls.Control;
import funkin.backend.utils.DiscordUtil;

// import flixel.input.keyboard.FlxKey;

import UndertaleText;
import StringTools;

var fnfPart:FlxSprite;
var mixPart:FlxSprite;
var utLogo:FlxSprite;
var utLogoBent:FlxSprite;

var promptText:UndertaleText;
var chance:UndertaleText;

var introStep:Int = 0;
var camZoom:Float = 6.0;
var introFinished:Bool = false;
var canSkip:Bool = true;
var checkOnce:Bool = false;

var camera:FlxCamera = new FlxCamera();
var r:FlxRandom = new FlxRandom();
var introSound:FlxSound;

var inputtedText:String = '';
function create() {
	DiscordUtil.changePresenceAdvanced({
		details: 'In the Title Screen',
	});
	
	if (FlxG.sound.music != null) {
		FlxG.sound.music.stop();
		FlxG.sound.music = null;
	}
	
	FlxG.cameras.add(camera, false);
	camera.bgColor = FlxColor.TRANSPARENT;
	camera.antialiasing = false;
	camera.zoom = camZoom;
	this.cameras = [camera];
	
	utLogo = new FlxSprite().loadGraphic(Paths.image('title/title/ut'));
	utLogo.screenCenter();
	utLogo.alpha = 1;
	
	utLogoBent = new FlxSprite(utLogo.x, utLogo.y).loadGraphic(Paths.image('title/title/utbent-alt'));
	
	fnfPart = new FlxSprite(utLogo.x - 2, utLogo.y - 47).loadGraphic(Paths.image('title/title/fnfpart'));
	
	mixPart = new FlxSprite(utLogo.x + 9, utLogo.y + 6).loadGraphic(Paths.image('title/title/mixpart'));
	
	// 修改点：保留中括号，全部小写
	promptText = new UndertaleText(0, mixPart.y + 39, '[touch screen to start game]', 'center', FlxG.width, 0.5, 'FFFFFF', 'crypt');
	promptText.alpha = 0.5;
	promptText.screenCenter(FlxAxes.X);
	
	chance = new UndertaleText(251, promptText.y, 'chance: ' + FlxG.save.data.introChance, 'left', FlxG.width, 0.5, 'FFFFFF', 'crypt');
	
	for (part in [utLogo, utLogoBent, fnfPart, mixPart, promptText, chance]) {
		part.visible = false;
		add(part);
	}
	
	// DiscordUtil.changePresence('In the title screen.');
}

var keys:String = 'QWERTYUIOPASDFGHJKLÑZXCVBNM';
var validKeys:Array<String> = keys.split();
function postCreate() {
	// 因为已经直接写死了固定文本，不需要再动态修改
	// 直接执行标题动画
	titleEvent();
}

function update(elapsed:Float) {
	// 修改点：点击屏幕 或 按下确认键 都能触发开始逻辑
	if (controls.ACCEPT || FlxG.mouse.justPressed) {
		handleAccept();
	}
	camera.zoom = FlxMath.lerp(camera.zoom, camZoom, 0.05);
	
	if (FlxG.keys.justPressed.ANY) {
		var key:String = CoolUtil.keyToString(FlxG.keys.firstJustPressed());
		if (validKey(key)) {
			inputtedText += key;
			if (StringTools.endsWith(inputtedText, 'BALL')) {
				inputtedText = '';
				FlxG.sound.play(Paths.sound('ball_chime'), Options.volumeSFX);
			} else if (StringTools.endsWith(inputtedText, 'PONG')) {
				FlxG.save.data.pong_unlock = true;
				FlxG.save.flush();
				
				FlxG.switchState(new ModState('PongTitle'));
			} else if (StringTools.endsWith(inputtedText, 'RUNNER')) {
				FlxG.save.data.run_unlock = true;
				FlxG.save.flush();
				
				FlxG.switchState(new ModState('SoulRunnerTitle'));
			}
			if (inputtedText.length > 15) {
				inputtedText = inputtedText.substr(5);
			}
		}
	}
	
	// if (!checkOnce) {
		// checkOnce = true;
		// if (FlxG.save.data.introChance == null) {
			// FlxG.save.data.introChance = 0;
		// }
		// FlxG.save.data.introChance += 1;
		// trace(FlxG.save.data.introChance);
		// if (r.bool(FlxG.save.data.introChance)) {
			// FlxG.switchState(new ModState('Thing'));
		// }
	// }
	
	// chance.visible = FlxG.keys.pressed.C;
}

function validKey(key:String) {
	return validKeys.contains(key);
}

/**
 * 封装处理开始/跳过的逻辑，供键盘和鼠标点击共用
 */
function handleAccept() {
	if (!introFinished && canSkip) {
		if (introSound != null && introSound.playing) {
			introSound.stop();
		}
		FlxTimer.globalManager.clear();
		introSkip();
	} else {
		if (FlxG.save.data.playerName != null) {
			FlxG.switchState(new MainMenuState());
		} else {
			FlxG.switchState(new ModState('StartUpIntro-new'));
		}
	}
}

function titleEvent() {
	switch(introStep) {
		case 0:
			introSound = FlxG.sound.load(Paths.sound('intro'), 1, false, null, false, true, null, function() {
				titleEvent();
			});
			utLogo.visible = true;
		case 1:
			canSkip = false;
		
			makeSound('intro', 1.3);
			makeSound('hey', 1);
			utLogo.visible = false;
			utLogoBent.visible = true;
			
			camera.zoom += 0.1;
			fnfPart.visible = true;
			var timer:FlxTimer = new FlxTimer().start(0.3, function() {
				titleEvent();
			});
		case 2:
			camera.zoom += 0.1;
			makeSound('intro', 1.6, function() {
				promptText.visible = true;
			});
			mixPart.visible = true;
			introFinished = true;
	}
	introStep++;
}

function introSkip() {
	introFinished = true;

	utLogo.visible = false;
	utLogoBent.visible = true;
	fnfPart.visible = true;
	mixPart.visible = true;
	camera.zoom += 0.2;
	makeSound('hey', 1);
	makeSound('intro', 1.6, function() {
		promptText.visible = true;
	});
}

function makeSound(soundFile:String, soundPitch:Float, ?onFinished:Void->Void) {
	var sound:FlxSound = FlxG.sound.load(Paths.sound(soundFile), Options.volumeSFX, false, null, true, false, null, (onFinished != null ? onFinished : null));
	sound.pitch = soundPitch;
	sound.play();
}