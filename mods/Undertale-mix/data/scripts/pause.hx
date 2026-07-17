import flixel.graphics.frames.FlxBitmapFont;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxStringUtil;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxBitmapText;
import funkin.options.TreeMenu;
import funkin.menus.StoryMenuState;
import funkin.options.OptionsMenu;
import StringTools;

var options:Array<String> = ['resume', 'restart', 'settings', 'exit'];
var objects:FlxTypedSpriteGroup<FlxSprite> = new FlxTypedSpriteGroup();

var selected:Int = 0;
var theme:FlxSound = FlxG.sound.load(Paths.music('pausetheme'), 0, true);

var pauseCam = new FlxCamera();
var exiting:Bool = false;

function create(event) {
	event.cancel();
	//Can't find a better way to make it shut the fuck up.
	event.music = 's';
	theme.play();
	theme.pitch = 0.9;
	
	FlxG.cameras.add(pauseCam, false);
	cameras = [pauseCam];
	
	pauseCam.bgColor = 0x7F000000;
	pauseCam.zoom = 1.5;
	pauseCam.alpha = 0;
	pauseCam.pixelPerfectRender = true;
	FlxTween.tween(pauseCam, {alpha: 1, zoom: 2}, 0.5, {ease: FlxEase.cubeOut});
	
	var backdrop = new FlxBackdrop(Paths.image('pause/bg'));
	backdrop.antialiasing = false;
	backdrop.velocity.set(20, 20);
	add(backdrop);
	
	var dither = new FlxSprite().loadGraphic(Paths.image('pause/dither'));
	dither.antialiasing = false;
	// add(dither);
	
	var songTitleBack = new FlxText(0, 0, FlxG.width, PlayState.SONG.meta.displayName.toLowerCase());
	songTitleBack.setFormat(Paths.font('title_B.ttf'), 48, FlxColor.GRAY, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE);
	songTitleBack.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
	add(songTitleBack);
	
	var songTitle = new FlxText(0, 0, FlxG.width, PlayState.SONG.meta.displayName.toLowerCase());
	songTitle.setFormat(Paths.font('title_F.ttf'), 48, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.NONE);
	add(songTitle);
	
	var cryptLetters:String = "abcdefgh" + "ijklmnop" + "qrstuvwx" + "yz123456" + "789.,:;'" + '"()!?+-/' + "=0% ";
	var songTime = bitmapText(0, 0, '(' + getTime() + ' - 0' + FlxStringUtil.formatTime(Math.floor(PlayState.instance.inst.length / 1000)) + ')', FlxTextAlign.CENTER, 'FFFFFF', FlxG.width, 1.5, getFont('cryptoftomorrow', cryptLetters));
	songTime.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1, 1);
	songTime.autoSize = false;
	add(songTime);
	
	add(objects);
	var index:Int = 0;
	for (option in options) {
		icon = new FlxSprite().loadGraphic(Paths.image('pause/' + option));
		icon.screenCenter();
		icon.antialiasing = false;
		//Positioning.
		if (objects.length > 0) {
			icon.x += (50 * index);
		}
		icon.ID = index;
		objects.add(icon);
		index++;
	}
	//God forbid you can easily center a group.
	objects.screenCenter();
	pauseCam.scroll.set((objects.x + objects.width) - 25, objects.y);
	objects.y += 94;
	objects.offset.set(-100, -20);
	
	dither.setPosition((objects.x + objects.width) + 215, objects.y + 260);
	songTitle.setPosition(objects.x + 176, objects.y + 150);
	songTitleBack.setPosition(songTitle.x, songTitle.y);
	songTime.setPosition(songTitle.x, songTitle.y + 42);
	
	updateSelection();
}

function update(elapsed) {
	if (controls.ACCEPT && !exiting) {
		var option = options[selected];
		exiting = true;
		FlxG.sound.play(Paths.sound('select'));
		if (option == 'resume') {
			theme.fadeOut(0.5, 0);
			FlxTween.tween(pauseCam, {alpha: 0, zoom: 1.5}, 0.5, {ease: FlxEase.cubeOut, onComplete: function(tween:FlxTween) {
				close();
			}});
		} else if (option == 'restart') {
			parentDisabler.reset();
			PlayState.instance.registerSmoothTransition();
			FlxG.resetState();
		} else if (option == 'settings') {
			TreeMenu.lastState = PlayState;
			FlxG.switchState(new OptionsMenu());
		} else if (option == 'exit') {
			PlayState.instance.strumLines.forEachAlive(function(grp) grp.notes.__forcedSongPos = Conductor.songPosition);
			CoolUtil.playMenuSong();
			FlxG.switchState(PlayState.isStoryMode ? new StoryMenuState() : new FreeplayState());
		}
	} else if (controls.LEFT_P) {
		updateSelection(-1);
	} else if (controls.RIGHT_P) {
		updateSelection(1);
	}
	
	if (theme.volume < 0.5 && !exiting) {
		theme.volume += 0.3 * elapsed;
	}
}

function updateSelection(?v:Int) {
	if (exiting) { return; }
	if (v != null) {
		selected += v;
		if (selected > objects.length - 1) {
			selected = 0;
		} else if (selected < 0) {
			selected = objects.length - 1;
		}
		FlxG.sound.play(Paths.sound('squeak'));
	}
	objects.forEach(function(option:FlxSprite) {
		var hovering = option.ID == selected;
		var scale = (hovering ? 1 : 0.7);
		option.color = (hovering ? FlxColor.YELLOW : FlxColor.WHITE);
		FlxTween.tween(option.scale, {x: scale, y: scale}, 0.1, {ease: FlxEase.quartOut});
	});
}

function bitmapText(x:Int, y:Int, text:String, alignment:FlxTextAlign, color:String, width:Int, scale:Float, font:FlxBitmapFont) {
	var text = new FlxBitmapText(x, y, text, font);
	text.alignment = alignment;
	text.fieldWidth = width;
	text.color = FlxColor.fromString('0xFF' + color);
	text.scale.set(scale, scale);
	text.font = font;
	return text;
}

function getFont(image:String, letters:String) {
	return FlxBitmapFont.fromXNA(Assets.getBitmapData(Paths.image('fonts/' + image), true, false), letters);
}

function getTime() {
	if (Conductor.songPosition > 0) {
		var currentTime:Float = Math.max(0, Conductor.songPosition);
		var time:Int = Math.floor(currentTime / 1000);
		return CoolUtil.addZeros(FlxStringUtil.formatTime(time), 5);
	} else {
		return '00:00';
	}
}