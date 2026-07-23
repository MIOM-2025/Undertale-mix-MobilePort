import UndertaleText;
import TypedBitmapText;
import optiontypes.KeyOption;
import flixel.FlxObject;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;

var stateCamera:FlxCamera = new FlxCamera();

//Visuals.
var bg:FlxBackdrop;
//Other.
var bgAlpha:Float = 1;
var camFollow:FlxObject = new FlxObject();
//Data.
var texts:Array<UndertaleText> = [];
var keySelected:Int = 0;
var selectableKeys:Array<UndertaleText> = [];
var p2Selected:Int = 0;
var keyOptions:Array<KeyOption> = [];
var categories:Array<Dynamic> = [
	{
		name: 'Notes',
		keys: [
			{
				name: 'left',
				control: 'NOTE_LEFT',
				defaultKey: [FlxKey.A],
				saveTo: Options,
			},
			{
				name: 'down',
				control: 'NOTE_DOWN',
				defaultKey: [FlxKey.S],
				saveTo: Options
			},
			{
				name: 'up',
				control: 'NOTE_UP',
				defaultKey: [FlxKey.W],
				saveTo: Options
			},
			{
				name: 'right',
				control: 'NOTE_RIGHT',
				defaultKey: [FlxKey.D],
				saveTo: Options
			}
		]
	},
	{
		name: 'UI',
		keys: [
			{
				name: 'left',
				control: 'LEFT',
				defaultKey: [FlxKey.A],
				saveTo: Options
			},
			{
				name: 'down',
				control: 'DOWN',
				defaultKey: [FlxKey.S],
				saveTo: Options
			},
			{
				name: 'up',
				control: 'UP',
				defaultKey: [FlxKey.W],
				saveTo: Options
			},
			{
				name: 'right',
				control: 'RIGHT',
				defaultKey: [FlxKey.D],
				saveTo: Options
			},
			{
				name: 'accept',
				control: 'ACCEPT',
				defaultKey: [FlxKey.ENTER],
				saveTo: Options
			},
			{
				name: 'back',
				control: 'BACK',
				defaultKey: [FlxKey.BACKSPACE],
				saveTo: Options
			},
			{
				name: 'reset',
				control: 'RESET',
				defaultKey: [FlxKey.R],
				saveTo: Options
			},
			{
				name: 'pause',
				control: 'PAUSE',
				defaultKey: [FlxKey.ENTER],
				saveTo: Options
			},
			{
				name: 'change mode',
				control: 'CHANGE_MODE',
				defaultKey: [FlxKey.TAB],
				saveTo: Options
			},
		]
	},
	{
		name: 'Volume',
		keys: [
			{
				name: 'up',
				control: 'VOLUME_UP',
				defaultKey: [FlxKey.PLUS],
				saveTo: Options
			},
			{
				name: 'down',
				control: 'VOLUME_DOWN',
				defaultKey: [FlxKey.MINUS],
				saveTo: Options
			},
			{
				name: 'mute',
				control: 'VOLUME_MUTE',
				defaultKey: [FlxKey.ZERO],
				saveTo: Options
			}
		]
	},
	{
		name: 'Engine',
		keys: [
			{
				name: 'switch mod',
				control: 'SWITCHMOD',
				defaultKey: [FlxKey.TAB],
				saveTo: Options
			},
			// {
				// name: 'fps counter',
				// control: 'FPS_COUNTER',
				// defaultKey: [FlxKey.F3],
				// saveTo: Options
			// }
		]
	},
	{
		name: 'Mod Specific',
		keys: [
			{
				name: 'SWITCH',
				control: 'MECH_SWITCH',
				defaultKey: [FlxKey.SPACE],
				// saveTo: Options,
			}
		]
	}
];
function create() {
	FlxG.cameras.add(stateCamera, false);
	stateCamera.bgColor = FlxColor.TRANSPARENT;
	this.cameras = [stateCamera];
	stateCamera.follow(camFollow);
	stateCamera.followLerp = 0.4;
	stateCamera.zoom = 4;
	
	camFollow.screenCenter();
	add(camFollow);
	
	var v:Int = 5;
	var tile:FlxSprite = FlxGridOverlay.create(15, 15, 30, 30, true, 0xFF4B3F61, 0xFF833DFF);
	bg = new FlxBackdrop(tile.pixels, FlxAxes.XY);
	// bg.setPosition(data[0].originalBg.x - 10, data[0].originalBg.y);
	bg.alpha = bgAlpha;
	bg.velocity.set(v, v);
	// bg.cameras = [FlxG.camera];
	add(bg);
	
	if (Options.devMode) {
		categories.push({
			name: 'Developer',
			keys: [
				{
					name: 'Developer Menus',
					control: 'DEV_ACCESS',
					defaultKey: [FlxKey.SEVEN],
					saveTo: Options
				},
				{
					name: 'Open Console',
					control: 'DEV_CONSOLE',
					defaultKey: [FlxKey.F2],
					saveTo: Options
				},
				{
					name: 'Reload State',
					control: 'DEV_RELOAD',
					defaultKey: [FlxKey.F5],
					saveTo: Options
				}
			]
		});
	}
	
	var index:Int = 0;
	var keyIndex:Int = 0;
	for (category in categories) {	
		var title:UndertaleText = new UndertaleText(0, 0, category.name.toUpperCase(), 'left', FlxG.width, 1, 'FFFFFF', 'undertale-outline');
		title.autoSize = true;
		title.updateHitbox();
		title.screenCenter();
		if (texts.length > 0) {
			title.y = texts[index - 1].y + (texts[index - 1].height / 1.5);
		}
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, title.height / 1.6, FlxColor.BLACK);
		bg.y = title.y + 3;
		bg.alpha = 0.9;
		add(bg);
		
		//Add into texts array.
		texts.push(title);
		index++;
		
		add(title);
		
		for (key in category.keys) {
			var keyTitle:UndertaleText = new UndertaleText(0, 0, key.name.toUpperCase(), 'left', FlxG.width, 1, 'FFFFFF', 'undertale-outline');
			keyTitle.autoSize = true;
			keyTitle.updateHitbox();
			keyTitle.cameras = [stateCamera];
			keyTitle.setPosition(497, (texts.length > 0 ? texts[index - 1].y + (texts[index - 1].height / 1.5) : 0));
			keyTitle.ID = keyIndex;
			
			var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, title.height / 1.7, FlxColor.BLACK);
			bg.y = keyTitle.y + 3;
			bg.alpha = 0.5;
			add(bg);
			
			var keyOptionP1:KeyOption = new KeyOption(0, 0, this, keyTitle, false, key.control, key.defaultKey, (key.saveTo != null ? key.saveTo : null));
			keyOptionP1.keyName = key.name;
			keyOptionP1.belongsTo = category.name;
			keyOptionP1.cameras = [stateCamera];
			
			var keyOptionP2:KeyOption = new KeyOption(0, 0, this, keyTitle, true, key.control, key.defaultKey, (key.saveTo != null ? key.saveTo : null));
			keyOptionP2.keyName = key.name;
			keyOptionP2.belongsTo = category.name;
			keyOptionP2.cameras = [stateCamera];

			add(keyOptionP1);
			add(keyOptionP2);
			keyOptions.push([keyOptionP1, keyOptionP2]);
			
			add(keyTitle);
			//Add into keys array.
			selectableKeys.push(keyTitle);
			keyIndex++;
			
			//Add into texts array.
			texts.push(keyTitle);
			index++;
		}
	}
	
	stateCamera.setScrollBoundsRect(0, 340, 1600, 14.8 * texts.length - 1);
	updateSelection();
	
	enterTransition(true);
}

var exiting:Bool = false;
var rebinding:Bool = false;
var skipFrame:Bool = false;
function update(elapsed:Float) {
	// if (rebinding) {
		
		// return;
	// }
	if (this.substate != null) {
		return;
	}
	if (!skipFrame) {
		skipFrame = true;
		return;
	}
	if (FlxG.mouse.wheel != 0) {
		updateSelection(-FlxG.mouse.wheel);
	}
	if (controls.ACCEPT) {
		FlxG.sound.play(Paths.sound('select'), Options.volumeSFX);
		// if (!rebinding) {
			// rebinding = true;
		// }
		// if (!skipFrame) {
			openSubState(new ModSubState('KeyReBind', keyOptions[keySelected][(p2Selected ? 1 : 0)]));
			// skipFrame = true;
		// }
	} else if (controls.UP_P) {
		updateSelection(-1);
	} else if (controls.DOWN_P) {
		updateSelection(1);
	} else if (controls.LEFT_P) {
		p2Selected = false;
		updateSelection();
	} else if (controls.RIGHT_P) {
		p2Selected = true;
		updateSelection();
	}

	
	if (controls.BACK) {
		if (!exiting) {
			enterTransition(false);
			exiting = true;
		}
	}
}

//its not good for this to update so many damn things at once right
//too bad!
function updateSelection(?v:Int) {
	if (v != null) {
		keySelected += v;
		FlxG.sound.play(Paths.sound('squeak'), Options.volumeSFX);
		if (keySelected > selectableKeys.length - 1) {
			keySelected = 0;
		} else if (keySelected < 0) {
			keySelected = selectableKeys.length - 1;
		}
	}
	for (key in selectableKeys) {
		key.color = FlxColor.WHITE;
		keyOptions[key.ID][0].keyObject.color = FlxColor.WHITE;
		keyOptions[key.ID][0].selected = false;
		keyOptions[key.ID][1].keyObject.color = FlxColor.WHITE;
		keyOptions[key.ID][1].selected = false;
		if (key.ID == keySelected) {
			key.color = FlxColor.YELLOW;
			keyOptions[key.ID][(p2Selected ? 1 : 0)].keyObject.color = FlxColor.YELLOW;
			keyOptions[key.ID][(p2Selected ? 1 : 0)].selected = true;
			camFollow.y = key.y + key.height / 2;
		}
	}
	// for (key in keyOptions) {
		
	// }
}

var time:Int = 0.1;
function enterTransition(e:Bool) {
	//Entering state.
	if (e) {
		bg.alpha = 0;
		FlxTween.tween(bg, {alpha: bgAlpha}, time, {ease: FlxEase.cubeIn});
		
		stateCamera.alpha = 0;
		// stateCamera.y += 500;
		FlxTween.tween(stateCamera, {alpha: 1}, time, {ease: FlxEase.cubeInOut, onComplete: function() {
		}});
	} else {
		// boxCamera.visible = false;
		FlxTween.tween(bg, {alpha: 0}, time, {ease: FlxEase.cubeIn, onComplete: function() {
			FlxTween.tween(stateCamera, {alpha: 0}, time, {ease: FlxEase.cubeInOut, onComplete: function() {
				close();
			}});
		}});
	//Exiting state.
	}
}