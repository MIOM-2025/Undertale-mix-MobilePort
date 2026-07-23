import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.graphics.frames.FlxBitmapFont;

import funkin.backend.system.Controls.Control;
import funkin.backend.utils.DiscordUtil;

import flixel.math.FlxRandom;
var r:FlxRandom = new FlxRandom();

var cryptFont:FlxBitmapFont;

var logo:FlxSprite;
var promptText:FlxBitmapText;
var p:FlxBitmapText;
function create() {
	DiscordUtil.call("onMenuLoaded", ["Title Screen"]);
	
	if (FlxG.sound.music != null) {
		FlxG.sound.music.stop();
		FlxG.sound.music = null;
	}

	cryptFont = getFont('cryptoftomorrow', "abcdefgh" + "ijklmnop" + "qrstuvwx" + "yz123456" + "789.,:;'" + '"()!?+-/' + "=0%[] ");
	
	logo = new FlxSprite().loadGraphic(Paths.image('title/logo-title'));
	logo.antialiasing = false;
	logo.scale.set(1.5, 1.5);
	logo.updateHitbox();
	logo.screenCenter();
	add(logo);
	
	var topText = bitmapText(0, logo.y - 13, "friday night funkin'", FlxTextAlign.CENTER, 'FFFFFF', FlxG.Width, 4, cryptFont);
	topText.screenCenter(FlxAxes.X);
	topText.x += 6;
	add(topText);	
	
	p = bitmapText(145, 650, 'chance: ' + FlxG.save.data.introChance, FlxTextAlign.LEFT, 'FFFFFF', FlxG.width, 4, cryptFont);
	add(p);
	
	DiscordUtil.changePresence('In the title screen.');
}

function postCreate() {
	var firstKey = controls.getKeyName(Control.ACCEPT, 0);
	var seconKey = controls.getKeyName(Control.ACCEPT, 1);
	var keys = (firstKey != null ? firstKey + (firstKey != null && seconKey != null ? ' or ' + seconKey : '') : 'any');

	promptText = bitmapText(0, logo.y + 223, '[press ' + keys.toLowerCase() + ' to begin]', FlxTextAlign.CENTER, 'FFFFFF', FlxG.width, 3.1, cryptFont);
	promptText.screenCenter(FlxAxes.X);
	promptText.alpha = 0.5;
	
	var intro = FlxG.sound.load(Paths.sound('intro'), 1, false, null, false, true, null, function() {
		add(promptText);
	});
}

var checkOnce:Bool = false;
function update(elapsed) {
	if (controls.ACCEPT) {
		if (FlxG.save.data.utmStartUp != null) {
			FlxG.switchState(new MainMenuState());
		} else {
			FlxG.switchState(new ModState('StartUp'));
		}
	}
	
	//Thing.
	if (!checkOnce) {
		checkOnce = true;
		if (FlxG.save.data.introChance == null) {
			FlxG.save.data.introChance = 0;
		}
		FlxG.save.data.introChance += 1;
		trace(FlxG.save.data.introChance);
		if (r.bool(FlxG.save.data.introChance)) {
			FlxG.switchState(new ModState('Thing'));
		}
	}
	//Thing.
	
	p.visible = FlxG.keys.pressed.C;
}


function bitmapText(x:Int, y:Int, text:String, alignment:FlxTextAlign, color:String, width:Int, scale:Float, font:FlxBitmapFont) {
	var text = new FlxBitmapText(x, y, text, font);
	text.alignment = alignment;
	text.fieldWidth = width;
	text.color = FlxColor.fromString('#' + color);
	text.scale.set(scale, scale);
	text.font = font;
	return text;
}

function getFont(image:String, letters:String) {
	return FlxBitmapFont.fromXNA(Assets.getBitmapData(Paths.image('fonts/' + image), true, false), letters);
}