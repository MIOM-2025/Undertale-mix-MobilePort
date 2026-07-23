import UndertaleText;

import funkin.editors.ui.UIState;

import funkin.editors.ui.UITextBox;
import funkin.editors.ui.UIText;
import funkin.editors.ui.UIDropDown;

//Data
var currentPage:Int = 0;
var pages:Array<String> = ['Description'];
//Box displays.
var creditName:UndertaleText = new UndertaleText(0, 0, '* Name', 'left', FlxG.width, 1.6);
var creditDescription:UndertaleText = new UndertaleText(0, 0, '* ' + pages[currentPage], 'left', FlxG.width, 1.6);
//Input boxes.
var name:UITextBox = new UITextBox(20, 142, 'Name');
var description:UITextBox = new UITextBox(name.x, name.y + 63, 'Description');
var color:UITextBox = new UITextBox(name.x, name.y + (63 * 2), '#FFFFFF');
var link:UITextBox = new UITextBox(name.x, name.y + (63 * 3), 'about:blank');
function create() {
	var box:FlxSprite = new FlxSprite().loadGraphic(Paths.image('credits/box'));
	box.scale.set(1.5, 1.5);
	box.updateHitbox();
	box.screenCenter();
	box.setPosition(box.x + 190, box.y);
	add(box);
	
	creditName.setPosition(box.x + 426, box.y + 43);
	add(creditName);
	
	creditDescription.setPosition(box.x + 42, box.y + 81);
	creditDescription.updateHitbox();
	add(creditDescription);
	
	name.members.push(new UIText(name.x, name.y - 24, 0, 'Name'));
	name.onChange = function() {
		creditName.text = '* ' + name.label.text;
	};
	add(name);
	
	description.members.push(new UIText(description.x, description.y - 24, 0, 'Description'));
	description.onChange = function() {
		pages[currentPage] = description.label.text;
		creditDescription.text = '* ' + pages[currentPage];
		creditDescription.updateHitbox();
	};
	add(description);
	
	
}

function update() {
	if (controls.BACK) {
		FlxG.switchState(new UIState(true, 'MasterDebugMenu'));
	}
}