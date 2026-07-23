import UndertaleText;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.math.FlxRandom;
import flixel.tweens.FlxEase;

import optionsobjects.CheckboxOption;
import optionsobjects.SliderOption;
import optionsobjects.DropdownOption;

var subCamera = new FlxCamera();
var r = new FlxRandom();
var options = [
	['c', 'Downscroll', 'hi'],
	['c', 'Ghost Tapping', 'hi'],
	['c', 'Naughtyness', 'hi'],
	['c', 'Camera Zoom On Beat', 'hi'],
	['c', 'Auto Pause', 'hi'],
	['s', 'Song Offset', 'hi'],
	['s', 'Music Volume', 'hi'],
	['s', 'SFX Volume', 'hi'],
];
var curSelected:Int = 0;
var optionObject:Array<Dynamic> = [
];
function create() {
	FlxG.cameras.add(subCamera, false);
	subCamera.bgColor = FlxColor.TRANSPARENT;
	this.cameras = [subCamera];
	// camera.zoom = 0.5;
	
	// var tile:FlxSprite = FlxGridOverlay.create(60, 60, 120, 120, true, r.color(), r.color());
	// background = new FlxBackdrop(tile.pixels, FlxAxes.XY);
	// background.alpha = 0;
	// background.velocity.set(20, 20);
	// background.scrollFactor.set(0, 0);
	// add(background);
	
	// FlxTween.tween(background, {alpha: 0.5}, 0.2, {ease: FlxEase.cubeInOut});
	
	// var check:CheckboxOption = new CheckboxOption(68, 149, 'Downscroll', 'hi', this);
	// add(check);
	
	var index:Int = 0;
	var previousY:Int = 149;
	for (option in options) {
		if (option[0] == 'c') {
			var check:CheckboxOption = new CheckboxOption(68, previousY + (index != 0 ? 80 : 0), option[1], option[2], this);
			previousY = check.y;
			check.ID = index;
			optionObject.push(check);
			add(check);
		} else if (option[0] == 's') {
			if (options[index - 1][0] == 'c') {
				previousY += 60;
			}
			var slide:SliderOption = new SliderOption(84, previousY + (index != 0 ? 40 : 0), option[1], option[2], this);
			previousY = slide.y;
			slide.ID = index;
			optionObject.push(slide);
			add(slide);
		} else if (option[0] == 'd') {
			var dropdown:DropdownOption = new DropdownOption(100, previousY + (index != 0 ? 40 : 0), option[1], 'he', this, option[2]);
			previousY = dropdown.y;
			dropdown.ID = index;
			optionObject.push(dropdown);
			add(dropdown);
		}
		index++;
	}
	updateSelection(0);
}

function update(elapsed:Float) {
	if (controls.UP_P) {
		updateSelection(-1);
	} else if (controls.DOWN_P) {
		updateSelection(1);
	} else if (controls.BACK) {
		closeSubmenu();
	}
}

function closeSubmenu() {
	FlxTween.tween(subCamera, {alpha: 0}, 0.2, {ease: FlxEase.cubeInOut, onComplete: function() {
		close();
	}});
}

function updateSelection(?v:Int) {
	if (v != null) {
		FlxG.sound.play(Paths.sound('squeak'), 1);
		curSelected += v;
		if (curSelected < 0) {
			curSelected = optionObject.length - 1;
		} else if (curSelected > optionObject.length - 1) {
			curSelected = 0;
		}
		if (curSelected > 2) {
			subCamera.scroll.y = optionObject[curSelected].y - (options[curSelected][0] == 's' ? 350 : 285);
		} else {
			subCamera.scroll.y = 0;
		}
	}
	for (option in optionObject) {
		option.optionText.color = (option.ID == curSelected ? FlxColor.YELLOW : FlxColor.WHITE);
		option.selected = option.ID == curSelected;
	}
}