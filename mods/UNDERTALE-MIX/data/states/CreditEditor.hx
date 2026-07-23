import UndertaleText;

import funkin.editors.ui.UITextBox;
import funkin.editors.ui.UIButton;
import funkin.editors.ui.UIText;
import funkin.editors.ui.UIImageExplorer;
import funkin.editors.ui.SaveSubstate;

import funkin.editors.ui.UIState;

import funkin.backend.assets.ModsFolder;
// import funkin.editors.ui.UIImageExplorer.ImageSaveData;

import StringTools;

var creditName:UndertaleText;
var creditDescription:UndertaleText;
var currentPage:Int = 0;
var pages:Array<String> = ['Description'];

var nameBox:UITextBox;
var descriptionBox:UITextBox;
var colorBox:UITextBox;
var imageExplorer:UIImageExplorer;
function create() {
	var box:FlxSprite = new FlxSprite().loadGraphic(Paths.image('credits/box'));
	box.scale.set(1.5, 1.5);
	box.updateHitbox();
	box.screenCenter();
	box.setPosition(box.x + 190, box.y);
	add(box);
	trace(ModsFolder.modsPath + ModsFolder.currentModFolder);

	creditName = new UndertaleText(box.x + 426, box.y + 43, '* Name',  'left', FlxG.width, 1.6);
	add(creditName);
	
	creditDescription = new UndertaleText(box.x + 42, box.y + 81, '* ' + pages[currentPage], 'left', FlxG.width, 1.6);
	creditDescription.updateHitbox();
	add(creditDescription);
	
	nameBox = new UITextBox(20, 142, 'Name');
	nameBox.members.push(new UIText(nameBox.x, nameBox.y - 24, 0, 'Name'));
	nameBox.onChange = function() {
		creditName.text = '* ' + nameBox.label.text;
		if (imageExplorer.uiElement != null) {
			imageExplorer.imageName = nameBox.label.text;
		}
	};
	add(nameBox);
	
	descriptionBox = new UITextBox(nameBox.x, nameBox.y + 63, 'Description');
	descriptionBox.members.push(new UIText(descriptionBox.x, descriptionBox.y - 24, 0, 'Description'));
	descriptionBox.onChange = function() {
		pages[currentPage] = descriptionBox.label.text;
		var desc:String = StringTools.replace(descriptionBox.label.text, '/', '\n  ');
		creditDescription.text = '* ' + pages[currentPage];
		creditDescription.updateHitbox();
	};
	add(descriptionBox);
	
	colorBox = new UITextBox(nameBox.x, nameBox.y + (63 * 2), '#FFFFFF');
	colorBox.members.push(new UIText(colorBox.x, colorBox.y - 24, 0, 'Color (Hex)'));
	colorBox.onChange = function() {
		var colorString:String = colorBox.label.text.substring(1, 7).toUpperCase();
		if (colorString.length < 7) {
			for (i in 0...(6 - colorString.length)) {
				colorString = colorString + '0';
			}
		}
		colorString = '#' + colorString;
		var color:FlxColor = FlxColor.fromString(colorString);
		colorBox.label.text = colorString;
		creditName.color = color;
	};
	add(colorBox);
	
	var linkBox = new UITextBox(nameBox.x, nameBox.y + (63 * 3), 'about:blank');
	linkBox.members.push(new UIText(linkBox.x, linkBox.y - 24, 0, 'Link'));
	add(linkBox);
	
	var saveButton:UIButton = new UIButton(nameBox.x, nameBox.y + (63 * 7), 'Save', function() {
		var path:String = ModsFolder.modsPath + ModsFolder.currentModFolder + '/images/credits/dogs';
		var fileContent:String = '
			{
				"desc":' + pages + ',
				"color": "' + colorBox.label.text + '",
				"name": "' + nameBox.label.text + '",
				"link": "' + linkBox.label.text + '"
			}
		';
		FlxG.openSubstate(new SaveSubstate(fileContent, {defaultSaveFile: nameBox.label.text + '.json'}));
		imageExplorer.saveFilesGlobal(imageExplorer.getSaveData(), path, function() {
			trace('Saved at [' + path + '].');
		});
		// CoolUtil.safeSaveFile(Paths.getAssetsRoot() + /data/credits
	});
	add(saveButton);
	
	var exitButton:UIButton = new UIButton(saveButton.x + nameBox.bWidth - 120, saveButton.y, 'Exit', function() {
	});
	add(exitButton);
	
	var loadButton:UIButton = new UIButton(saveButton.x, saveButton.y + 51, 'Load', function() {
	});
	add(loadButton);

	var offset:Int = -50;
	var nextPageButton:UIButton = new UIButton(saveButton.x + ((nameBox.bWidth - 120) * 5), saveButton.y + 51, 'Next', function() {
		updatePage(1);
	});
	nextPageButton.x += offset;
	add(nextPageButton);
	
	var createPageButton:UIButton = new UIButton(saveButton.x + ((nameBox.bWidth - 120) * 4), saveButton.y + 51, 'Create', function() {
		currentPage = pages.length;
		pages[currentPage] = 'Description';
		updatePage(0);
		trace('hey' + pages);
	});
	createPageButton.x += offset;
	add(createPageButton);
	
	var previousPageButton:UIButton = new UIButton(saveButton.x + ((nameBox.bWidth - 120) * 3), saveButton.y + 51, 'Previous', function() {
		updatePage(-1);
	});
	previousPageButton.x += offset;
	add(previousPageButton);
	
	pageControls = new UIText(previousPageButton.x, previousPageButton.y - 24, 0, 'Page Controls (Page 1)');
	previousPageButton.members.push(pageControls);
	
	imageExplorer = new UIImageExplorer(nameBox.x, nameBox.y + (63 * 5) - 64, null, 35 * 3, 34 * 3, (_) -> {updateDog();}, 'images/credits/dogs');
	imageExplorer.members.push(new UIText(imageExplorer.x, imageExplorer.y - 24, 0, 'Dog Image File'));
	imageExplorer.maxSize.set(100, 100);
	add(imageExplorer);
}

function update() {
	if (FlxG.keys.justPressed.ESCAPE) {
		FlxG.switchState(new ModState('MasterDebugMenu'));
	}
}

function updatePage(?v:Int) {
	if (v != null) {
		currentPage += v;
		if (currentPage > pages.length - 1) {
			currentPage = 0;
		} else if (currentPage < 0) {
			currentPage = pages.length - 1;
		}
		creditDescription.text = '* ' + pages[currentPage];
		descriptionBox.label.text = pages[currentPage];
		pageControls.text = 'Page Controls (Page ' + (currentPage + 1) + ')';
	}
}

function updateDog() {
	trace('got image!');
	imageExplorer.uiElement.antialiasing = false;
	imageExplorer.fileText.text = '';
}

function saveAndExit() {
	
}