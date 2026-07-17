import UndertaleText;
import TypedBitmapText;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxRandom;
import funkin.backend.utils.DiscordUtil;
import flixel.util.FlxTimer;

var stateCamera:FlxCamera = new FlxCamera();
var boxCamera:FlxCamera = new FlxCamera();
var r = new FlxRandom();

//Visuals.
var bg:FlxBackdrop;
var box:FlxSprite = new FlxSprite(0, 394).loadGraphic(Paths.image('options/boxbase'));
var title:UndertaleText = new UndertaleText(0, 285, 'OPTIONS', 'center', FlxG.width, 1.5, 'FFFFFF', 'undertale-outline');
var description:TypedBitmapText;
//Menu objects, data.
var selected:Int = 0;
var optionSelected:Bool = false;
var optionObjects:Array<Dynamic> = [];
var categories:Array<Dynamic> = [
	{
		title: 'Controls',
		description: '*Change your controls here!'
	},
	{
		title: 'Gameplay',
		description: '*Change your gameplay/ñexperience to your liking!'
	},
	{
		title: 'Appearance',
		description: '*Change specific aspects of/ñhow the game looks like.'
	},
	{
		title: 'Miscellaneous',
		description: '*Anything that doesn\'t/ñfit in with the rest.'
	}
];
var categoryData = [
	'gameplay' => [
		{
			type: 'checkbox',
			title: 'Downscroll',
			description: '*If checked the notes come/ñfrom the top instead of/ñthe bottom.',
			defaultValue: false,
			parentValue: 'downscroll',
			saveTo: Options
		},
		{
			type: 'checkbox',
			title: 'Ghost Tapping',
			description: '*Pressing a note when there/ñisn\'t one won\'t register/ñas a miss.',
			defaultValue: true,
			parentValue: 'ghostTapping',
			saveTo: Options
		},
		{
			type: 'checkbox',
			title: 'Naughtyness',
			description: '*If unchecked, any mean and/ñnaughty things will be/ñcensored.',
			defaultValue: true,
			parentValue: 'naughtyness',
			saveTo: Options
		},
		{
			type: 'checkbox',
			title: 'Camera Zoom on Beat',
			description: '*If checked, the camera will/ñzoom in on a certain beat.',
			defaultValue: true,
			parentValue: 'camZoomOnBeat',
			saveTo: Options
		},
		{
			type: 'checkbox',
			title: 'Auto Pause',
			description: '*If checked, the game will stop/ñwhen the window isn\'t focused.',
			defaultValue: true,
			parentValue: 'autoPause',
			saveTo: Options
		},
		{
			type: 'function',
			title: 'Edit Song Offset',
			description: '*The offset songs start with./*Use to mitigate audio delay.',
		},
		{
			type: 'slider',
			title: 'Music Volume',
			description: '*The volume of the music used/ñin the game.',
			defaultValue: 1,
			parentValue: 'volumeMusic',
			max: 1,
			min: 0,
			valueStep: 0.01,
			percentageDisplay: true,
			saveTo: Options,
		},
		{
			type: 'slider',
			title: 'SFX Volume',
			description: '*The volume of sound effects/ñused in the game',
			defaultValue: 1,
			parentValue: 'volumeSFX',
			max: 1,
			min: 0,
			valueStep: 0.01,
			percentageDisplay: true,
			saveTo: Options
		},
		{
			type: 'checkbox',
			title: 'Splashes Enabled',
			description: '*If unchecked, splashes won\'t/ñappear on note hit.',
			defaultValue: true,
			parentValue: 'splashesEnabled',
			saveTo: Options
		},
		{
			type: 'slider',
			title: 'Cam Move Distance',
			description: '*The amount of pixels the camera/ñmoves by when hitting a note./*Set to 0 to disable.',
			defaultValue: 4,
			parentValue: 'camFollowDistance',
			max: 14,
			min: 0
		}
	],
	'appearance' => [
		{
			type: 'slider',
			title: 'Framerate',
			description: '*FPS stands for \'frames per/ñsecond\'./*Did you know that?',
			defaultValue: 60,
			parentValue: 'framerate',
			saveTo: Options,
			valueSuffix: 'fps',
			max: 240,
			min: 60
		},
		{
			type: 'checkbox',
			title: 'Flashing Lights',
			description: '*If unchecked, any effects that/ñmay trigger epilepsy are/ñreduced or disabled.',
			defaultValue: true,
			parentValue: 'flashingLights'
		},
		{
			type: 'checkbox',
			title: 'Particles',
			description: '*If unchecked, any particle or/ñparticle based effects are/ñdisabled.',
			defaultValue: true,
			parentValue: 'particlesEnabled'
		},
		{
			type: 'function',
			title: 'Edit Ratings',
			description: '*Edit every aspect of the/ñratings, combo counter/ñwhichever you want, here!'
		},
		{
			type: 'checkbox',
			title: 'Colored Healthbar',
			description: '*If unchecked, the health bar/ñwill have that classic retro/ñred and green look.',
			defaultValue: true,
			parentValue: 'colorHealthBar',
			saveTo: Options
		},
		{
			type: 'checkbox',
			title: 'Pixel Perfect Render',
			description: '*If checked, every pixel stage/ñwill have a pixel perfect look.',
			defaultValue: false,
			parentValue: 'week6PixelPerfect',
			saveTo: Options
		},
		{
			type: 'choice',
			title: 'Soul Trait',
			description: '*The color of the soul used/ñwhen the soul appears.',
			defaultValue: 0,
			parentValue: 'soulColor',
			choices: ['determination', 'patience', 'bravery', 'integrity', 'perseverance', 'kindness', 'justice']
		},
		{
			type: 'checkbox',
			title: 'Antialiasing',
			description: '*If checked, it gives applicable/ñsprites a more smooth and/ñhigher quality look.',
			defaultValue: true,
			parentValue: 'antialiasing',
			saveTo: Options,
		},
		{
			type: 'checkbox',
			title: 'Low Memory Mode',
			description: '*If checked, disables certain/ñbackground elements to save/ñon memory.',
			defaultValue: false,
			parentValue: 'lowMemoryMode',
			saveTo: Options,
		},
		{
			type: 'checkbox',
			title: 'Shaders',
			description: '*If unchecked, stops all/ñshaders from loading.',
			defaultValue: true,
			parentValue: 'gameplayShaders',
			saveTo: Options
		},
		{
			type: 'checkbox',
			title: 'VRAM-Only Sprites',
			description: '*If checked, bitmaps (sprites)/ñare stored in V-RAM to save/ñon memory.',
			defaultValue: false,
			parentValue: 'gpuOnlyBitmaps',
			saveTo: Options
		}
	],
	'miscellaneous' => [
		{
			type: 'function',
			title: 'Reset Save Data',
			description: '*Does what it says.'
		}
	],
	'debug' => [
		#if windows
			{
				type: 'function',
				title: 'Show Console',
				description: '*You can just press F2, y\'know?',
			},
		#end
		{
			type: 'checkbox',
			title: 'Resizable Editors',
			description: '*',
			defaultValue: true,
			parentValue: 'editorsResizable',
			saveTo: Options,
		},
		{
			type: 'checkbox',
			title: 'Bypass Editor Resize',
			description: '*',
			defaultValue: false,
			parentValue: 'bypassEditorsResize',
			saveTo: Options,
		},
		{
			type: 'checkbox',
			title: 'Editor SFX',
			description: '*',
			defaultValue: true,
			parentValue: 'editorSFX',
			saveTo: Options,
		},
		{
			type: 'checkbox',
			title: 'Chart Pretty Print',
			description: '*',
			defaultValue: false,
			parentValue: 'editorCharterPrettyPrint',
			saveTo: Options,
		},
		{
			type: 'checkbox',
			title: 'Character Pretty Print',
			description: '*',
			defaultValue: true,
			parentValue: 'editorCharacterPrettyPrint',
			saveTo: Options,
		},
		{
			type: 'checkbox',
			title: 'Stage Pretty Print',
			description: '*',
			defaultValue: true,
			parentValue: 'editorStagePrettyPrint',
			saveTo: Options,
		},
		{
			type: 'checkbox',
			title: 'Intensive Blur',
			description: '*',
			defaultValue: true,
			parentValue: 'intensiveBlur',
			saveTo: Options,
		},
		{
			type: 'checkbox',
			title: 'Editor Autosaves',
			description: '*',
			defaultValue: true,
			parentValue: 'charterAutoSaves',
			saveTo: Options,
		},
		{
			type: 'slider',
			title: 'Autosaving Time',
			description: '*',
			defaultValue: true,
			parentValue: 'charterAutoSaveTime',
			max: 60 * 10,
			min: 60,
			saveTo: Options,
		},
		{
			type: 'slider',
			title: 'Save Warning Time',
			description: '*',
			defaultValue: true,
			parentValue: 'charterAutoSaveWarningTime',
			max: 15,
			min: 0,
			saveTo: Options,
		},
		{
			type: 'checkbox',
			title: 'Autosaves Folder',
			description: '*',
			defaultValue: false,
			parentValue: 'charterAutoSavesSeparateFolder',
			saveTo: Options,
		},
		{
			type: 'checkbox',
			title: 'Offset in Charter',
			description: '*',
			defaultValue: false,
			parentValue: 'songOffsetAffectEditors',
			saveTo: Options,
		},
	],
];
//Other.
var timer:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);

// ========== 拖拽相关变量 ==========
var isDragging:Bool = false;
var dragStartY:Float = 0;
var dragStartSelected:Int = 0;
var dragThreshold:Float = 5;
var dragSensitivity:Float = 0.014;
var lastDelta:Float = 0;
var velocityHistory:Array<Float> = [];
var inertiaTimer:FlxTimer;

// ========== 子菜单状态控制 ==========
var inSubState:Bool = false;

// ========== 模式管理 ==========
var inputMode:String = "keyboard";

// ---------- 退出按钮 ----------
var uiCamera:FlxCamera;
var exitButton:FlxSprite;
var exitButtonHovered:Bool = false;

function create() {
	FlxG.cameras.add(stateCamera, false);
	stateCamera.bgColor = FlxColor.TRANSPARENT;
	stateCamera.zoom = 4;
	
	DiscordUtil.changePresenceAdvanced({
		details: 'Changing some settings',
	});

	FlxG.cameras.add(boxCamera, false);
	boxCamera.bgColor = FlxColor.TRANSPARENT;
	boxCamera.zoom = 3;
	boxCamera.visible = false;
	
	var v:Int = 20;
	var tile:FlxSprite = FlxGridOverlay.create(60, 60, 120, 120, true, 0xFF969696, 0xFF404040);
	bg = new FlxBackdrop(tile.pixels, FlxAxes.XY);
	bg.alpha = 0.5;
	bg.velocity.set(v, v);
	add(bg);
	
	if (Options.devMode) {
		categories.push({title: 'Debug', description: '*Options for developers.'});
		categories.push({title: 'Mod Specific (REMOVE LATER)', description: 'for whatever other bullshit i/add to the mod like frisk or botplay and /some other stuff'});
	}

	var index:Int = 0;
	for (category in categories) {
		var button:UndertaleText = new UndertaleText(514, 0, category.title.toUpperCase(), 'left', FlxG.width, 1, 'FFFFFF', 'undertale-outline');
		button.autoSize = true;
		button.updateHitbox();
		button.screenCenter(FlxAxes.Y);
		button.ID = index;
		button.cameras = [stateCamera];
		add(button);
		optionObjects.push({
			object: button,
			initX: button.x,
			initY: button.y,
			id: index
		});
		index++;
	}
	
	title.cameras = [stateCamera];
	title.screenCenter(FlxAxes.X);
	add(title);
	
	var scale:Float = 1;
	box.scale.set(scale, scale);
	box.updateHitbox();
	box.screenCenter(FlxAxes.X);
	box.cameras = [boxCamera];
	add(box);
	
	var t:UndertaleText = new UndertaleText(0, 0, '*', 'left', 0, 1, 'FFFFFF');
	description = new TypedBitmapText(box.x + 14, box.y + 11, '*', t.getFont('undertale-pixel'));
	description.setTextFormat(1, 'FFFFFF', t.getAlignment('left'), FlxG.width);
	description.parentState = this;
	description.lineOffset = 0;
	description.lineSpacing = 18;
	description.cameras = [boxCamera];
	add(description);
	
	this.subState = null;
	
	// ---------- 退出按钮（统一大小与位置：与 Freeplay 一致）----------
	uiCamera = new FlxCamera();
	uiCamera.bgColor = FlxColor.TRANSPARENT;
	uiCamera.zoom = 1;
	uiCamera.antialiasing = false;
	FlxG.cameras.add(uiCamera, false);
	
	exitButton = new FlxSprite().loadGraphic(Paths.image('pause/exit'));
	exitButton.scale.set(1.6, 1.6);   // 与 Freeplay 相同
	exitButton.updateHitbox();
	exitButton.setPosition(-exitButton.width - 10, 10); // 起始在左外侧，偏移10与目标左距一致
	exitButton.antialiasing = false;
	exitButton.cameras = [uiCamera];
	exitButton.alpha = 0;
	add(exitButton);
	
	#if mobile
		inputMode = "touch";
	#else
		inputMode = "keyboard";
	#end
	
	enterTransition(true);
}

var objectDistance:Int = 19;
var lerp:Float = 0;
var categoryTransitionTime:Float = 0.1;
var exiting:Bool = false;
public var canChange:Bool = true;
var specialSubMenu:Bool = false;
var doOnce:Bool = false;
public var canExitCategory:Bool = false;

function update(elapsed:Float) {
	// ========== 模式切换 ==========
	if (inputMode == "keyboard") {
		if (FlxG.mouse.justPressed) switchToTouch();
	} else {
		if (controls.LEFT_P || controls.RIGHT_P || controls.UP_P || controls.DOWN_P || controls.ACCEPT) {
			switchToKeyboard();
		}
	}

	if (description != null) {
		description.textUpdate(elapsed);
	}

	// ========== 退出按钮交互（仅当可见时） ==========
	if (exitButton.visible) {
		var mousePoint = FlxG.mouse.getWorldPosition(uiCamera);
		var isHover = exitButton.overlapsPoint(mousePoint, false, uiCamera);
		if (isHover != exitButtonHovered) {
			exitButtonHovered = isHover;
			exitButton.color = exitButtonHovered ? FlxColor.YELLOW : FlxColor.WHITE;
		}
		if (FlxG.mouse.justReleased && exitButtonHovered) {
			FlxG.sound.play(Paths.sound('select'), Options.volumeSFX);
			if (!exiting) {
				enterTransition(false);
				exiting = true;
			}
			return;
		}
	}

	// ========== 检测子菜单返回 ==========
	if (inSubState && this.subState == null) {
		inSubState = false;
		optionSelected = false;
		boxCamera.visible = true;
		title.text = 'OPTIONS';
		for (object in optionObjects) {
			object.object.x = object.initX;
			object.object.y = object.initY;
			object.object.visible = true;
			object.object.color = (object.id == selected ? FlxColor.YELLOW : FlxColor.WHITE);
		}
		description.resetAndChangeText(categories[selected].description, true);
		description.startTyping(0.01, 'text-blip', true);
		description.advanceDialogue();
		isDragging = false;
		canChange = true;
		exitButton.visible = true;
		exitButton.alpha = 1;
		exitButton.x = 10;      // 复位到目标位置
		exitButton.y = 10;
	}

	// ========== 文本动画 ==========
	lerp = Math.exp(-elapsed * 28);
	for (object in optionObjects) {
		var text:UndertaleText = object.object;
		if (!optionSelected && !inSubState) {
			text.setPosition(FlxMath.lerp(object.initX + (4 * (object.id == selected ? 1 : -1)), text.x, lerp), 
							 FlxMath.lerp(((object.id - selected) * objectDistance) + object.initY, text.y, lerp));
			text.scale.set(FlxMath.lerp(1 + (0.2 * (object.id == selected ? 1 : 0)), text.scale.x, lerp / 2), 
						   FlxMath.lerp(1 + (0.2 * (object.id == selected ? 1 : 0)), text.scale.y, lerp / 2));
		} else {
			text.setPosition(object.initX + (4 * (object.id == selected ? 1 : -1)), 
							 ((object.id - selected) * objectDistance) + object.initY);
			text.scale.set(1 + (0.2 * (object.id == selected ? 1 : 0)), 1 + (0.2 * (object.id == selected ? 1 : 0)));
		}
		text.updateHitbox();
		if (text.ID == selected && !optionSelected && !inSubState) {
			text.offset.y += 1;
		}
		if (inputMode == "touch" && categories[text.ID].title == "Controls") {
			text.alpha = 0.5;
		} else {
			text.alpha = 1.0;
		}
	}
	
	if (specialSubMenu) {
		if (this.subState == null) {
			specialSubMenu = false;
		}
		return;
	}
	
	if (optionSelected) {
		if (this.subState == null && canExitCategory) {
			if (!doOnce) {
				FlxTween.tween(timer, {x: 0}, categoryTransitionTime, {onComplete: function() {
					for (object in optionObjects) {
						object.object.x = 100;
						object.object.visible = true;
					}
					description.resetAndChangeText(categories[selected].description, true);
					description.startTyping(0.01, 'text-blip', true);
					description.advanceDialogue();
					title.text = 'OPTIONS';
					boxCamera.visible = true;
					optionSelected = false;
				}});
				canExitCategory = false;
				doOnce = true;
			}
		}
		return;
	}
	
	// ========== 主菜单交互 ==========
	if (!optionSelected && !inSubState && !exiting && canChange && !specialSubMenu) {
		var mousePointMain = FlxG.mouse.getWorldPosition(stateCamera);
		if (FlxG.mouse.justPressed && !isDragging) {
			for (object in optionObjects) {
				var text:UndertaleText = object.object;
				if (text.visible && text.overlapsPoint(mousePointMain, false, stateCamera)) {
					isDragging = true;
					dragStartY = FlxG.mouse.screenY;
					dragStartSelected = selected;
					velocityHistory = [];
					lastDelta = 0;
					break;
				}
			}
		}
		
		if (isDragging && FlxG.mouse.pressed) {
			var deltaY = FlxG.mouse.screenY - dragStartY;
			var rawIndex = dragStartSelected - deltaY * dragSensitivity;
			var targetIndex = Math.round(rawIndex);
			targetIndex = FlxMath.bound(targetIndex, 0, optionObjects.length - 1);
			
			if (targetIndex != selected) {
				selected = targetIndex;
				description.resetAndChangeText(categories[selected].description, true);
				description.startTyping(0.026, 'text-blip', true);
				description.advanceDialogue();
				for (obj in optionObjects) {
					obj.object.color = (obj.id == selected ? FlxColor.YELLOW : FlxColor.WHITE);
				}
				FlxG.sound.play(Paths.sound('squeak'), Options.volumeSFX);
			}
			
			var currentDelta = FlxG.mouse.screenY - dragStartY;
			var velocity = (currentDelta - lastDelta) / elapsed;
			velocityHistory.push(velocity);
			if (velocityHistory.length > 10) velocityHistory.shift();
			lastDelta = currentDelta;
		}
		
		if (isDragging && FlxG.mouse.justReleased) {
			var totalDelta = FlxG.mouse.screenY - dragStartY;
			// 获取点击到的选项
			var clickedId:Int = -1;
			for (object in optionObjects) {
				var text:UndertaleText = object.object;
				if (text.visible && text.overlapsPoint(mousePointMain, false, stateCamera)) {
					clickedId = object.id;
					break;
				}
			}
			if (Math.abs(totalDelta) <= dragThreshold) {
				if (clickedId != -1) {
					if (clickedId == selected) {
						performAccept();
					} else {
						// 仅切换选中
						selected = clickedId;
						description.resetAndChangeText(categories[selected].description, true);
						description.startTyping(0.026, 'text-blip', true);
						description.advanceDialogue();
						for (obj in optionObjects) {
							obj.object.color = (obj.id == selected ? FlxColor.YELLOW : FlxColor.WHITE);
						}
						FlxG.sound.play(Paths.sound('squeak'), Options.volumeSFX);
					}
				}
			} else {
				// 惯性处理
				var avgVelocity = 0.0;
				if (velocityHistory.length > 0) {
					for (v in velocityHistory) avgVelocity += v;
					avgVelocity /= velocityHistory.length;
				}
				if (Math.abs(avgVelocity) > 60) {
					var direction = (avgVelocity < 0) ? 1 : -1;
					var speed = Math.abs(avgVelocity);
					var extraSteps = Math.floor(speed / 350);
					extraSteps = FlxMath.bound(extraSteps, 1, 3);
					
					if (inertiaTimer != null) inertiaTimer.cancel();
					var stepsRemaining = extraSteps;
					inertiaTimer = new FlxTimer().start(0.05, function(timer:FlxTimer) {
						if (stepsRemaining <= 0) {
							timer.cancel();
							return;
						}
						var newIndex = selected + direction;
						if (newIndex < 0 || newIndex >= optionObjects.length) {
							timer.cancel();
							return;
						}
						selected = newIndex;
						description.resetAndChangeText(categories[selected].description, true);
						description.startTyping(0.026, 'text-blip', true);
						description.advanceDialogue();
						for (obj in optionObjects) {
							obj.object.color = (obj.id == selected ? FlxColor.YELLOW : FlxColor.WHITE);
						}
						FlxG.sound.play(Paths.sound('squeak'), Options.volumeSFX);
						stepsRemaining--;
					}, extraSteps);
				}
			}
			isDragging = false;
		}

		// 键盘输入
		if (inputMode == "keyboard") {
			if (FlxG.mouse.wheel != 0) {
				updateSelection(-FlxG.mouse.wheel);
			}
			if (controls.ACCEPT) {
				performAccept();
			} else if (controls.BACK) {
				if (!exiting) {
					enterTransition(false);
					exiting = true;
				}
			} else if (controls.UP_P) {
				updateSelection(-1);
			} else if (controls.DOWN_P) {
				updateSelection(1);
			}
		}
	}
}

// ========== 模式切换 ==========
function switchToTouch() {
	if (inputMode == "touch") return;
	inputMode = "touch";
}

function switchToKeyboard() {
	if (inputMode == "keyboard") return;
	inputMode = "keyboard";
}

// ========== 进入子菜单 ==========
function performAccept() {
	if (optionSelected || exiting || !canChange || inSubState) return;
	if (inputMode == "touch" && categories[selected].title == "Controls") return;
	
	FlxG.sound.play(Paths.sound('select'), Options.volumeSFX);
	
	exitButton.visible = false;
	
	for (object in optionObjects) {
		object.object.visible = false;
	}
	boxCamera.visible = false;
	optionSelected = true;
	inSubState = true;
	
	switch(categories[selected].title.toLowerCase()) {
		case 'controls':
			openSubState(new ModSubState('OptionsKeybinds', [{
				originalBg: bg
			}]));
			specialSubMenu = true;
		default:
			var stateData:Array<Dynamic> = [
				{
					stateBg: bg,
					mainCamera: stateCamera,
					descriptionCamera: boxCamera,
					descriptionBox: description,
				}
			];
			stateData.push(categoryData.get(categories[selected].title.toLowerCase()));
			stateData.push({inputMode: inputMode});
			
			title.text = categories[selected].title.toUpperCase();
			openSubState(new ModSubState('OptionCategorySubstate', stateData));
	}
}

function updateSelection(?v:Int) {
	if (optionSelected || exiting || !canChange || inSubState) return;
	if (v != null) {
		FlxG.sound.play(Paths.sound('squeak'), Options.volumeSFX);
		selected += v;
		if (selected > optionObjects.length - 1) selected = 0;
		else if (selected < 0) selected = optionObjects.length - 1;
	}
	description.resetAndChangeText(categories[selected].description, true);
	description.startTyping(0.026, 'text-blip', true);
	description.advanceDialogue();
	for (object in optionObjects) {
		object.object.color = (object.id == selected ? FlxColor.YELLOW : FlxColor.WHITE);
	}
}

var time:Int = 0.25;
function enterTransition(e:Bool) {
	if (e) {
		bg.alpha = 0;
		FlxTween.tween(bg, {alpha: 0.5}, time / 2, {startDelay: time / 3, ease: FlxEase.cubeIn});
		stateCamera.alpha = 0;
		stateCamera.y += 500;
		FlxTween.tween(stateCamera, {alpha: 1, y: 0}, time, {ease: FlxEase.cubeInOut, onComplete: function() {
			boxCamera.visible = true;
			updateSelection();
		}});
		// 退出按钮：从左外侧滑入（先快后慢），目标位置 (10,10)
		exitButton.x = -exitButton.width - 10;
		exitButton.y = 10;
		exitButton.alpha = 0;
		exitButton.visible = true;
		FlxTween.tween(exitButton, {x: 10, alpha: 1}, 0.4, {ease: FlxEase.quartOut});
	} else {
		boxCamera.visible = false;
		FlxTween.tween(bg, {alpha: 0}, time / 3, {ease: FlxEase.cubeIn, onComplete: function() {
			FlxTween.tween(stateCamera, {alpha: 0, y: 500}, time, {ease: FlxEase.cubeInOut, onComplete: function() {
				if (data != null && data) {
					FlxG.switchState(new PlayState());
				} else {
					FlxG.switchState(new ModState('ModMainMenu', 'options'));
				}
			}});
		}});
		// 退出按钮：向上方移出（先快后慢）
		FlxTween.tween(exitButton, {y: -exitButton.height - 10, alpha: 0}, 0.4, {ease: FlxEase.quartOut, onComplete: function() {
			exitButton.visible = false;
		}});
	}
}