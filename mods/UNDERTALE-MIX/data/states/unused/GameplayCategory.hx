import UndertaleText;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.math.FlxRandom;
import flixel.tweens.FlxEase;

import optionsobjects.CheckboxOption;
import optionsobjects.SliderOption;
import optionsobjects.DropdownOption;
import TypedBitmapText;

var subCamera = new FlxCamera();
var r = new FlxRandom();
var descriptionBox:FlxSprite;
var descriptionBackground:FlxSprite;
var descriptionTyped:TypedBitmapText;
var options = [
	['c', 'Downscroll', 'If checked, notes scroll down/instead of up.'],
	['c', 'Ghost Tapping', "If checked, pressing a key when/there isn't a note will not/register as a miss."],
	['c', 'Naughtyness', "If checked, any naughty things/will be censored."],
	['c', 'Camera Zoom On Beat', "Pretty self explanatory.      /If checked, the camera will zoom in/when a certain beat is reached."],
	['c', 'Auto Pause', "If checked the game will pause/when the window isn't focused."],
	['s', 'Song Offset', "The amount of milliseconds the/song will be offset by./Use to mitigate audio delay."],
	['s', 'Music Volume', "The volume of ingame audio."],
	['s', 'SFX Volume', "The volume of ingame sound effects.      /Such as this typing sound effect."],
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
	
	descriptionBox = new FlxSprite(0, 492).makeGraphic(895, 215, FlxColor.WHITE);
	descriptionBox.screenCenter(FlxAxes.X);
	descriptionBox.scrollFactor.set(0, 0);
	add(descriptionBox);
	
	descriptionBackground = new FlxSprite(0, 500).makeGraphic(880, 200, FlxColor.BLACK);
	descriptionBackground.screenCenter(FlxAxes.X);
	descriptionBackground.scrollFactor.set(0, 0);
	add(descriptionBackground);
	
	description = new UndertaleText(descriptionBackground.x + 40, descriptionBackground.y + 30, '* hello', 'left', FlxG.width, 3, 'FFFFFF', 'undertale-pixel');
	descriptionTyped = new TypedBitmapText(descriptionBackground.x + 32, descriptionBackground.y + 40, '* hi', description.getFont('undertale-pixel'));
	descriptionTyped.setTextFormat(3, 'FFFFFF', description.getAlignment('left'), FlxG.width);
	descriptionTyped.parentState = this;
	descriptionTyped.scrollFactor.set(0, 0);
	descriptionTyped.lineOffset = 1326;
	descriptionTyped.lineSpacing = 50;
	add(descriptionTyped);
	
	updateSelection(0);
}

function update(elapsed:Float) {
	if (descriptionTyped != null) {
		descriptionTyped.textUpdate(elapsed);
	}
	if (controls.UP_P) {
		updateSelection(-1);
	} else if (controls.DOWN_P) {
		updateSelection(1);
	} else if (controls.BACK) {
		closeSubmenu();
	}
}

function startTalking(text:String) {
	descriptionTyped.resetAndChangeText(text, true);
	descriptionTyped.startTyping(0.02, 'text-blip', true);
}


function closeSubmenu() {
	showBox(false);
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
	startTalking('* ' + options[curSelected][2]);
}

function showBox(show:Bool) {
	for (thing in [descriptionBackground, descriptionBox, descriptionTyped]) {
		thing.visible = show;
	}
	if (descriptionTyped.lines.length > 1) {
		for (line in descriptionTyped.lines) {
			line.visible = show;
		}
	}
}