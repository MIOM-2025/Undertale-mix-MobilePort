import UndertaleText;
import StringTools;
import haxe.Json;

import flixel.FlxObject;
//Menu.
var boxSizeSlider:FlxObject = new FlxObject();
var boxBottom:FlxSprite = new FlxSprite(0, 370).makeGraphic(867, 228, FlxColor.WHITE);
var boxTop:FlxSprite = new FlxSprite().makeGraphic(boxBottom.width - 18, boxBottom.height - 18, FlxColor.BLACK);
var boxText:UndertaleText = new UndertaleText(boxBottom.x + 248.5, boxBottom.y + 33, 
'*tung\n*tung\n*tung sahur', 'left', FlxG.width, 3, 'FFFFFF', 'undertale-pixel');
//Button stuff.
var buttonSubMenu:Bool = false;
var options:Array<String> = [
	'art', 'music', 'code', 'chart', 'misc',
];
var buttonObjects:Array<FlxSprite> = [];
var buttonSelected:Int = 0;
//Button submenu.
var boxListTexts:Map<Int, Array<UndertaleText>> = [];
var listTextsFull:Array<UndertaleText> = [];
var rowSelected:Int = 0;
var columnSelected:Int = 0;
var currentPage:Int = 0;
//Other stuff.
var dog:FlxSprite = new FlxSprite().loadGraphic(Paths.image('credits/dogs/boundbox'));
var stateCamera:FlxCamera = new FlxCamera();
function create() {
	FlxG.cameras.add(stateCamera, false);
	stateCamera.bgColor = FlxColor.TRANSPARENT;
	stateCamera.antialiasing = false;
	this.cameras = [stateCamera];
	
	var index:Int = 0;
	for (option in options) {
		var button:FlxSprite = new FlxSprite((174 * (index + 6)) - 838, 620).loadGraphic(Paths.image('credits/buttons/' + option));
		button.scale.set(1.5, 1.5);
		button.updateHitbox();
		button.ID = index;
		buttonObjects.push(button);
		add(button);
		index++;
	}
	
	// for (
	
	boxSizeSlider.y = 228;
	add(boxSizeSlider);
	
	add(boxBottom);
	boxBottom.origin.y = boxBottom.height;
	boxBottom.screenCenter(FlxAxes.X);

	add(boxTop);
	boxTop.origin.y = boxTop.height;
	boxTop.setPosition(boxBottom.x + 9, boxBottom.y + 9);

	// var box:FlxSprite = new FlxSprite(0, 126).loadGraphic(Paths.image('hi'));
	// box.scale.set(3, 3);
	// box.updateHitbox();
	// box.alpha = 0.5;
	// box.screenCenter(FlxAxes.X);
	// box.x += -64;
	// add(box);

	dog.scale.set(3, 3);
	dog.updateHitbox();
	dog.setPosition(906, boxSizeSlider.y + dog.height / 2.55);
	add(dog);
	
	var greets:Array<String> = [
		'*Thanks for playing the mod!\n*We hope you had fun!',
	];
	
	boxText.text = greets[FlxG.random.int(0, greets.length - 1)];
	boxText.lineSpacing = 3;
	boxText.updateHitbox();
	add(boxText);
	// trace(boxText);
	
			// boxTransition(!buttonSubMenu);
			// boxText.visible = false;
			// inTransition = true;
			
	var col:Int = 0;
	var row:Int = 0;
	var texts:Array<UndertaleText> = [];
	var index:Int = 0;
	for (i in 0...14) {
		var text:UndertaleText = new UndertaleText(185 + (461.9 * row), 159 + (54 * col), '*AAAAAAAAAAAAAAAA', 'left', FlxG.width, 3, 'FFFFFF', 'undertale-pixel');
		text.updateHitbox();
		text.visible = false;
		texts.push(text);
		listTextsFull.push(text);
		text.ID = index;
		add(text);
		index++;
		col++;
		if (col > 6) {
			boxListTexts.set(row, texts);
			row++;
			
			texts = [];
			col = 0;
		}
	}
	
	trace(boxListTexts);
	
	buttonChangeSelection();
}

var boxScale:Float = 2.07;
var transitionTime:Float = 0.1;
var inTransition:Bool = false;
function update(elapsed:Float) {
	if (controls.ACCEPT) {
		if (!inTransition) {
			boxTransition(!buttonSubMenu);
			boxText.visible = false;
			inTransition = true;
		}
	}
	if (inTransition) {
		return;
	}
	
	if (buttonSubMenu) {
		if (controls.UP_P) {
			updateCreditSelection(-1);
		} else if (controls.DOWN_P) {
			updateCreditSelection(1);
		} else if (controls.LEFT_P) {
			updateCreditSelection(null, -1);
		} else if (controls.RIGHT_P) {
			updateCreditSelection(null, 1);
		}
	}

	if (!buttonSubMenu) {
		if (controls.LEFT_P) {
			buttonChangeSelection(-1);
		} else if (controls.RIGHT_P) {
			buttonChangeSelection(1);
		}
	}
}

function buttonChangeSelection(?v:Int) {
	if (v != null) {
		FlxG.sound.play(Paths.sound('squeak'), Options.volumeSFX);
		buttonSelected += v;
		if (buttonSelected > buttonObjects.length - 1) {
			buttonSelected = 0;
		} else if (buttonSelected < 0) {
			buttonSelected = buttonObjects.length - 1;
		}
	}
	for (button in buttonObjects) {
		if (buttonSelected == button.ID) {
			button.color = button.color = FlxColor.fromString('#FFFF40');
		} else {
			button.color = FlxColor.fromString('#FF7F27');
		}
	}
}

var pageMax:Int = 0;
function updateCreditSelection(?c:Int, ?r:Int) {
	pageMax = creditPages[currentPage].length - 1;
	
	// trace('PAGE MAX: ' + (pageMax - (rowSelected == 0 ? 3 : 7)));
	if (c != null) {
		FlxG.sound.play(Paths.sound('squeak'), Options.volumeSFX);
		columnSelected += c;
		if (columnSelected > (pageMax - (rowSelected == 0 ? 3 : 7))) {
			columnSelected = 0;
		} else if (columnSelected < 0) {
			columnSelected = (pageMax - (rowSelected == 0 ? 3 : 7));
		}
	}
	if (r != null) {
		FlxG.sound.play(Paths.sound('squeak'), Options.volumeSFX);
		rowSelected += r;
		if (rowSelected > 1) {
			if (currentPage < creditPages.length - 1) {
				currentPage++;
			}
			rowSelected = 0;
		} else if (rowSelected < 0) {
			if (currentPage > 0) {
				currentPage--;
			}
			rowSelected = 1;
		}
		updateCreditSelection(0, null);
	}
	trace('ROW: ' + rowSelected + ' COLUMN: ' + columnSelected);

	var curIndex:Int = (rowSelected == 0 ? 0 : 7) + columnSelected;
	for (text in listTextsFull) {
		text.color = FlxColor.WHITE;
	}
	for (text in boxListTexts.get(rowSelected)) {
		if (text.ID == curIndex) {
			text.color = FlxColor.fromString('#' + creditPages[currentPage][curIndex].color);
		} else {
			text.color = FlxColor.WHITE;
		}
	}
}

function boxTransition(b:Bool) {
	if (b) {
		FlxTween.tween(boxBottom.scale, {x: boxScale / 1.8, y: boxScale}, transitionTime);
		FlxTween.tween(boxTop.scale, {x: boxScale / 1.8, y: boxScale + 0.09}, transitionTime);
		FlxTween.tween(dog, {y: (boxSizeSlider.y + dog.height / 2.55) - (118 * boxScale)}, transitionTime, {onComplete: function() {
			buttonSubMenu = !buttonSubMenu;
			inTransition = false;
			boxText.setPosition(184.8, boxBottom.y - 211);
			showCredits(options[buttonSelected]);
		}});
	} else {
		for (text in listTextsFull) {
			text.visible = false;
		}
	
		FlxTween.tween(boxBottom.scale, {x: 1, y: 1}, transitionTime);
		FlxTween.tween(boxTop.scale, {x: 1, y: 1}, transitionTime);
		FlxTween.tween(dog, {y: boxSizeSlider.y + dog.height / 2.55}, transitionTime, {onComplete: function() {
			buttonSubMenu = !buttonSubMenu;
			inTransition = false;
			boxText.setPosition(248.5, boxBottom.y + 33);
			boxText.visible = true;
		}});
	}
}

var creditPages:Array<Dynamic> = [];
function showCredits(category:String) {
	var foundData:Dynamic = getCategoryData(category);
	if (foundData.length > 0) {
		creditPages = [];
		var index:Int = 0;
		var page:Array<Dynamic> = [];
		for (data in foundData) {
			page.push(data);
			index++;
			if (index > 13) {
				creditPages.push(page);
				page = [];
				index = 0;
			}
		}
		creditPages.push(page);
	}
	for (page in creditPages) {
		var index:Int = 0;
		for (credit in page) {
			var text:UndertaleText = listTextsFull[index];
			text.text = '*' + credit.name;
			text.visible = true;
			index++;
		}
	}
	
	updateCreditSelection();
}


function getCategoryData(category:String) {
	var files:Array<String> = Paths.getFolderContent('data/credits/' + category);
	var data:Array<Dynamic> = [];
	if (files.length > 0) {
		for (file in files) {
			var text:String = Assets.getText(Paths.json('credits/' + category + '/' + StringTools.replace(file, '.json', '')));
			var creditData:Dynamic = Json.parse(text);
			data.push(creditData);
		}
	}
	return data;
}
