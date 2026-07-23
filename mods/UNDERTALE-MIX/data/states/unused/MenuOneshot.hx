import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.tweens.FlxTweenType;
import funkin.menus.ModSwitchMenu;
import funkin.options.OptionsMenu;
import flixel.math.FlxRandom;
import SeasonParticle;
import Math;
import Std;
import StringTools;
import Odometer;

//Other stuff.
var particles:FlxTypedGroup<SeasonParticle> = new FlxTypedGroup();
var r = new FlxRandom();
var menuCamera = new FlxCamera();
var bark:FlxSound = FlxG.sound.load(Paths.sound('pombark'), 1, false, null, false, false, null, function() {
	changeDogBehaviour();
});
//Menu stuff.
var options:Array<String> = ['OPTIONS', 'CREDITS'];
var optionTexts:FlxTypedGroup<FlxBitmapText> = new FlxTypedGroup();
var hanger:FlxSprite = new FlxSprite(640, 270).loadGraphic(Paths.image('hanged'), true, 95, 76);
var selection = 1;
var songSelected = false;
var dog:FlxSprite = new FlxSprite(600, 431).loadGraphic(Paths.image('dog'), true, 26, 19);
//Font stuff.
var undertaleFont:FlxBitmapFont;
var dogBehaviour = 'idle';
//Odometer stuff.
var numbers:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
//I refuse to do half the fucking math that may be required for this shit, I gotta get this out in a day to hop on that anniversary hype.
// var trackingNumbers = [0, 0, 0];
// var currentValue = 
var currentValue = 100;
var trackingValue = 50;

function create() {
	FlxG.cameras.add(menuCamera, false);
	cameras = [menuCamera];
	
	menuCamera.bgColor = FlxColor.TRANSPARENT;
	menuCamera.pixelPerfectRender = true;
	menuCamera.zoom = 4;
	undertaleFont = getFont('ut-text', 'AaBbCcDdEeFf' + 'GgHhIiJjKkLl' + 'MmNnOoPpQqRr' + 'SsTtUuVvWwXx' + 'YyZz01234567' + '89!#%&$*"/@?' + '+>}{<_~=-])[' + "(,.|'^;: ");
	
	add(particles);
	
	hanger.animation.add('idle', [0, 1], 0);
	hanger.animation.play('idle', true);
	hanger.angle = 2;
	hanger.pixelPerfectRender = false;
	add(hanger);
	
	dog.animation.add('idle', [0], 0);
	dog.animation.add('walk', [2, 3], 8, true);
	dog.animation.add('bark', [1], 12);
	dog.animation.add('jump', [4], 0);
	dog.animation.play('idle', true);
	add(dog);
	
	add(optionTexts);
	
	var index = 0;
	for (option in options) {
		index++;
		var text = bitmapText(520, 260 + (16 * (index + 1)), option, FlxTextAlign.LEFT, 'FFFFFF', FlxG.width, 0.5, undertaleFont);
		text.ID = index;
		optionTexts.add(text);
	}
	new FlxTimer().start(0.05, function() {
		particle = new SeasonParticle(r.int(450, 700), 200, 'spring');
		particles.add(particle);
	}, 150);
	
	FlxTween.tween(hanger, {angle: -2}, 2, {type: FlxTweenType.PINGPONG, ease: FlxEase.quadInOut});
	hanger.origin.set(50, 0);
	
	// var meter = new Odometer(500, 300);
	// add(meter);
	var frames = [];
	for (i in 0...40) {
		frames.push(i);
	}
	var fps = 24;
	for (i in 0...3) {
		// var num = new FlxSprite(500 + (9 * i), 300);
		var num = new FlxSprite(500 + (9 * i), 300).loadGraphic(Paths.image('numbers'), true, 9, 16);
		// num.frames = Paths.getSparrowAtlas('numbersPacked');
		// num.animation.addByPrefix('0', 'ninetozero0', fps, false);
		// num.animation.addByPrefix('1', 'zerotoone0', fps, false);
		// num.animation.addByPrefix('2', 'onetotwo0', fps, false);
		// num.animation.addByPrefix('3', 'twotothree0', fps, false);
		// num.animation.addByPrefix('4', 'threetofour0', fps, false);
		// num.animation.addByPrefix('5', 'fourtofive', fps, false);
		// num.animation.addByPrefix('6', 'fivetosix0', fps, false);
		// num.animation.addByPrefix('7', 'sixtoseven0', fps, false);
		// num.animation.addByPrefix('8', 'seventoeight0', fps, false);
		// num.animation.addByPrefix('9', 'eighttonine0', fps, false);
		num.animation.add('scroll', frames, 0);
		num.animation.play('scroll', true);
		num.ID = i;
		numbers.add(num);
	}
	add(numbers);
	
	// updateTrackers(50, 985);
	
	// t = new FlxTimer().start(1, function() {
		// updateTrackers(0, r.int(0, 999));
	// }, 999);
	
	updateSelection();
}

var numberFrames = [
	0 => 0,
	1 => 4,
	2 => 8,
	3 => 12,
	4 => 16,
	5 => 20,
	6 => 24,
	7 => 28,
	8 => 32,
	9 => 36
];

function update() {
	if (controls.ACCEPT) {
		FlxG.sound.play(Paths.sound('select'), 1);
		if (!songSelected) {
			if (options[selection - 1] == 'OPTIONS') {
				FlxG.switchState(new OptionsMenu());
			}
		} else {
			PlayState.loadSong('temperate', 'normal', false, false);
			FlxG.switchState(new PlayState());
		}
	} else if (controls.UP_P && !songSelected) {
		updateSelection(-1);
	} else if (controls.DOWN_P && !songSelected) {
		updateSelection(1);
	} else if (controls.RIGHT_P) {
		songSelected = true;
		updateSelection();
	} else if (controls.LEFT_P) {
		songSelected = false;
		updateSelection();
	} else if (controls.SWITCHMOD) {
		openSubState(new ModSwitchMenu());
		persistentUpdate = false;
		persistentDraw = true;
	}
	
	hanger.animation.curAnim.curFrame = (songSelected ? 1 : 0);
	
	if (r.bool(10)) {
		if (dogBehaviour == 'idle') {
			dog.animation.play('idle', true);
			if (r.bool(10)) {
				changeDogBehaviour();
			}
		} else if (dogBehaviour == 'walk') {
			if (r.bool(5)) {
				changeDogBehaviour();
			}
		} else if (dogBehaviour == 'jump') {
			if (dog.y > 431) {
				dog.velocity.set(0, 0);
				dog.acceleration.set(0, 0);
				changeDogBehaviour();
				dog.y = 431;
			}
		}
	}
	
	// numbers.forEach(function(num:FlxSprite) {
		// var previousNum = 
		// num.animation.play(
	// });
	
	// trace(
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

function updateSelection(?v:Int) {
	FlxG.sound.play(Paths.sound('squeak'), 1);
	if (v != null) {
		selection += v;
		if (selection > options.length) {
			selection = 1;
		} else if (selection < 1) {
			selection = options.length;
		}
	}
	optionTexts.forEach(function(text:FlxBitmapText) {
		var selected = (text.ID == selection && !songSelected);
		text.color = (selected ? FlxColor.YELLOW : FlxColor.WHITE);
	});
}

function changeDogBehaviour() {
	var thing = r.int(0, 100);
	if (thing < 5) {
		dogBehaviour = 'jump';
		dog.animation.play('jump', true);
		dog.velocity.y = -50;
		dog.acceleration.y = 100;
	} else if (thing > 60) {
		dogBehaviour = 'idle';
		dog.animation.play('idle', true);
		dog.velocity.set(0, 0);
		dog.acceleration.set(0, 0);
	} else if (thing < 30) {
		dogBehaviour = 'walk';
		var direction = (r.bool(50) ? 1 : -1);
		dog.animation.play('walk', true);
		dog.velocity.x = 20 * direction;
		dog.flipX = (direction ? true : false);
	} else if (thing < 60) {
		bark.play();
		dog.animation.play('bark', true);
		dog.velocity.set(0, 0);
		dog.acceleration.set(0, 0);
	}
}

function updateTrackers(oldValue:Int, newValue:Int) {
	currentValue = newValue;
	// var splitOld = StringTools.lpad(Std.string(oldValue), '0', 3);
	var splitNew = StringTools.lpad(Std.string(newValue), '0', 3);
	var splitted = splitNew.split();
	// trace(splitted);
	// trace(splitNew);
	// trace(splitted[0]);
	numbers.forEach(function(num:FlxSprite) {
		// trace(num.ID);
		// trace(numberFrames[splitted[num.ID]]);
		FlxTween.num(num.animation.curAnim.curFrame, numberFrames[splitted[num.ID]], 0.1, null, number -> num.animation.curAnim.curFrame = number);
	});
	// FlxTween.num(trackingValue, newValue, 0.5);
}