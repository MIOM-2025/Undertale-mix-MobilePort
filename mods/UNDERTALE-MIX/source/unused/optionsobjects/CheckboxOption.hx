import UndertaleText;

import funkin.backend.system.Controls;
import funkin.options.PlayerSettings;

class CheckboxOption extends FlxSprite {
	var updateCallback:Void->Void;
	var stateParent:Dynamic;
	var type:String = 'bool';
	var optionText:UndertaleText;
	var selected:Bool = false;
	
	var value(default, set):Bool;
	
	var controls(get, never):Controls;
	function get_controls():Controls {
		return PlayerSettings.solo.controls;
	}
	
	public function new(x:Int, y:Int, text:String, desc:String, parent:Dynamic, ?optionCallback:Void->Void) {
		super(x, y);
		
		frames = Paths.getSparrowAtlas('options/checkbox');
		animation.addByPrefix('unchecked', 'checkbox check0000', 24, false);
		animation.addByPrefix('unchecking', 'checkbox uncheck0000', 14, false);
		animation.addByPrefix('checking', 'checkbox check0', 14, false);
		animation.addByPrefix('checked', 'checkbox check0000', 24, false);
		scale.set(4, 4);
		animation.play('checking', true);
		updateHitbox();
		antialiasing = false;
		// setPosition(text.x - 20, text.y);
		
		optionText = new UndertaleText(x + 100, y + 20, text, 'left', FlxG.width, 4, 'FFFFFF', 'undertale-outline');
		optionText.updateHitbox();
		parent.add(optionText);
		
		value = true;
		animation.play(value ? 'checked' : 'unchecked', true);
	}
	
	override function update(elapsed:Float) {
		if (controls.ACCEPT && selected) {
			value = !value;
		}
		super.update(elapsed);
	}
	
	function set_value(checked:Bool) {
		animation.play(checked ? 'checking' : 'unchecking', true);
		return value = checked;
	}
}