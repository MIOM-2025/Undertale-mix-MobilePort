import haxe.Json;
import sys.FileSystem;
import funkin.backend.assets.ModsFolder;
import flixel.util.FlxStringUtil;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import funkin.savedata.FunkinSave;
import funkin.backend.utils.DiscordUtil;

var songs:Array<Dynamic> = [];
var groups:Array<String> = [];
var songSelected:Int = 0;
var groupSelected:Int = 0;
var subMenu:Bool = false;
var songExists:Bool = false;
var theme:FlxSound = FlxG.sound.load(Paths.music('freeplaytheme'), 0, true);

var render:FlxSprite;
var background:FlxSprite;
var box:FlxSprite;

var groupTitle:FlxBitmapText;
var groupTexts:FlxTypedGroup<FlxBitmapText> = new FlxTypedGroup();
var otherTexts:FlxTypedGroup<FlxBitmapText> = new FlxTypedGroup();
var boxTexts:FlxTypedGroup<FlxBitmapText> = new FlxTypedGroup();

var undertaleFont:FlxBitmapFont;
var dotumcheFont:FlxBitmapFont;
var cryptFont:FlxBitmapFont;
var wonderFont:FlxBitmapFont;
function create() {
	var fileList = FileSystem.readDirectory(ModsFolder.modsPath + ModsFolder.currentModFolder + '/data/freeplay_data/weeks');
	for (file in fileList) {
		groups.push(FlxStringUtil.remove(file, '.json'));
	}
	
	DiscordUtil.changePresence("Scrolling through menus.", "In Freeplay");
	
	undertaleFont = getFont('ut-text', 'AaBbCcDdEeFf' + 'GgHhIiJjKkLl' + 'MmNnOoPpQqRr' + 'SsTtUuVvWwXx' + 'YyZz01234567' + '89!#%&$*"/@?' + '+>}{<_~=-])[' + "(,.|'^;: ");
	dotumcheFont = getFont('dotumche', 'AaBbCcDdEeFf' + 'GgHhIiJjKkLl' + 'MmNnOoPpQqRr' + 'SsTtUuVvWwXx' + 'YyZz01234567' + '89!#%&$*"/@?' + '+>}{<_~=-])[' + "(,.|^;:' ");
	cryptFont = getFont('cryptoftomorrow', "abcdefgh" + "ijklmnop" + "qrstuvwx" + "yz123456" + "789.,:;'" + '"()!?+-/' + "=0% ");
	wonderFont = getFont('8bitwonder', "abcdef" + "ghijkl" + "mnopqr" + "stuvwx" + "yz1234" + "567890" + "' ");
	
	if (FlxG.sound.music != null) {
		FlxG.sound.music.volume = 0;
	}
	
	theme.play();
	theme.pitch = 0.9;
	
	background = new FlxSprite().loadGraphic(Paths.image('freeplay/placeholder'));
	background.antialiasing = false;
	background.scale.set(5, 5);
	background.updateHitbox();
	background.screenCenter();
	background.x -= 350;
	add(background);
	
	render = new FlxSprite().loadGraphic(Paths.image('freeplay/placeholderrender'));
	render.alpha = 0;
	
	for (i in 0...6) {
		var fade = new FlxSprite(460 + (80 * i), 300).loadGraphic(Paths.image('freeplay/fadedither'));
		fade.scale.set(5, 5);
		fade.screenCenter(FlxAxes.Y);
		fade.antialiasing = false;
		fade.alpha = 0.8;
		add(fade);
		
		var fade_c = new FlxSprite(fade.x + 90, fade.y).makeGraphic(500, FlxG.height, FlxColor.BLACK);
		fade_c.screenCenter(FlxAxes.Y);
		fade_c.alpha = fade.alpha;
		add(fade_c);
	}
	
	box = new FlxSprite(704, 270).loadGraphic(Paths.image('freeplay/box'));
	box.antialiasing = false;
	box.scale.set(2, 2);
	box.visible = false;
	
	box_bg = new FlxSprite(box.x, box.y).makeGraphic(box.width, box.height, FlxColor.BLACK);
	box_bg.scale.set(box.scale.x - 0.1, box.scale.y - 0.1);
	box_bg.alpha = 0.9;
	box_bg.visible = false;
	
	groupTitle = bitmapText(0, 65, '< Group Title >', FlxTextAlign.CENTER, 'FFFFFF', 0, 3.0, dotumcheFont);
	groupTitle.screenCenter(FlxAxes.X);
	add(groupTitle);
	
	for (i in 0...(2 * 5)) {
		bar = new FlxSprite(565, 155 - 18 + (60 * i)).makeGraphic(515, 2, FlxColor.WHITE);
		bar.alpha = 0.6;
		add(bar);
	}
	
	add(groupTexts);
	add(otherTexts);
	
	updateGroup();
}

function postCreate() {
	add(render);
	add(box_bg);
	add(box);	
	add(boxTexts);
	
	// var border_1 = new FlxSprite().makeGraphic(171, FlxG.height, FlxColor.BLACK);
	// add(border_1);
	
	// var border_2 = new FlxSprite(1109).makeGraphic(171, FlxG.height, FlxColor.BLACK);
	// add(border_2);
}

function update(elapsed) {
	if (controls.ACCEPT || FlxG.keys.justPressed.Z) {
		if (songExists && !subMenu) {
			openMenu(songs[songSelected].song);
		} else if (subMenu) {
			PlayState.loadSong(songs[songSelected].song, 'normal', false, false);
			FlxG.switchState(new PlayState());
		}
		FlxG.sound.play(Paths.sound('select'));
	} else if (controls.BACK || FlxG.keys.justPressed.X || FlxG.keys.justPressed.SHIFT) {
		if (subMenu) {
			box.visible = false;
			box_bg.visible = false;
			boxTexts.clear();
			FlxTween.tween(render, {alpha: 0}, 0.1, {ease: FlxEase.cubeOut});
			FlxTween.tween(render.offset, {x: 500}, 0.1, {ease: FlxEase.cubeOut});
			// boxTexts.kill();
			subMenu = false;
		} else {
			FlxG.switchState(new MainMenuState());
		}
	} else if (controls.LEFT_P) {
		updateGroup(-1);
	} else if (controls.RIGHT_P) { 
		updateGroup(1);
	} else if (controls.UP_P) {
		updateSelection(-1);
	} else if (controls.DOWN_P) {
		updateSelection(1);
	}
	
	if (theme.volume < 0.5) {
		theme.volume += 0.3 * elapsed;
	}
}

/*
	took me a long fucking while to notice why it was screaming at me for some dumbass null error
	turns out i was checking for the length WHILE i added a non song text haha so it would go through it when doing
	the check and since a variant text has no song it didnt exist wow.
*/
function updateGroup(?v:Int) {
	if (subMenu) { return; }
	if (v != null) {
		groupSelected += v;
		if (groupSelected > groups.length - 1) {
			groupSelected = 0;
		} else if (groupSelected < 0) {
			groupSelected = groups.length - 1;
		}
		FlxG.sound.play(Paths.sound('squeak'));
	}
	//Clearing stuff from other group.
	groupTexts.clear();
	otherTexts.clear();
	songs = [];
	songSelected = 0;
	//Creating new group.
	var group = Json.parse(Assets.getText(Paths.json('freeplay_data/weeks/' + groups[groupSelected])));
	for (song in group.songs) {
		if (Assets.exists(Paths.json('freeplay_data/songs/' + song))) {
			var songData = Json.parse(Assets.getText(Paths.json('freeplay_data/songs/' + song)));
			// trace("Added: [" + song + "]");
			songs.push(songData);
		} else {
			trace("Skipped [" + song + "] because it doesn't have a .json!");
		}
		
	}
	groupTitle.text = '< ' + group.display + ' >';
	for (i in 0...songs.length) {
		var name = songs[i].display;
		var text = bitmapText(-840, 155 + (60 * i), name, FlxTextAlign.RIGHT, 'FFFFFF', FlxG.width, 2.0, undertaleFont);
		if (songs[i].varianttag != null) {
			var variant = bitmapText(-844, text.y + 17, songs[i].varianttag, FlxTextAlign.RIGHT, '' + songs[i].variantcolor, FlxG.width, 2.0, wonderFont);
			variant.autoSize = false;
			text.x -= 35 * variant.text.length;
			
			otherTexts.add(variant);
		}
		text.ID = i;
		text.autoSize = false;
		groupTexts.add(text);
	}
	DiscordUtil.changePresence("Scrolling through menus.", "In Freeplay (" + group.display + ")");
	updateSelection();
}

var thisSongExists = false;
function updateSelection(?v:Int) {
	if (subMenu) { return; }
	var data = songs[songSelected];
	songExists = Assets.exists(Paths.chart(data.song, 'normal'));
	if (v != null) {
		songSelected += v;
		boundCheck();
		FlxG.sound.play(Paths.sound('squeak'));
	}
	groupTexts.forEach(function(text:FlxBitmapText) {
		var selected = (text.ID == songSelected);
		// trace(groupTexts.length);
		if (songs[text.ID].song != null) {
			thisSongExists = Assets.exists(Paths.chart(songs[text.ID].song, 'normal'));
		}
		text.color = (selected ? FlxColor.YELLOW : FlxColor.WHITE);
		if (selected) {
			background.loadGraphic(Paths.image('freeplay/bgs/' + songs[text.ID].bg));
			// background.updateHitbox();
			// background.screenCenter(FlxAxes.Y);
			// if (songs[text.ID].renderdata[0].bgoffset != null) {
				// background.offset.x += songs[text.ID].renderdata[0].bgoffset[0];
				// background.offset.y += songs[text.ID].renderdata[0].bgoffset[1];
			// }
		}
		if (!thisSongExists) {
			text.color = FlxColor.GRAY;
			if (selected) {
				songSelected += (v == null ? 1 : v);
				boundCheck();
				updateSelection();
			}
		}
	});	
}

function boundCheck() {
	if (songSelected > groupTexts.length - 1) {
		songSelected = 0;
	} else if (songSelected < 0) {
		songSelected = groupTexts.length - 1;
	}
}

var ranks:Array<Dynamic> = [
	[0, 'F', 0xFFFF4444],
	[0.5, 'E', 0xFFFF8844],
	[0.7, 'D', 0xFFFFAA44],
	[0.8, 'C', 0xFFFFFF44],
	[0.85, 'B', 0xFFAAFF44],
	[0.9, 'A', 0xFF88FF44],
	[0.95, 'S', 0xFF44FFFF],
	[1, 'S++', 0xF44FFFF]
];
function openMenu(song:String) {
	//Get song info.
	var data = songs[songSelected];
	var songData = FunkinSave.getSongHighscore(song, 'normal');
	var info:Array<String> = (songData.date != null ? ['SCORE', 'ACCURACY', 'RANK'] : ['NONE']);
	subMenu = true;
	box.visible = true;
	box_bg.visible = true;
	//Render stuff.
	render.loadGraphic(Paths.image('freeplay/renders/' + data.render));
	render.scale.set(data.renderdata[0].scale[0], data.renderdata[0].scale[1]);
	render.offset.set(300, data.renderdata[0].offset[1]);
	FlxTween.tween(render, {alpha: 1}, 0.1, {ease: FlxEase.cubeOut});
	FlxTween.tween(render.offset, {x: data.renderdata[0].offset[0], y: data.renderdata[0].offset[1]}, 0.1, {ease: FlxEase.cubeOut});
	//Box information.
	var title = bitmapText(box.x - 80, box.y - 118, data.display, FlxTextAlign.LEFT, 'FFFFFF', FlxG.width, 2.0, undertaleFont);
	if (data.varianttag != null) {
		var variant = bitmapText(title.x + 640, title.y + 74, data.variant, FlxTextAlign.LEFT, data.variantcolor, FlxG.width, 2.0, wonderFont);
		variant.autoSize = false;
		boxTexts.add(variant);
	}
	
	var textLength = title.text.length;
	if (textLength > 13) {
		var scaler = (0.11 * (textLength - 13));
		title.scale.set(title.scale.x - scaler, title.scale.y);
	}
	title.updateHitbox();
	title.autoSize = false;
	
	boxTexts.add(title);
	
	if (data.mechanics) {
		info.push('MECHANICS');
	}
	var index = 0;
	for (stat in info) {
		var text = bitmapText(box.x + 560, box.y - 7 + (90 * index), stat + ':', FlxTextAlign.LEFT, 'FFFFFF', FlxG.width, 2.0, undertaleFont);
		text.autoSize = false;
		boxTexts.add(text);
		
		var value = bitmapText(text.x + 640, text.y + 50, 'value', FlxTextAlign.LEFT, 'FFFFFF', FlxG.width, 3.0, cryptFont);
		value.autoSize = false;
		switch(stat) {
			case 'SCORE':
				value.text = songData.score;
			case 'ACCURACY':
				value.text = CoolUtil.quantize(songData.accuracy * 100, 100) + '%';
			case 'RANK':
				if (songData.misses == 0) {
					for (rank in ranks) {
						var percent = rank[0];
						if (percent <= songData.accuracy) {
							value.text = rank[1].toLowerCase();
							value.color = rank[2];
						}
					}
				} else {
					text.text = 'MISSES:';
					value.text = songData.misses;
				}
			case 'MECHANICS':
				text.text = 'MECHANICS';
				value.text = 'press tab to disable';
				if (songData.date == null) {
					text.y += 102;
					value.y += 102;
				}
			case 'NONE':
				text.text = "(You haven't\nplayed this\nsong yet!)";
				text.alpha = 0.5;
				text.y += 32;
				value.visible = false;
		}
		boxTexts.add(value);
		index += 1;
	}
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