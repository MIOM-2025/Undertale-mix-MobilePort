import Reflect;
import funkin.backend.system.Controls;
import funkin.options.PlayerSettings;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

class Checkbox extends FlxSprite {
	var parentObject:Dynamic;
	var saveState:Dynamic;
	var checked(default, set):Bool;
	var parentValue:String;
	var defaultValue:Dynamic;
	var currentValue:Dynamic;

	var controls(get, never):Controls;
	function get_controls():Controls {
		return PlayerSettings.solo.controls;
	}
	
	public function new(x:Int, y:Int, parent:Dynamic, pv:String, dv:Dynamic, ?saveParent:Dynamic) {
		super(x, y);
		
		frames = Paths.getSparrowAtlas('options/checkbox');
		animation.addByPrefix('unchecked', 'checkbox check0000', 24, false);
		animation.addByPrefix('unchecking', 'checkbox uncheck0000', 24, false);
		animation.addByPrefix('checking', 'checkbox check0', 24, false);
		animation.addByPrefix('checked', 'checkbox check0000', 24, false);
		
		parentObject = parent;
		if (saveParent != null) {
			saveState = saveParent;
		} else {
			saveState = FlxG.save.data;
		}
		parentValue = pv;
		defaultValue = dv;
		
		// 读取保存值，若不存在则写入默认值
		currentValue = Reflect.field(saveState, parentValue);
		if (currentValue == null) {
			// 先确保 currentValue 是默认值（布尔类型）
			currentValue = defaultValue;
			Reflect.setField(saveState, parentValue, defaultValue);
		}
		// 现在 currentValue 不会是 null，可以安全赋给 checked
		checked = currentValue;
		animation.play((!checked ? 'checking' : 'unchecking'), true);
		offset.x = 11;
		
		antialiasing = false;
	}
	
	override function update(elapsed:Float) {
		setPosition(parentObject.x - 13, parentObject.y - 6);
		
		// 键盘回车切换（按下触发）
		if (controls.ACCEPT && parentObject.color == FlxColor.YELLOW) {
			toggle();
		}
		
		// 鼠标点击切换（松开触发）
		if (parentObject.color == FlxColor.YELLOW && FlxG.mouse.justReleased) {
			var mainCamera = (cameras != null && cameras.length > 0) ? cameras[0] : FlxG.camera;
			var mousePos = FlxG.mouse.getWorldPosition(mainCamera);
			if (this.overlapsPoint(mousePos, false, mainCamera)) {
				toggle();
			}
		}
	}
	
	/**
	 * 公开的切换方法，供外部调用（例如键盘或其它UI）
	 * 切换状态、保存并播放音效
	 */
	public function toggle():Void {
		checked = !checked;
		Reflect.setField(saveState, parentValue, checked);
		FlxG.save.flush();
		FlxG.sound.play(Paths.sound('select'), Options.volumeSFX);
	}
	
	function set_checked(c:Bool) {
		animation.play((!c ? 'checking' : 'unchecking'), true);
		return checked = c;
	}
}