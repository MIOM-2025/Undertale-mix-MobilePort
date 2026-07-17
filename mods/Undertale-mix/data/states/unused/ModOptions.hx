import UndertaleText;
// import optionsobjects.CheckboxOption;
// import optionsobjects.SliderOption;
import optionsobjects.DropdownOption;
import flixel.addons.display.FlxGridOverlay;
import flixel.text.FlxTextBorderStyle;
import TypedBitmapText;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxEase;
import flixel.math.FlxRandom;

var optionGroup:Array<Dynamic>;
var camera = new FlxCamera();
var r = new FlxRandom();

var description:UndertaleText;
var topText:UndertaleText;
var descriptionBox:FlxSprite;
var descriptionBackground:FlxSprite;
var descriptionTyped:TypedBitmapText;
var background:FlxBackdrop;
var menuTexts:Array<Dynamic> = [];
var optionMenus = [
	['Controls', 'Change your controls here!'],
	['Gameplay', 'Change things about gameplay to your/liking such as turning on Downscroll/or changing your scroll speed!'],
	['Appearance', "If you don't like how some things/look like then change them here."],
	['Miscellaneous', "Anything that doesn't fit in the/other four, just general engine/settings."],
	['Debug', 'Options for developers when using/debug mode.'],
];
var curSelected:Int = 0;
function create() {
	FlxG.cameras.add(camera, false);
	camera.bgColor = FlxColor.TRANSPARENT;
	this.cameras = [camera];
	// camera.zoom = 0.5;
	
	var tile:FlxSprite = FlxGridOverlay.create(60, 60, 120, 120, true, 0xFF969696, 0xFF404040);
	background = new FlxBackdrop(tile.pixels, FlxAxes.XY);
	background.alpha = 0.5;
	background.velocity.set(20, 20);
	background.scrollFactor.set(0, 0);
	add(background);
	
	topText = new UndertaleText(100, 100, 'OPTIONS', 'center', FlxG.width, 6, 'FFFFFF', 'undertale-outline');
	// topText.setBorderStyle(FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK, 1);
	topText.screenCenter(FlxAxes.X);
	topText.x -= 3;
	add(topText);
	
	var index:Int = 0;
	for (menuString in optionMenus) {
		var string:String = menuString[0];
		var menu:UndertaleText = new UndertaleText(2008, 199 + (60 * index), string.toUpperCase(), 'left', FlxG.width, 4, 'FFFFFF', 'undertale-outline');
		menu.ID = index;
		add(menu);
		menuTexts.push(menu);
		index++;
	}
	
	
	descriptionBox = new FlxSprite(0, 492).makeGraphic(895, 215, FlxColor.WHITE);
	descriptionBox.screenCenter(FlxAxes.X);
	add(descriptionBox);
	
	descriptionBackground = new FlxSprite(0, 500).makeGraphic(880, 200, FlxColor.BLACK);
	descriptionBackground.screenCenter(FlxAxes.X);
	// descriptionBackground.alpha = 0.8;
	add(descriptionBackground);
	
	description = new UndertaleText(descriptionBackground.x + 40, descriptionBackground.y + 30, '* hello', 'left', FlxG.width, 3, 'FFFFFF', 'undertale-pixel');
	// description.updateHitbox();
	// description.screenCenter(FlxAxes.X);
	// add(description);
	
	descriptionTyped = new TypedBitmapText(descriptionBackground.x + 32, descriptionBackground.y + 40, '* hi', description.getFont('undertale-pixel'));
	descriptionTyped.setTextFormat(3, 'FFFFFF', description.getAlignment('left'), FlxG.width);
	descriptionTyped.parentState = this;
	descriptionTyped.lineOffset = 1326;
	descriptionTyped.lineSpacing = 50;
	// descriptionTyped.startTyping(0.02,
	add(descriptionTyped);
	
	updateSelection();

	// var optionTest:CheckboxOption = new CheckboxOption(100, 100, 'test', 'hello', this);
	// add(optionTest);
	
	// var sliderTest:SliderOption = new SliderOption(100, 400, 'slider test', 'hello', this);
	// add(sliderTest);
	
	// var dropTest:DropdownOption = new DropdownOption(100, 400, 'dropdown test', 'hello', this, ['hello1', 'hello2', 'hello long1', 'hello long long1', 'not visible', 'not visible 3']);
	// add(dropTest);
}

var main:Bool = true;
function update(elapsed:Float) {
	if (descriptionTyped != null) {
		descriptionTyped.textUpdate(elapsed);
	}

	if (controls.ACCEPT && main) {
		categorySwitch();
	} else if (controls.BACK) {
		if (main) {
			FlxG.switchState(new MainMenuState());
		} else {
			main = true;
			FlxTween.tween(background, {alpha: 0}, 0.2, {ease: FlxEase.cubeInOut, onComplete: function() {
				for (text in menuTexts) {
					FlxTween.tween(text, {x: text.x + 550}, 0.2, {ease: FlxEase.cubeInOut});
				}	
				var tile:FlxSprite = FlxGridOverlay.create(60, 60, 120, 120, true, 0xFF969696, 0xFF404040);
				background.pixels = tile.pixels;
				FlxTween.tween(background, {alpha: 0.5}, 0.2, {ease: FlxEase.cubeInOut, onComplete: function() {
					showBox(true);
					topText.text = 'OPTIONS';
				}});
			}});
		}
	}
	
	if (controls.UP_P && main) {
		updateSelection(-1);
	} else if (controls.DOWN_P && main) {
		updateSelection(1);
	}
}

function startTalking(text:String) {
	descriptionTyped.resetAndChangeText(text, true);
	descriptionTyped.startTyping(0.02, 'text-blip', true);
}

function categorySwitch() {
	main = false;
	showBox(false);
	if (descriptionTyped.active) {
		descriptionTyped.advanceDialogue();
	}
	for (text in menuTexts) {
		FlxTween.tween(text, {x: text.x - 550}, 0.2, {ease: FlxEase.cubeInOut});
	}
	FlxTween.tween(background, {alpha: 0}, 0.2, {ease: FlxEase.cubeInOut, onComplete: function() {
		openOptionMenu(optionMenus[curSelected][0]);
	}});
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

function openOptionMenu(?substate:String) {
	var tile:FlxSprite = FlxGridOverlay.create(60, 60, 120, 120, true, r.color(), r.color());
	background.pixels = tile.pixels;
	FlxTween.tween(background, {alpha: 0.5}, 0.2, {ease: FlxEase.cubeInOut});
	topText.text = optionMenus[curSelected][0].toUpperCase();
	openSubState(new ModSubState(substate + 'Category'));
}

function updateSelection(?v:Int) {
	if (v != null) {
		curSelected += v;
		FlxG.sound.play(Paths.sound('squeak'), 1);
		if (curSelected < 0) {
			curSelected = optionMenus.length - 1;
		} else if (curSelected > optionMenus.length - 1) {
			curSelected = 0;
		}
	}
	for (text in menuTexts) {
		text.color = (curSelected == text.ID ? FlxColor.YELLOW : FlxColor.WHITE);
	}
	startTalking('* ' + optionMenus[curSelected][1]);
}