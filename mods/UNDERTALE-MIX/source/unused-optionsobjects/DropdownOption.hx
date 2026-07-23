import UndertaleText;
import Math;
import flixel.math.FlxMath;
import flixel.FlxObject;

import flixel.input.mouse.FlxMouseEvent;
import flixel.input.mouse.FlxMouseEventManager;

import funkin.backend.system.Controls;
import funkin.options.PlayerSettings;

class DropdownOption extends FlxSprite {
	var optionText:UndertaleText;
	var optionArray:Array<String>;
	var defaultOption:UndertaleText;
	var mainBox:FlxSprite;
	var mainBoxBackground:FlxSprite;
	var optionsBoxBackground:FlxSprite;
	var arrowBackground:FlxSprite;
	
	var optionsBox:FlxCamera;
	var boxFollow:FlxObject;
	var maxScroll:Int = 120;
	var curSelected:Int = 0;
	var optionBackgrounds:Array<Dynamic> = [];
	var optionTexts:Array<Dynamic> = [];
	var menuOpened:Bool = false;
	var selected:Bool = false;
	
	var mouseControls:Bool = true; //Decides if you're using the mouse or not, disables upon keyboard input and enables on mouse movement.
	// var optionsCamera:FlxCamera = new FlxCamera(0, 0, 
	// var parent:Dynamic;

	var controls(get, never):Controls;
	function get_controls():Controls {
		return PlayerSettings.solo.controls;
	}

	public function new(x:Int, y:Int, text:String, desc:String, parent:Dynamic, options:Array<String>, ?optionCallback:Void->Void) {
		super(x, y);
		visible = false;
		
		optionArray = options;
		
		optionText = new UndertaleText(x, y, text, 'left', FlxG.width, 1.8, 'FFFFFF');
		optionText.updateHitbox();
		parent.add(optionText);
		
		//Text to base the box's size on.
		var sizeText:UndertaleText = new UndertaleText(x, y, getLongestString(options), 'left', FlxG.width, 1.8, 'FFFFFF');
		sizeText.autoSize = true;
		
		mainBoxBackground = new FlxSprite(optionText.x + (28 * optionText.text.length), optionText.y).makeGraphic(((sizeText.width + 45) + 8) * sizeText.scale.x, 60 + 14, FlxColor.WHITE);
		mainBoxBackground.setPosition(mainBoxBackground.x - 7, mainBoxBackground.y - 7);
		mainBoxBackground.updateHitbox();
		
		mainBox = new FlxSprite(optionText.x + (28 * optionText.text.length), optionText.y).makeGraphic((sizeText.width + 45) * sizeText.scale.x, 60, FlxColor.BLACK);
		mainBox.updateHitbox();
		
		arrowBackground = new FlxSprite((mainBox.x + mainBox.width) - 62, mainBox.y).makeGraphic(62, 60, FlxColor.WHITE);
		arrowBackground.color = FlxColor.BLACK;
		arrowBackground.updateHitbox();
		FlxMouseEvent.add(arrowBackground, function() {
			if (menuOpened) {
				closeDropdownMenu();
			} else {
				openDropdownMenu();
			}
		}, null, function() {
			arrowBackground.color = FlxColor.WHITE;
			arrowBackground.alpha = 0.5;
		}, function() {
			arrowBackground.color = FlxColor.BLACK;
		});
		
		var arrowThing:FlxSprite = new FlxSprite((mainBox.x + mainBox.width) - 48, mainBox.y + 17).loadGraphic(Paths.image('options/arrowd'));
		arrowThing.scale.set(4, 4);
		arrowThing.updateHitbox();
		arrowThing.antialiasing = false;
		
		optionsBoxBackground = new FlxSprite(mainBoxBackground.x, mainBoxBackground.y).makeGraphic(mainBoxBackground.width, (mainBoxBackground.height * 4) + 25, FlxColor.WHITE);
		optionsBoxBackground.visible = false;
		parent.add(optionsBoxBackground);
		
		optionsBox = new FlxCamera(mainBox.x + 1, mainBox.y + 67, mainBox.width - 2, (mainBox.height * 4));
		optionsBox.bgColor = FlxColor.BLACK;
		optionsBox.visible = false;
		FlxG.cameras.add(optionsBox, false);
		
		boxFollow = new FlxObject();
		//Y: 120 (Start).
		//+60 = full scroll
		boxFollow.setPosition(253, 120);
		parent.add(boxFollow);
		optionsBox.target = boxFollow;
		
		// optionsBox.updateHitbox();
		// parent.add(optionsBox);
		
		parent.add(mainBoxBackground);
		parent.add(mainBox);
		parent.add(arrowBackground);
		parent.add(arrowThing);
		
		var index = 0;
		for (option in options) {
			var textY:Int = (60 * index);
			var optionBackground:FlxSprite = new FlxSprite(-1, textY).makeGraphic(optionsBox.width + 2, mainBox.height, FlxColor.WHITE);
			optionBackground.color = FlxColor.BLACK;
			optionBackground.alpha = 0.5 + (0.05 * index);
			optionBackground.cameras = [optionsBox];
			optionBackground.ID = index;
			optionBackground.visible = false;
			optionBackgrounds.push(optionBackground);
			parent.add(optionBackground);	
			FlxMouseEvent.add(optionBackground, function() {
				if (menuOpened && mouseControls) {
					closeDropdownMenu();
					defaultOption.text = optionTexts[curSelected].text;		
				}
			}, null, function() {
				if (menuOpened && mouseControls) {
					optionBackground.color = FlxColor.WHITE;
					optionBackground.alpha = 0.2;
					curSelected = optionBackground.ID;
					// if (curSelected < 3) {
						// maxDisplay = 3;
					// } else {
						// maxDisplay = optionBackground.ID;
					// }
					// if (curSelected - 3 < 0) {
						// minDisplay = 0;
					// } else {
						// minDisplay = curSelected - 3;
					// }
					updateSelection(0);
				}
			}, function() {
				if (menuOpened && mouseControls) {
					optionBackground.color = FlxColor.BLACK;
				}
			});
			
			var option:UndertaleText = new UndertaleText(13, (60 * index), option, 'left', FlxG.width, 1.8, 'FFFFFF');
			option.y += 4;
			option.updateHitbox();
			option.cameras = [optionsBox];
			option.ID = index;
			option.visible = false;
			parent.add(option);
			optionTexts.push(option);
			index++;
		}
		maxScroll += 60 * (index - 4);
		
		//Display option on the dropdown, which is just your selected option.
		defaultOption = new UndertaleText(this.x + 378, this.y + 4, getLongestString(options), 'left', FlxG.width, 1.8, 'FFFFFF');
		defaultOption.updateHitbox();
		parent.add(defaultOption);
	}

	override function update(elapsed:Float) {
		arrowBackground.updateHitbox();
		if (controls.ACCEPT) {
			if (menuOpened) {
				closeDropdownMenu();
				defaultOption.text = optionTexts[curSelected].text;
			} else {
				openDropdownMenu();
			}
		}
	
		if (menuOpened) {
			if (controls.UP_P || controls.DOWN_P) {
				mouseControls = false;
			}
			if (controls.UP_P) {
				updateSelection(-1);
			} else if (controls.DOWN_P) {
				updateSelection(1);
			}
	
			boxFollow.y += 15 * -FlxG.mouse.wheel;
			if (boxFollow.y < 120) {
				boxFollow.y = 120;
			} else if (boxFollow.y > maxScroll) {
				boxFollow.y = maxScroll;
			}
			
			if (FlxG.mouse.justMoved && !mouseControls) {
				mouseControls = true;
			}
		}
		
		super.update(elapsed);
	}
	
	function getLongestString(strings:Array<String>) {
		var long:Int = 0;
		var longestString:String;
		for (string in strings) {
			if (string.length > long) {
				long = string.length;
				longestString = string;
			}
		}
		return longestString;
	}
	
	function openDropdownMenu() {
		menuOpened = true;
		optionsBox.visible = true;
		optionsBoxBackground.visible = true;
		for (bg in optionBackgrounds) {
			bg.visible = true;
		}
		for (text in optionTexts) {
			text.visible = true;
		}
		updateSelection(0);
	}
	
	function closeDropdownMenu() {
		menuOpened = false;
		optionsBox.visible = false;
		optionsBoxBackground.visible = false;
		for (bg in optionBackgrounds) {
			bg.visible = false;
		}
		for (text in optionTexts) {
			text.visible = false;
		}
	}
	
	var minDisplay:Int = 0;
	var maxDisplay:Int = 3;
	var highestCurSelected:Int = 0;
	var lastCurSelected:Int = 0;
	var nextCurSelected:Int = 0;
	function updateSelection(?v:Int) {
		if (v != null) {
			curSelected += v;
			if (lastCurSelected != curSelected) { //FUCK
				nextCurSelected = lastCurSelected + v;
				if (lastCurSelected != optionArray.length - 1) {
					lastCurSelected = curSelected;
					checkMoveList(v);
				} else {
					if (nextCurSelected < lastCurSelected) {
						lastCurSelected = curSelected;
						checkMoveList(v);
					}
				}
			}
			if (curSelected > optionArray.length - 1) {
				curSelected = optionArray.length - 1;
			} else if (curSelected < 0) {
				curSelected = 0;
			}
			// if (!mouseControls) {
				// if (curSelected > maxDisplay) {
					// minDisplay += 1;
					// maxDisplay += 1;
					// boxFollow.y += 60;
				// } else if (curSelected < minDisplay) {
					// minDisplay -= 1;
					// maxDisplay -= 1;
					// boxFollow.y -= 60;
				// }
			// }
		}
		for (text in optionTexts) {
			text.color = (curSelected == text.ID ? FlxColor.YELLOW : FlxColor.WHITE);
			optionBackgrounds[text.ID].color = (curSelected == text.ID ? FlxColor.WHITE : FlxColor.BLACK);
			optionBackgrounds[text.ID].alpha = (curSelected == text.ID ? 0.2 : 1);
		}
		// if (!mouseControls) {
			// var diff = curSelected - 3;
			// if (diff < 0) {
				// diff = 0;
			// }
			// minDisplay += diff;
			// maxDisplay += diff;
		// }
	}
	
	function checkMoveList(v:Int) {
		if (highestCurSelected < curSelected) {
				highestCurSelected = curSelected;
			}
			var scrollCurSelected:Int = highestCurSelected - 1;
			var diff:Int = scrollCurSelected - 3;
			if (diff < 0) {
				diff = 0;
			}
			// trace(diff);
			var currentMaxScroll:Int = 120 + (60 * (3 + diff));
			var currentMinScroll:Int = 120 + (60 * diff);
			var predictedPosition:Int = 120 + (60 * curSelected);
			if (v < 0) {
				predictedPosition -= 60;
			}
			// trace('\nMax: ' + currentMaxScroll + '\nMin: ' + currentMinScroll + '\nPredicted: ' + predictedPosition + '\nHighest: ' + highestCurSelected);
			if (predictedPosition > currentMaxScroll && v > 0) {
				boxFollow.y += 60;
			} else if (predictedPosition < currentMinScroll && v < 0) {
				boxFollow.y -= 60;
				highestCurSelected -= 1;
				// trace('shouldgo down');
			}
			// trace('Current: ' + boxFollow.y);
	}
}