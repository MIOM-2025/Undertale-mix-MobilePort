import UndertaleText;
import TextItem;
import Sys;

import funkin.menus.credits.CreditsMain;
import funkin.options.OptionsMenu;

import funkin.backend.utils.DiscordUtil;

//Option stuff.
var options = ['Story Mode', 'Freeplay', 'Options', 'Credits', 'mod option test'];
var optionObjects:FlxTypedGroup<TextItem> = new FlxTypedGroup();
//Scrolling text stuff.
var curSelected = 0;
var lerp = 0;
//Other.
var name:UndertaleText;
var nameSelected:Bool = false;
//Pointers.
var pointerRight:FlxSprite = new FlxSprite(813, 421).loadGraphic(Paths.image('title/arrow')); 
var pointerLeft:FlxSprite = new FlxSprite(453, 421).loadGraphic(Paths.image('title/arrow'));

var popupTimer:FlxTimer;
function create() {
	DiscordUtil.changePresence('In the main menu.');

	if (FlxG.sound.music == null) { FlxG.sound.playMusic(Paths.music('startmenu'), 1, true); }
	
	var bg:FlxSprite = new FlxSprite(0, 137).loadGraphic(Paths.image('title/ruinsbg'));
	bg.scale.set(3, 3);
	bg.screenCenter(FlxAxes.X);
	
	name = new UndertaleText(766, 203, FlxG.save.data.playerName, 'left', FlxG.width, 1.8);
	// name.updateHitbox();
	// var realName:UndertaleText = new UndertaleText(name.x, name.y + 48, '(Hi, ' + Sys.getEnv('USERNAME') + '!)', 'left', FlxG.width, 1.8);
	// add(realName);
	
	var id:Int = 0;
	for (option in options) {
		var text:TextItem = new TextItem(0, 415, option, name.font);
		text.screenCenter(FlxAxes.X);
		text.startPoint = text.x;
		text.target = id;
		text.x = (text.target * text.distanceBetween) + text.startPoint;
		optionObjects.add(text);
		id++;
	}
	
	var accuracyText:UndertaleText = new UndertaleText(name.x + 252, name.y, 'Avg. Acc', 'left', FlxG.width, 1.8);
	var accuracyCounter:UndertaleText = new UndertaleText(accuracyText.x, accuracyText.y + 81, '%0.0', 'left', FlxG.width, 1.8);
	
	var elapsedText:UndertaleText = new UndertaleText(name.x + 552, name.y, 'Time Played', 'left', FlxG.width, 1.8);
	var timeCounter:UndertaleText = new UndertaleText(elapsedText.x, elapsedText.y + 81, '0:00', 'left', FlxG.width, 1.8);
	
	var info:UndertaleText = new UndertaleText(0, 704, 'undertale mix v1.00 2025', 'center', FlxG.width, 3, 'FFFFFF', 'crypt');
	info.screenCenter(FlxAxes.X);
	info.alpha = 0.5;
	
	var id:Int = 0;
	for (item in [bg, pointerLeft, pointerRight, optionObjects, name, accuracyText, accuracyCounter, elapsedText, timeCounter, info]) {
		if (id < 3) {
			item.antialiasing = false;
			item.scale.set(3, 3);
		}
		add(item);
		id++;
	}
	pointerLeft.flipX = true;
	
	updateSelection();
}

function update(elapsed:Float) {
	if (controls.LEFT_P && !nameSelected) {
		updateSelection(-1);
	} else if (controls.RIGHT_P && !nameSelected) {
		updateSelection(1);
	} else if (controls.UP_P && !nameSelected) {
		nameSelected = true;
		updateSelection(0, false);
	} else if (controls.DOWN_P && nameSelected) {
		nameSelected = false;
		updateSelection(0, false);
	} else if (controls.ACCEPT) {
		if (!nameSelected) {
			var selection:String = options[curSelected].toLowerCase();
			trace(selection);
			switch(selection) { //Only using this cause it looks prettier. Really that's why some of these things exist anyways.
				case 'story mode':
					FlxG.switchState(new StoryMenuState());
				case 'freeplay':
					FlxG.switchState(new FreeplayState());
				case 'options':
					FlxG.switchState(new OptionsMenu());
				case 'credits':
					FlxG.switchState(new ModState('ModCreditsState'));
				case 'mod option test':
					FlxG.switchState(new ModState('ModOptions'));
			}
		} else {
			FlxG.switchState(new ModState('StartUp'));
		}
	} else if (controls.BACK) {
		FlxG.switchState(new TitleState());
	} else if (controls.DEV_ACCESS) {
		FlxG.switchState(new ModState('MasterDebugMenu'));
	}

	lerp = Math.exp(-elapsed * 24.6);
	for (text in optionObjects) {
		text.x = FlxMath.lerp(((text.target - curSelected) * text.distanceBetween) + text.startPoint, text.x, lerp);
	}
}

function updateSelection(?v:Int, ?updateArrow:Bool) {
	if (updateArrow == null || updateArrow == true) {
		pointerLeft.alpha = 0; pointerRight.alpha = 0;
		if (popupTimer != null) { popupTimer.cancel(); }
		popupTimer = new FlxTimer().start(0.13, function() {
			pointerLeft.alpha = (curSelected > 0 ? 1 : 0);
			pointerRight.alpha = (curSelected < optionObjects.length - 1 ? 1 : 0);
		});
	}
	if (v != null) {
		FlxG.sound.play(Paths.sound('squeak'));
		curSelected += v;
		if (curSelected < 0) {
			curSelected = optionObjects.length - 1;
		} else if (curSelected > optionObjects.length - 1) {
			curSelected = 0;
		}
	}
	name.color = (nameSelected ? FlxColor.YELLOW : FlxColor.WHITE);
	for (text in optionObjects) {
		text.color = (curSelected == text.target && !nameSelected ? FlxColor.YELLOW : FlxColor.WHITE);
	}
}