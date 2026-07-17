import UndertaleText;

import funkin.backend.assets.ModsFolder;
import funkin.editors.ui.UIState;
import funkin.editors.ui.UITextBox;
import funkin.editors.ui.UIText;
import funkin.editors.ui.UIButton;
import funkin.editors.ui.UICheckbox;

import haxe.Json;

import sys.io.File;

import StringTools;
// import flash.net.FileFilter;

import Reflect;
import Std;

var data = {
	var categoryName:String;
	var songs:Array<Dynamic>;
};
var songData = {
	var displayName:String;
	var song:String;
	var variation:String;
	var variationShort:String;
	var variationColor:String;
	var renderInfo:Array<Dynamic>;
	var background:String;
	var backgroundOffset:Array<Int>;
	var mechanics:Bool;
}
var renderData = {
	var image:String;
	var scale:Array<Int>;
	var offset:Array<Int>;
}

var existingSongs:Array<Dynamic> = [];
var controlsCamera = new FlxCamera();
/* 
	Main menu UI objects. 
*/
var topMenu:Array<UIContextMenuOption>;
var topMenuSprite:UITopMenu;
var categoryNameBox:UITextBox;
var createCategory:UIButton;
var loadCategory:UIButton;
var arrayThatHoldsThese:Array<Dynamic> = [];
/*
	File list loading.
*/
var filesFoundTexts:Array<UIText> = [];
var fileSelected:Int = 0;
var filesInfo:UIText;
var inFileSelector:Bool = true;
function create() {	
	/*
	renderData = {
		scale: [0, 0],
		offset: [0, 0],
	}
	existingSongs.push(songData = {
		displayName: 'hi',
		song: 'hey',
		variation: 'yo',
		variationShort: 'y',
		renderImage: 'hee',
		renderInfo: renderData,
		background: 'aadwadaw',
		mechanicsBox: true,
	});
	trace(existingSongs);
	
	var dataString:String = stringify(existingSongs[0], "\t");
	trace(dataString);
	*/
	
	categoryNameBox = new UITextBox(20, 142, 'Name');
	categoryNameBox.members.push(new UIText(categoryNameBox.x, categoryNameBox.y - 24, 0, 'Category Name'));
	add(categoryNameBox);
	arrayThatHoldsThese.push(categoryNameBox);
	
	var buttonWidth:Int = 100;
	createCategory = new UIButton(categoryNameBox.x, categoryNameBox.y + 51, 'Create', function() {
		inFileSelector = false;
		setupSongMenu();
	}, buttonWidth);
	add(createCategory);
	arrayThatHoldsThese.push(createCategory);
	
	var filesList = Paths.getFolderContent('data/categories/', false, -1, true);
	loadCategory = new UIButton((createCategory.x + createCategory.field.width) + 11, createCategory.y, 'Load', function() {
		inFileSelector = false;
		loadCategoryFunction();
	}, buttonWidth);
	if (filesList.length > 0) {
		add(loadCategory);	
		arrayThatHoldsThese.push(loadCategory);
	}
	
	filesInfo = new UIText(loadCategory.x, 0, 0, 'FILES FOUND:');
	filesInfo.y = (filesList.length > 0 ? (loadCategory.y + loadCategory.field.height) + filesInfo.height : loadCategory.y);
	add(filesInfo);
	arrayThatHoldsThese.push(filesInfo);

	var fileIndex:Int = 0;
	if (filesList.length > 0) {
		for (file in filesList) {
			var text:UIText = new UIText(0, 0, 0, file);
			text.setPosition(loadCategory.x + loadCategory.field.width / 2, (loadCategory.y + loadCategory.field.height) + (text.height * (fileIndex + 2)));
			text.ID = fileIndex;
			add(text);
			filesFoundTexts.push(text);
			fileIndex++;
		}
		updateFileSelection();
	} else {
		var text:UIText = new UIText(0, 0, 0, 'NONE');
		text.setPosition(loadCategory.x + loadCategory.field.width / 2, loadCategory.y + (text.height));
		add(text);
		arrayThatHoldsThese.push(text);
	}
	
	FlxG.cameras.add(controlsCamera, false);
	controlsCamera.bgColor = FlxColor.TRANSPARENT;
	controlsCamera.visible = false;
	
	var blackBackground:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	blackBackground.screenCenter();
	blackBackground.cameras = [controlsCamera];
	blackBackground.alpha = 0.5;
	add(blackBackground);
	
	var controlText:UITextBox = new UIText(0, 0, 0, "MAIN EDITOR\nPress [TAB] to switch to render edit mode.\nPress [SHIFT] + [UP]/[DOWN] arrow key to switch through songs in song tree.\nPress [ENTER] to preview the selected song's data, press [ENTER] again to close.\n\nRENDER MENU\nPress [UP], [DOWN], [LEFT] or [RIGHT] arrow keys to change offsets.\nHold [SHIFT] to change offsets by 10 pixels instead of 1.", 22);
	controlText.alignment = 'center';
	controlText.screenCenter();
	controlText.cameras = [controlsCamera];
	add(controlText);
}

var songTree:UIText;
var pushSongButton:UIButton;
var removeSongButton:UIButton;
var saveSongButton:UIButton;
var saveCategoryButton:UIButton;
var insertSongButton:UIButton;
var treeTexts:Array<UIText> = [];
var treeSelection:Int = 0;
var savedChanges:Bool = true;
/* 
	Song menu UI Objects. 
*/
var box:FlxSprite = new FlxSprite(904, 270).loadGraphic(Paths.image('freeplay/box'));
var title:UndertaleText = new UndertaleText(box.x - 80, box.y - 118, 'hi', 'left', FlxG.width, 2.0, 'FFFFFF', 'undertale');
var weekName:UIText;
var displayName:UITextBox;
var songName:UITextBox;
var variationTag:UITextBox;
var variationTagShort:UITextBox;
var variationColor:UITextBox;
var variationText:UndertaleText;
var songBackground:UITextBox;
var mechanicsBox:UICheckbox;
var switchInfoText:UIText;
var insertPositionBox:UITextBox;
var renderInfo:UIText;
var songInfoText:UIText;
var switchInfoText:UIText;
var arrayThatHoldsAllThat:Array<Dynamic> = [];
var treeSelectIndicator:UIText;
/* 
	Render edit UI Objects. 
*/
var arrayThatHoldsAllThatButForTheRenderEditMenu:Array<Dynamic>;
var background:FlxSprite;
var render:FlxSprite;
var box:FlxSprite;
var backgroundBox:UITextBox;
var renderBox:UITextBox;
var scaleBox:UITextBox;
var offsetInfo:UIText;
var inRenderEdit:Bool = false;
var offsetObject:Dynamic;
function setupSongMenu() {
	for (object in arrayThatHoldsThese) { object.kill(); }
	
	weekName = new UIText(categoryNameBox.x, categoryNameBox.y - 22, 0, 'Category name: ' + categoryNameBox.label.text, 20);
	add(weekName);
	arrayThatHoldsAllThat.push(weekName);
	
	saveCategoryButton = new UIButton((weekName.x + weekName.width) + 11, weekName.y, 'Save', function() {
		saveCategoryFunction();
	});
	saveCategoryButton.members.push(new UIText(saveCategoryButton.x, saveCategoryButton.y - 24, 0, 'Save Category'));
	add(saveCategoryButton);
	arrayThatHoldsAllThat.push(saveCategoryButton);
	
	switchInfoText = new UIText(0, FlxG.height - 44, 0, 'HOLD [F1] TO SEE CONTROLS', 30);
	switchInfoText.setPosition(FlxG.width - switchInfoText.width, FlxG.height - 44);
	add(switchInfoText);
	arrayThatHoldsAllThat.push(switchInfoText);
	
	songInfoText = new UIText(weekName.x, weekName.y + 55, 0, 'Song Information:', 30);
	add(songInfoText);
	arrayThatHoldsAllThat.push(songInfoText);
	
	displayName = new UITextBox(songInfoText.x, songInfoText.y + 66, 'Name');
	displayName.members.push(new UIText(displayName.x, displayName.y - 24, 0, 'Display Name'));
	displayName.onChange = function() {
		savedChanges = false;
	}
	add(displayName);
	arrayThatHoldsAllThat.push(displayName);
	
	songName = new UITextBox(displayName.x, displayName.y + 66, 'Name');
	songName.members.push(new UIText(songName.x, songName.y - 24, 0, 'Song Folder'));
	add(songName);
	songName.onChange = function() {
		savedChanges = false;
	}
	arrayThatHoldsAllThat.push(songName);
	
	/* Everything from here is literally just for the variation tags. */
	var variationWidth:Int = 120;
	variationTag = new UITextBox(songName.x, songName.y + 66, 'Tag', variationWidth);
	variationTag.members.push(new UIText(variationTag.x, variationTag.y - 24, 0, 'Variation Tag'));
	variationTag.onChange = function() {
		savedChanges = false;
	}
	add(variationTag);
	arrayThatHoldsAllThat.push(variationTag);
	
	variationTagShort = new UITextBox(variationTag.x + (variationTag.label.width + 11), variationTag.y, 'Tag', variationWidth);
	variationTagShort.members.push(new UIText(variationTagShort.x, variationTagShort.y - 24, 0, 'Short Tag'));
	variationTagShort.onChange = function() {
		var displayVariationText:String = variationTag.label.text + ' (' + variationTagShort.label.text + ')';
		variationText.text = displayVariationText.toLowerCase();
		savedChanges = false;
	}
	add(variationTagShort);
	arrayThatHoldsAllThat.push(variationTagShort);
	
	variationColor = new UITextBox(variationTagShort.x + (variationTag.label.width + 11), variationTag.y, '#FFFFFF', variationWidth);
	variationColor.members.push(new UIText(variationColor.x, variationColor.y - 24, 0, 'Tag Color'));
	variationColor.onChange = function() {
		var colorString:String = variationColor.label.text.toUpperCase();
		if (colorString.length < 7) {
			for (i in 0...(6 - colorString.length)) {
				colorString = colorString + '0';
			}
		}
		variationText.color = FlxColor.fromString(colorString);
		variationColor.label.text = colorString;
		savedChanges = false;
	}
	add(variationColor);
	arrayThatHoldsAllThat.push(variationColor);
	
	variationText = new UndertaleText(variationColor.x + (variationColor.label.width + 11), variationColor.y + 11, '', 'left', FlxG.width, 2, 'FFFFFF', 'wonder');
	variationText.updateHitbox();
	add(variationText);
	arrayThatHoldsAllThat.push(variationText);
	var displayVariationText:String = variationTag.label.text + ' (' + variationTagShort.label.text + ')';
	variationText.text = displayVariationText.toLowerCase();
	
	variationTag.onChange = function() {
		var displayVariationText:String = variationTag.label.text + ' (' + variationTagShort.label.text + ')';
		variationText.text = displayVariationText.toLowerCase();
		savedChanges = false;
	}
	/* Ok it's over. */
	
	mechanicsBox = new UICheckbox(songName.x, variationColor.y + 46, 'Mechanics');
	mechanicsBox.onChecked = function() {
		savedChanges = false;
	}
	add(mechanicsBox);
	arrayThatHoldsAllThat.push(mechanicsBox);
	
	treeSelectIndicator = new UIText(0, 0, 0, '▼', 20);
	arrayThatHoldsAllThat.push(treeSelectIndicator);
	add(treeSelectIndicator);
	
	renderInfo = new UIText(mechanicsBox.x, mechanicsBox.y + 28, 0, 'RENDER DATA:', 20);
	add(renderInfo);
	arrayThatHoldsAllThat.push(renderInfo);
	updateRenderInformation(fetchRenderData());
	
	songTree = new UIText(switchInfoText.x, weekName.y, 0, categoryNameBox.label.text + ':\n', 20);
	add(songTree);
	arrayThatHoldsAllThat.push(songTree);
	generateSongTree();
	updateTreeSelection();
	
	insertSongButton = new UIButton(0, switchInfoText.y, 'Insert', function() {
		insertButtonFunction();
	}, 100);
	insertSongButton.setPosition((FlxG.width - switchInfoText.width) - (insertSongButton.field.width + 11), insertSongButton.y);
	add(insertSongButton);
	arrayThatHoldsAllThat.push(insertSongButton);
	
	insertPositionBox = new UITextBox(insertSongButton.x, (insertSongButton.y - insertSongButton.field.height) - 22, '0', 30);
	insertPositionBox.members.push(new UIText(insertPositionBox.x, insertPositionBox.y - 24, 0, 'Insert Position'));
	add(insertPositionBox);
	arrayThatHoldsAllThat.push(insertPositionBox);
	
	pushSongButton = new UIButton(0, switchInfoText.y, 'Add', function() {
		pushButtonFunction();
	}, 100);
	pushSongButton.setPosition((insertSongButton.x - insertSongButton.field.width) - 11, pushSongButton.y);
	add(pushSongButton);
	arrayThatHoldsAllThat.push(pushSongButton);
	
	removeSongButton = new UIButton(0, switchInfoText.y, 'Remove', function() {
		removeButtonFunction();
	}, 100);
	removeSongButton.setPosition((pushSongButton.x - pushSongButton.field.width) - 11, pushSongButton.y);
	add(removeSongButton);
	arrayThatHoldsAllThat.push(removeSongButton);
	
	saveSongButton = new UIButton(0, switchInfoText.y, 'Save', function() {
		saveButtonFunction();
	}, 100);
	saveSongButton.setPosition((removeSongButton.x - removeSongButton.field.width) - 11, pushSongButton.y);
	saveSongButton.members.push(new UIText(saveSongButton.x, saveSongButton.y - 24, 0, 'Song Controls'));
	add(saveSongButton);
	arrayThatHoldsAllThat.push(saveSongButton);
	
	if (existingSongs.length == 0) {
		pushButtonFunction();
	}
	setupRenderEdit();
}

// function postCreate() {
	// setupRenderEdit();
// }

function setupRenderEdit() {
	// inRenderEdit = true;
	arrayThatHoldsAllThatButForTheRenderEditMenu = [];
	
	// var currentRenderData:Dynamic = fetchRenderData();
	
	background = new FlxSprite().loadGraphic(Paths.image('freeplay/bgs/' + existingSongs[treeSelection].background));
	background.antialiasing = false;
	background.scale.set(5, 5);
	background.updateHitbox();
	background.screenCenter();
	background.x -= 350;
	add(background);
	arrayThatHoldsAllThatButForTheRenderEditMenu.push(background);
	
	var renderData:Dynamic = fetchRenderData();
	render = new FlxSprite().loadGraphic(Paths.image('freeplay/renders/' + renderData.image));
	render.screenCenter(FlxAxes.Y);
	add(render);
	render.scale.set(renderData.scale[0], renderData.scale[1]);
	render.offset.set(renderData.offset[0], renderData.offset[1]);
	arrayThatHoldsAllThatButForTheRenderEditMenu.push(render);
	offsetObject = render;
	
	box = new FlxSprite(704, 270).loadGraphic(Paths.image('freeplay/box'));
	box.antialiasing = false;
	box.scale.set(2, 2);
	box.screenCenter();
	box.setPosition(box.x + 281, box.y - 1);
	add(box);
	arrayThatHoldsAllThatButForTheRenderEditMenu.push(box);
	
	var boxWidth:Int = 120;
	backgroundBox = new UITextBox(categoryNameBox.x, categoryNameBox.y, existingSongs[treeSelection].background, boxWidth);
	backgroundBox.members.push(new UIText(backgroundBox.x, backgroundBox.y - 24, 0, 'Background'));
	backgroundBox.onChange = function() {
		background.loadGraphic(Paths.image('freeplay/bgs/' + backgroundBox.label.text));
		savedChanges = false;
		// existingSongs[treeSelection].background = backgroundBox.label.text;
	}
	add(backgroundBox);
	arrayThatHoldsAllThatButForTheRenderEditMenu.push(backgroundBox);
	
	renderBox = new UITextBox((backgroundBox.x + backgroundBox.label.width) + 11, backgroundBox.y, existingSongs[treeSelection].renderInfo.image, boxWidth);
	renderBox.members.push(new UIText(renderBox.x, renderBox.y - 24, 0, 'Render'));
	renderBox.onChange = function() {
		render.loadGraphic(Paths.image('freeplay/renders/' + renderBox.label.text));
		savedChanges = false;
		// existingSongs[treeSelection].renderInfo.image = renderBox.label.text;
	}
	add(renderBox);
	arrayThatHoldsAllThatButForTheRenderEditMenu.push(renderBox);
	
	scaleBox = new UITextBox((renderBox.x + renderBox.label.width) + 11, renderBox.y, existingSongs[treeSelection].renderInfo.scale[0], boxWidth);
	scaleBox.members.push(new UIText(scaleBox.x, scaleBox.y - 24, 0, 'Scale'));
	scaleBox.onChange = function() {
		render.scale.set(scaleBox.label.text, scaleBox.label.text);
		savedChanges = false;
		// existingSongs[treeSelection].renderInfo.scale = [render.scale.x, render.scale.y];
	}
	add(scaleBox);
	arrayThatHoldsAllThatButForTheRenderEditMenu.push(scaleBox);
	
	offsetInfo = new UIText(backgroundBox.x, backgroundBox.y + 44, 0, 'OFFSET: [' + existingSongs[treeSelection].renderInfo.offset[0] + ', ' + existingSongs[treeSelection].renderInfo.offset[1] + ']', 20);
	add(offsetInfo);
	arrayThatHoldsAllThatButForTheRenderEditMenu.push(offsetInfo);
	
	for (object in arrayThatHoldsAllThatButForTheRenderEditMenu) {
		object.kill();
	}
}

/*
	Render menu functions.
*/
function exitRenderEditMode() {
	inRenderEdit = false;
	for (object in arrayThatHoldsAllThatButForTheRenderEditMenu) {
		object.kill();
	}
	for (object in arrayThatHoldsAllThat) {
		object.revive();
	}
	checkTextVisibility(true);
}

function enterRenderEdit() {
	inRenderEdit = true;
	for (object in arrayThatHoldsAllThatButForTheRenderEditMenu) {
		object.revive();
	}
}

function updateOffset(x:Int, y:Int, ?affectSave:Bool) {
	offsetObject.offset.set(offsetObject.offset.x + x, offsetObject.offset.y + y);
	// existingSongs[treeSelection].renderInfo.offset = [offsetObject.offset.x, offsetObject.offset.y];
	offsetInfo.text = 'OFFSET: ' + '[' + offsetObject.offset.x + ', ' + offsetObject.offset.y + ']';
	if (affectSave == null || affectSave) {
		savedChanges = false;
	}
}

/* 
	Info display functions.
*/

function generateSongTree() {
	if (treeTexts.length > 0) {
		for (text in treeTexts) {
			text.destroy();
		}
		treeTexts = [];
	}
	treeSelectIndicator.visible = (existingSongs.length > 0);
	if (existingSongs.length > 0) {
		var index:Int = 0;
		for (songs in existingSongs) {
			var text:UIText = new UIText(songTree.x + 36, songTree.y + 22 + (20 * index), 0, songs.displayName, 20);
			text.ID = index;
			treeTexts.push(text);
			add(text);
			index++;
		}
	} else {
		var text:UIText = new UIText(songTree.x + 36, songTree.y + 22, 0, 'NONE', 20);
		treeTexts.push(text);
		add(text);
	}
}

var selectedText:UIText;
function updateTreeSelection(?v:Int) {
	if (inRenderEdit) { return; }
	if (v != null) {
		treeSelection += v;
		if (treeSelection > existingSongs.length - 1) {
			treeSelection = 0;
		} else if (treeSelection < 0) {
			treeSelection = existingSongs.length - 1;
		}
		updateDisplayedData();
	}
	
	if (treeTexts.length > 0) {
		for (text in treeTexts) {
			if (text.ID == treeSelection) {
				selectedText = text;
			}
			text.color = (text.ID == treeSelection ? FlxColor.YELLOW : FlxColor.WHITE);
		}
	}
	if (selectedText != null) {
		treeSelectIndicator.setPosition(selectedText.x - 16, selectedText.y);
	}
}

function updateFileSelection(?v:Int) {
	if (v != null) {
		fileSelected += v;
		if (fileSelected > filesFoundTexts.length - 1) {
			fileSelected = 0;
		} else if (fileSelected < 0) {
			fileSelected = filesFoundTexts.length - 1;
		}
	}
	for (text in filesFoundTexts) {
		text.color = (text.ID == fileSelected ? FlxColor.YELLOW : FlxColor.WHITE);
	}
}

function updateDisplayedData() {
	displayName.label.text = existingSongs[treeSelection].displayName;
	songName.label.text = existingSongs[treeSelection].song;
	variationTag.label.text = existingSongs[treeSelection].variation;
	variationTagShort.label.text = existingSongs[treeSelection].variationShort;
	variationColor.label.text = existingSongs[treeSelection].variationColor;
	mechanicsBox.checked = existingSongs[treeSelection].mechanics;
	renderBox.label.text = existingSongs[treeSelection].renderInfo.image;
	render.loadGraphic(Paths.image('freeplay/renders/' + existingSongs[treeSelection].renderInfo.image));
	render.offset.set(existingSongs[treeSelection].renderInfo.offset[0], existingSongs[treeSelection].renderInfo.offset[1]);
	render.scale.set(existingSongs[treeSelection].renderInfo.scale[0], existingSongs[treeSelection].renderInfo.scale[1]);
	scaleBox.label.text = existingSongs[treeSelection].renderInfo.scale[0];
	backgroundBox.label.text = existingSongs[treeSelection].background;
	background.loadGraphic(Paths.image('freeplay/bgs/' + existingSongs[treeSelection].background));
	// render.offset.set(existingSongs[treeSelection].renderInfo.offset[0], existingSongs[treeSelection].renderInfo.offset[1]);
	// render.scale.set(existingSongs[treeSelection].renderInfo.scale[0], existingSongs[treeSelection].renderInfo.scale[1]);
	updateOffset(0, 0, false);
	updateRenderInformation(renderData = {
		image: existingSongs[treeSelection].renderInfo.image,
		offset:	existingSongs[treeSelection].renderInfo.offset,
		scale: existingSongs[treeSelection].renderInfo.scale,
	});
}

function compareCurrentAndSavedData() {
	trace("Match " + (savedChanges ? "found." : "not found."));
	return savedChanges;
}

function updateRenderInformation(data:Dynamic) {
	var printedData:String = stringify(data, null, " ");
	renderInfo.text = 'RENDER DATA:\n' + printedData;
}

var watchingInfo:Bool = false;
function showSongInformation() {
	if (existingSongs.length > 0) {
		var jsonInfo:String = stringify(existingSongs[treeSelection], null, "\t");
		updateTreeSelection();
		selectedText.text = existingSongs[treeSelection].displayName + ':\n' + jsonInfo;
	}
	checkTextVisibility();
	treeSelectIndicator.text = '▲';
	watchingInfo = true;
}

function stopShowingInfo() {
	if (selectedText != null) {
		selectedText.text = existingSongs[treeSelection].displayName;
	}
	checkTextVisibility(true);
	treeSelectIndicator.text = '▼';
	watchingInfo = false;
	updateTreeSelection();
}

function checkTextVisibility(?allVisible:Bool) {
	if (treeTexts.length > 0) {
		for (text in treeTexts) {
			if (allVisible != null) {
				text.visible = allVisible;
			} else {
				text.visible = !(text.ID > treeSelection);
			}
		}
	}
}

/*
	Data functions.
*/
var heldRenderData:Dynamic;
function fetchRenderData() {
	// trace(existingSongs[treeSelection].renderInfo);
	if (renderBox != null && scaleBox != null && backgroundBox != null) {
		trace('Render data found.');
		renderData = {
			image: renderBox.label.text,
			offset: [render.offset.x, render.offset.y],
			scale: [render.scale.x, render.scale.y],
		}
	} else {
		trace('No render data found.');
		renderData = {
			image: "chara",
			scale: [0.75, 0.75],
			offset: [40, -102],
		};
	}
	return renderData;
}

function createSongData() {
	var renderData:Dynamic = fetchRenderData();
	songData = {
		displayName: displayName.label.text,
		song: songName.label.text,
		variation: variationTag.label.text,
		variationShort: variationTagShort.label.text,
		variationColor: variationColor.label.text,
		renderInfo: renderData,
		background: (backgroundBox != null ? backgroundBox.label.text : 'flowerbed'), 
		backgroundOffset: [(background != null ? background.offset.x : 0), (background != null ? background.offset.x : 0)],
		mechanics: mechanicsBox.checked,
	};
	return songData;
}

/*
	Button functions.
*/
function pushButtonFunction() {
	savedChanges = true;
	existingSongs.push(createSongData());
	treeSelection = existingSongs.length - 1;
	stopShowingInfo();
	generateSongTree();
	updateTreeSelection();
}

function removeButtonFunction() {
	savedChanges = true;
	var removedSong:Dynamic = existingSongs[treeSelection];
	existingSongs.remove(removedSong);
	generateSongTree();
	treeSelection--;
	updateTreeSelection();
}

function saveButtonFunction() {
	savedChanges = true;
	existingSongs[treeSelection] = createSongData();
	generateSongTree();
	updateTreeSelection();
	updateRenderInformation(fetchRenderData());
	if (watchingInfo) {
		showSongInformation();
	}
}

function saveCategoryFunction() {
	var data = {
		categoryName: categoryNameBox.label.text,
		songs: existingSongs,
	}
	var stringData:String = stringify(data);
	var formattedName:String = StringTools.replace(StringTools.replace(data.categoryName.toLowerCase(), "'", ''), ' ', '-');
	// CoolUtil.browsePath(ModsFolder.modsPath + ModsFolder.currentModFolder + '/data/categories');
	CoolUtil.safeSaveFile(ModsFolder.modsPath + ModsFolder.currentModFolder + '/data/categories/' + formattedName + '.json', stringData);
	// trace(stringify(data));
}

function insertButtonFunction() {
	var insertData:Dynamic = existingSongs[treeSelection];
	var insertInto:Int = Std.parseInt(insertPositionBox.label.text);
	existingSongs.remove(insertData);
	existingSongs.insert(insertInto, insertData);
	generateSongTree();
	treeSelection = insertInto;
	updateTreeSelection();
}

function loadCategoryFunction() {
	var load:String = filesFoundTexts[fileSelected].text;
	var parsedData:Array<Dynamic> = Json.parse(Assets.getText(Paths.json('categories/' + load)));
	categoryNameBox.label.text = parsedData.categoryName;
	for (song in parsedData.songs) {
		existingSongs.push(song);
	}
	for (text in filesFoundTexts) {
		text.kill();
	}
	setupSongMenu();
}

/*
	Helper functions.
*/
function stringify(json:String) {
	return Json.stringify(json, null, " ");
}

function focusedOnAnyTextBox() {
	for (box in [displayName, songName, variationTag, variationTagShort, variationColor, insertSongButton, backgroundBox, renderBox, scaleBox]) {
		if (box.__wasFocused) {
			return true;
		}
	}
	return false;
}

/*
	File saving.
*/
var savingFile:FileReference;


var mult:Int = 1;
function update() {
	if (FlxG.keys.justPressed.ESCAPE) {
		if (!watchingInfo && !inRenderEdit) {
			FlxG.switchState(new UIState(true, 'MasterDebugMenu'));
		} else if (inRenderEdit) {
			exitRenderEditMode();
			updateRenderInformation(renderData = {
				image: renderBox.label.text,
				offset: [render.offset.x, render.offset.y],
				scale: [render.scale.x, render.scale.y],
			});
		}
	}
	
	if (inFileSelector) {
		if (FlxG.keys.justPressed.UP) {
			updateFileSelection(-1);
		} else if (FlxG.keys.justPressed.DOWN) {
			updateFileSelection(1);
		}
	}
	if (inFileSelector) { return; }
	
	if (FlxG.keys.justPressed.ENTER) {
		if (!watchingInfo && !inRenderEdit && !focusedOnAnyTextBox()) {
			showSongInformation();
		} else if (watchingInfo && !inRenderEdit && !focusedOnAnyTextBox()) {
			stopShowingInfo();
		}
	} else if (FlxG.keys.justPressed.TAB) {
		if (!inRenderEdit && existingSongs.length > 0) {
			checkTextVisibility(false);
			// if (arrayThatHoldsAllThatButForTheRenderEditMenu != null) {
				enterRenderEdit();
			// } else {
				// setupRenderEdit();
			// }
		} else {
			trace('What are you trying to change?');
		}
	}
	
	if (FlxG.keys.pressed.SHIFT && !inRenderEdit) {
		// trace(compareCurrentAndSavedData());
		if (FlxG.keys.justPressed.UP) {
			if (compareCurrentAndSavedData()) {
				updateTreeSelection(-1);
			} else {
				// trace('saved and edited song data dont match');
			}
		} else if (FlxG.keys.justPressed.DOWN) {
			if (compareCurrentAndSavedData()) {
				updateTreeSelection(1);
			} else {
				// trace('saved and edited song data dont match');
			}
		}
	}
	
	mult = (FlxG.keys.pressed.SHIFT ? 10 : 1);
	if (inRenderEdit) {
		if (FlxG.keys.justPressed.UP && !focusedOnAnyTextBox()) {
			updateOffset(0, mult);
		} else if (FlxG.keys.justPressed.DOWN && !focusedOnAnyTextBox()) {
			updateOffset(0, -mult);
		} else if (FlxG.keys.justPressed.LEFT && !focusedOnAnyTextBox()) {
			updateOffset(mult, 0);
		} else if (FlxG.keys.justPressed.RIGHT && !focusedOnAnyTextBox()) {
			updateOffset(-mult, 0);
		}
	}
	
	// if (arrayThatHoldsAllThatButForTheRenderEditMenu == null) {
		// setupRenderEdit();
	// }
	
	controlsCamera.visible = FlxG.keys.pressed.F1;
}