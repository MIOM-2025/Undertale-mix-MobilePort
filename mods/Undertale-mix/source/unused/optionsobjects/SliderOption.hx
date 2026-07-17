import UndertaleText;
import Math;
import flixel.math.FlxMath;

import funkin.backend.system.Controls;
import funkin.options.PlayerSettings;

class SliderOption extends FlxSprite {
	var updateCallback:Void->Void;
	var stateParent:Dynamic;
	var type:String = 'slider';
	var optionText:UndertaleText;
	
	var value:Int = 0;
	var minValue:Int = 0;
	var maxValue:Int = 100;
	var percentage:Bool = false;
	
	var sliderBar:FlxSprite;
	var slideCounter:UndertaleText;
	var selected:Bool = false;
	// var selected:Bool = false;
	
	var controls(get, never):Controls;
	function get_controls():Controls {
		return PlayerSettings.solo.controls;
	}
	
	public function new(x:Int, y:Int, text:String, desc:String, parent:Dynamic, ?optionCallback:Void->Void) {
		super(x, y);	
		optionText = new UndertaleText(x, y, text, 'left', FlxG.width, 4, 'FFFFFF', 'undertale-outline');
		optionText.updateHitbox();
		parent.add(optionText);
		
		sliderBar = new FlxSprite().loadGraphic(Paths.image('options/greenbar'));
		sliderBar.antialiasing = false;
		sliderBar.scale.set(4, 4);
		sliderBar.updateHitbox();
		sliderBar.alpha = 0.5;
		sliderBar.setPosition(optionText.x + (34 * optionText.text.length), optionText.y - 10);
		parent.add(sliderBar);

		loadGraphic(Paths.image('options/gaylittlebar'));
		scale.set(4, 4);
		offset.x = -1;
		alpha = 0.5;
		this.y = sliderBar.y + 36;
		
		slideCounter = new UndertaleText(sliderBar.x + 262, sliderBar.y + 44, '0', 'left', FlxG.width, 4, 'FFFFFF', 'crypt');
		slideCounter.updateHitbox();
		parent.add(slideCounter);
		
		value = maxValue / 2;
		updateValue();
	}
	
	var hold:Float = 0;
	override function update(elapsed:Float) {
		if (selected) {
			if (controls.RIGHT_P) {
				value = Math.max(minValue, Math.min(value + 1, maxValue));
				updateValue();
			} else if (controls.LEFT_P) {
				value = Math.max(minValue, Math.min(value - 1, maxValue));
				updateValue();
			}
		
			var direction:Int = 1;
			if (controls.LEFT || controls.RIGHT) {
				// trace('hahh');
				hold += elapsed;
				if (controls.LEFT) {
					direction = -1;
				}
			}
			if (controls.LEFT_R || controls.RIGHT_R) {
				hold = 0;
			}
			if (hold >= 0.5) {
				value += 1 * direction;
				value = Math.max(minValue, Math.min(value, maxValue));
				updateValue();
			}
		}
		super.update(elapsed);
	}
	
	function updateValue() {
		this.x = sliderBar.x + FlxMath.remapToRange(value, minValue, maxValue, 0, 248);
		if (percentage) {
			slideCounter.text = value + '%';
		} else {
			slideCounter.text = value;
		}
		// trace(value);
	}
}