import Reflect;
import UndertaleText;
import flixel.input.keyboard.FlxKey;
import funkin.backend.system.Controls;
import funkin.options.PlayerSettings;

class KeyOption extends FlxSprite {
	var player2:Bool = false;
	var parentObject:Dynamic;
	var saveState:Dynamic;
	var currentValue:Dynamic;
	var parentValue:Dynamic;
	var defaultValue:Array<FlxKey>;
	var playerSuffix:String = 'P1_';
	var keyText:UndertaleText;
	var usesIcon:Bool = true;
	var keyIcon:FlxSprite = new FlxSprite();
	var keyObject:Dynamic;
	var selected:Bool = false;
	var objectState:Dynamic;
	var keyName:String = '';
	var belongsTo:String = '';
	
	var controls(get, never):Controls;
	function get_controls():Controls {
		return PlayerSettings.solo.controls;
	}
	
	override function new(x:Int, y:Int, state:Dynamic, parent:Dynamic, p2:Bool, pv:Dynamic, dv:Dynamic, saveParent:Dynamic) {
		super(x, y);
		keyText = new UndertaleText(0, 0, '', 'left', FlxG.width, parent.scale.x, 'FFFFFF', 'undertale-outline');
		keyText.autoSize = true;
		
		parentObject = parent;
		player2 = p2;
		objectState = state;
		if (saveParent != null) {
			saveState = saveParent;
		} else {
			saveState = FlxG.save.data;
		}
		playerSuffix = (player2 ? 'P2_' : 'P1_');
		parentValue = playerSuffix + pv;
		defaultValue = dv;
		// trace(defaultValue);
		
		currentValue = Reflect.field(saveState, parentValue);
		// trace(Reflect.field(saveState, parentValue));
		if (currentValue == null) {
			trace(defaultValue + ' dont exist!');
			if (player2) {
				Reflect.setField(saveState, parentValue, [FlxKey.NONE]);
				currentValue = Reflect.field(saveState, parentValue);
				updateKey(Reflect.field(saveState, parentValue)[0]);
			} else {
				Reflect.setField(saveState, parentValue, defaultValue);
				currentValue = Reflect.field(saveState, parentValue);
				updateKey(Reflect.field(saveState, parentValue)[0]);
			}
		} else {
			updateKey(currentValue[0]);
		}
		
		
		
		keyObject.cameras = parentObject.cameras;
		// keyText.text = CoolUtil.keyToString(currentValue[0]);
		state.add(keyObject);
	}
	
	var skipFrame:Bool = false;
	override function update(elapsed:Float) {
		keyObject.setPosition(parentObject.x + (player2 ? 200 : 130), (usesIcon ? parentObject.y + 3 : parentObject.y));
		if (!skipFrame) {
			skipFrame = true;
			return;
		}
		if (selected) {
			if (controls.ACCEPT) {
				trace('hi im ' + CoolUtil.keyToString(currentValue[0]));
			}
		}
	}
	
	function rebindKey(newKey:FlxKey) {
		Reflect.setField(saveState, parentValue, [newKey]);
		currentValue = Reflect.field(saveState, parentValue);
		Options.applyKeybinds();
		updateKey(currentValue[0]);
	}
	
	function updateKey(newKey:Dynamic) {
		objectState.remove(keyObject);
		
		keyObject = keyIcon;
		var key:String = CoolUtil.keyToString(newKey);
		switch(key) {
			case '←':
				// trace('hi');
				keyIcon.loadGraphic(Paths.image('options/keys/left'));
			case '↓':
				keyIcon.loadGraphic(Paths.image('options/keys/down'));
			case '↑':
				keyIcon.loadGraphic(Paths.image('options/keys/up'));
			case '→':
				keyIcon.loadGraphic(Paths.image('options/keys/right'));
			case '[←]':
				keyIcon.loadGraphic(Paths.image('options/keys/backspace'));
			default:
				keyText.text = key;
				keyObject = keyText;
				usesIcon = false;
		}
		keyObject.cameras = parentObject.cameras;
		objectState.add(keyObject);
	}
}