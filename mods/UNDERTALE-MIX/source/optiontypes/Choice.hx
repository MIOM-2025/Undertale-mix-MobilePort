import Reflect;
import UndertaleText;
import funkin.backend.system.Controls;
import funkin.options.PlayerSettings;

class Choice extends FlxSprite {
	var parentObject:Dynamic;
	var saveState:Dynamic;
	var parentValue:String;
	var defaultValue:Dynamic;
	var currentValue:Dynamic;
	var optionChoices:Array<String> = [];
	var index:Int = 0;
	var textDisplay:UndertaleText;
	
	var controls(get, never):Controls;
	function get_controls():Controls {
		return PlayerSettings.solo.controls;
	}
	
	public function new(x:Int, y:Int, state:Dynamic, parent:Dynamic, pv:String, dv:Dynamic, choices:Array<String>, ?saveParent:Dynamic) {
		super(x, y);
		
		textDisplay = new UndertaleText(0, 0, '', 'left', FlxG.width, parent.scale.x, 'FFFFFF', 'undertale-outline');
		textDisplay.autoSize = true;
		textDisplay.cameras = parent.cameras;
		state.add(textDisplay);
		
		optionChoices = choices;
		parentObject = parent;
		if (saveParent != null) {
			saveState = saveParent;
		} else {
			saveState = FlxG.save.data;
		}
		parentValue = pv;
		defaultValue = dv;
		
		currentValue = Reflect.field(saveState, parentValue);
		if (currentValue == null) {
			Reflect.setField(saveState, parentValue, choices[dv]);
			currentValue = Reflect.field(saveState, parentValue);
		}
		
		textDisplay.text = '< ' + currentValue.toUpperCase() + ' >';
		textDisplay.updateHitbox();
	}
	
	override function update(elapsed:Float) {
		textDisplay.setPosition(parentObject.x + (parentObject.width + 4), parentObject.y - 1);
		
		// ---------- 键盘控制：改为松开触发 ----------
		if (controls.LEFT_R) {
			updateSelection(-1);
		} else if (controls.RIGHT_R) {
			updateSelection(1);
		}
		
		// ---------- 鼠标点击：改为松开触发 ----------
		if (parentObject.color == FlxColor.YELLOW && FlxG.mouse.justReleased) {
			var mainCamera = (textDisplay.cameras != null && textDisplay.cameras.length > 0) 
				? textDisplay.cameras[0] 
				: FlxG.camera;
			var mousePos = FlxG.mouse.getWorldPosition(mainCamera);
			
			// 点击选项名称（parentObject）或选项值（textDisplay）均可切换
			var hitName:Bool = parentObject.overlapsPoint(mousePos, false, mainCamera);
			var hitValue:Bool = textDisplay.overlapsPoint(mousePos, false, mainCamera);
			
			if (hitName || hitValue) {
				updateSelection(1);
			}
		}
	}
	
	// 切换选项，统一在此播放音效（松开时触发）
	function updateSelection(?v:Int) {
		if (parentObject.color == FlxColor.WHITE) {
			return;
		}
		if (v != null) {
			index += v;
			if (index > optionChoices.length - 1) {
				index = 0;
			} else if (index < 0) {
				index = optionChoices.length - 1;
			}
		}
		currentValue = optionChoices[index];
		Reflect.setField(saveState, parentValue, currentValue);
		FlxG.save.flush();
		textDisplay.text = '< ' + currentValue.toUpperCase() + ' >';
		
		// 播放与子菜单确认一致的音效（松开时触发）
		FlxG.sound.play(Paths.sound('select'), Options.volumeSFX);
	}
}