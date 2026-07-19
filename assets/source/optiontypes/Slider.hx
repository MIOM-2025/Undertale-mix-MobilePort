import UndertaleText;
import Reflect;
import funkin.backend.system.Controls;
import funkin.options.PlayerSettings;

class Slider extends FlxSprite {
	var parentObject:Dynamic;
	var saveState:Dynamic;
	var parentValue:String;
	var defaultValue:Dynamic;
	var currentValue:Float = 0;
	var savedValue:Dynamic;
	var valueSuffix:String = '';

	var stepper:Float = 1;
	var maxValue:Int = 100;
	var minValue:Int = 0;
	var percentageDisplay:Bool = false;
	var lastValue:Float = 0;
	var quantValue:Int = 10;
	
	var sliderBar:FlxSprite = new FlxSprite().loadGraphic(Paths.image('options/greenbar'));
	var valueCounter:UndertaleText = new UndertaleText(0, 0, '0', 'left', FlxG.width, 1, 'FFFFFF', 'crypt');
	var leftArrow:UndertaleText;
	var rightArrow:UndertaleText;

	// 鼠标交互变量
	var isDragging:Bool = false;
	var mainCamera:FlxCamera;

	var controls(get, never):Controls;
	function get_controls():Controls {
		return PlayerSettings.solo.controls;
	}
	
	public function new(x:Int, y:Int, state:Dynamic, parent:Dynamic, pv:String, dv:String, min:Int, max:Int, ?percent:Bool, ?saveParent:Dynamic, ?step:Float, ?suffix:String) {
		super(x, y);
		
		parentObject = parent;
		if (saveParent != null) {
			saveState = saveParent;
		} else {
			saveState = FlxG.save.data;
		}
		parentValue = pv;
		defaultValue = dv;
		maxValue = max;
		minValue = min;
		if (percent != null) {
			percentageDisplay = percent;
		}
		if (step != null) {
			stepper = step;
		}
		if (suffix != null) {
			valueSuffix = suffix;
		}
		trace(stepper);
		savedValue = Reflect.field(saveState, parentValue);
		if (savedValue == null) {
			Reflect.setField(saveState, parentValue, defaultValue);
		}
		currentValue = Reflect.field(saveState, parentValue);
		
		sliderBar.antialiasing = false;
		sliderBar.alpha = 0.5;
		sliderBar.cameras = parentObject.cameras;
		state.add(sliderBar);
		
		valueCounter.autoSize = true;
		valueCounter.cameras = parentObject.cameras;
		state.add(valueCounter);
		
		// 创建左右箭头（使用 "<" 和 ">"）
		leftArrow = new UndertaleText(0, 0, "<", 'left', FlxG.width, 1, 'FFFFFF', 'undertale-outline');
		leftArrow.autoSize = true;
		leftArrow.antialiasing = false;
		leftArrow.cameras = parentObject.cameras;
		state.add(leftArrow);
		
		rightArrow = new UndertaleText(0, 0, ">", 'left', FlxG.width, 1, 'FFFFFF', 'undertale-outline');
		rightArrow.autoSize = true;
		rightArrow.antialiasing = false;
		rightArrow.cameras = parentObject.cameras;
		state.add(rightArrow);
		
		loadGraphic(Paths.image('options/gaylittlebar'));
		alpha = 0.5;
		
		lastValue = currentValue;
		if (percentageDisplay) {
			valueCounter.text = CoolUtil.quantize(((currentValue / maxValue) * 100), 10) + '%';
		} else {
			valueCounter.text = CoolUtil.quantize(currentValue, 100) + valueSuffix;
		}

		// 保存主相机引用（用于鼠标坐标转换）
		if (parentObject.cameras != null && parentObject.cameras.length > 0) {
			mainCamera = parentObject.cameras[0];
		} else {
			mainCamera = FlxG.camera;
		}
	}
	
	var hold:Float = 0;
	var skipFrame:Bool = false;
	var valueNoise:FlxSound = FlxG.sound.load(Paths.sound('snd_noise'), Options.volumeSFX);
	
	override function update(elapsed:Float) {
		// 判断是否选中
		var isActive:Bool = (parentObject.color == FlxColor.YELLOW);
		// 未选中时整体下移1像素
		var yOffset:Float = isActive ? 0 : 1;
		
		// 计算各元素位置
		var arrowSpacing:Float = 1;
		
		// 左箭头：左边缘 = parentObject右边缘 + 1px
		var leftArrowX:Float = parentObject.x + parentObject.width + 1;
		
		// 滑块条：左箭头右侧 + 1px，左移4像素，再右移3像素（净左移1）
		sliderBar.x = leftArrowX + leftArrow.width + arrowSpacing;
		sliderBar.y = parentObject.y - 4 + yOffset;
		
		// 滑块（小方块）位置：跟随滑块条
		setPosition(
			sliderBar.x + FlxMath.remapToRange(currentValue, minValue, maxValue, 0, sliderBar.width - 1),
			sliderBar.y + 5
		);
		
		// 垂直居中于选项名称，动态偏移（选中/未选中）
		var baseArrowY:Float = parentObject.y + (parentObject.height - leftArrow.height) / 2 - 1;
		var arrowY:Float = baseArrowY + (isActive ? 0 : 1);
		
		leftArrow.setPosition(leftArrowX, arrowY);
		
		// 右箭头：滑块条右侧 + 1px，再向右移6像素
		rightArrow.setPosition(
			sliderBar.x + sliderBar.width + arrowSpacing + 4,
			arrowY
		);
		
		// 数值显示：移动到滑块条正中央，水平居中，垂直居中，不透明（修改：alpha = 1.0）
		valueCounter.setPosition(
			sliderBar.x + (sliderBar.width - valueCounter.width) / 2,
			sliderBar.y + (sliderBar.height - valueCounter.height) / 2
		);
		valueCounter.alpha = 1.0;   // 原来是 0.5，现在改为 1.0
		
		// 箭头透明度
		leftArrow.alpha = isActive ? 1.0 : 0.3;
		rightArrow.alpha = isActive ? 1.0 : 0.3;
		
		// 数值变化时保存并更新显示
		if (lastValue != currentValue) {
			if (percentageDisplay) {
				valueCounter.text = CoolUtil.quantize(((currentValue / maxValue) * 100), 10) + '%';
			} else {
				valueCounter.text = CoolUtil.quantize(currentValue, 100) + valueSuffix;
			}
			// 重新居中文字
			valueCounter.updateHitbox();
			valueCounter.x = sliderBar.x + (sliderBar.width - valueCounter.width) / 2;
			Reflect.setField(saveState, parentValue, currentValue);
			FlxG.save.flush();
			lastValue = currentValue;
			valueNoise.play();
		}
		
		// 鼠标交互（仅在选项被选中时响应）
		if (isActive) {
			var mousePos = FlxG.mouse.getWorldPosition(mainCamera);
			
			if (FlxG.mouse.justReleased) {
				if (leftArrow.overlapsPoint(mousePos, false, mainCamera)) {
					currentValue = Math.max(minValue, currentValue - stepper);
				} else if (rightArrow.overlapsPoint(mousePos, false, mainCamera)) {
					currentValue = Math.min(maxValue, currentValue + stepper);
				}
			}
			
			if (FlxG.mouse.justPressed) {
				if (sliderBar.overlapsPoint(mousePos, false, mainCamera) || this.overlapsPoint(mousePos, false, mainCamera)) {
					isDragging = true;
					updateValueFromMouse(mousePos);
				}
			}
			
			if (isDragging && FlxG.mouse.pressed) {
				updateValueFromMouse(mousePos);
			}
			
			if (FlxG.mouse.justReleased) {
				isDragging = false;
			}
			
			// 键盘控制
			if (controls.RIGHT_P) {
				currentValue = Math.max(minValue, Math.min(currentValue + stepper, maxValue));
			} else if (controls.LEFT_P) {
				currentValue = Math.max(minValue, Math.min(currentValue - stepper, maxValue));
			}
			
			if (controls.LEFT || controls.RIGHT) {
				hold += elapsed;
			}
			if (controls.LEFT_R || controls.RIGHT_R) {
				hold = 0;
			}
			if (hold >= 0.5) {
				currentValue += stepper * (controls.LEFT ? -1 : 1);
				currentValue = Math.max(minValue, Math.min(currentValue, maxValue));
			}
		}
	}
	
	function updateValueFromMouse(mousePos:FlxPoint) {
		var relativeX = mousePos.x - sliderBar.x;
		var ratio = FlxMath.bound(relativeX / sliderBar.width, 0, 1);
		var rawValue = minValue + ratio * (maxValue - minValue);
		var stepped = Math.round(rawValue / stepper) * stepper;
		currentValue = FlxMath.bound(stepped, minValue, maxValue);
	}
	
	function set_currentValue(v) {
		valueCounter.text = v;
		return v;
	}
}
