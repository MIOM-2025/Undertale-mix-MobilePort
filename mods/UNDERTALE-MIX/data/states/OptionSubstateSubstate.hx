// 保留所有新功能，修正 data 解析
import UndertaleText;
import TypedBitmapText;
import optiontypes.Checkbox;
import optiontypes.Slider;
import optiontypes.Choice;
import funkin.savedata.FunkinSave;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxRandom;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;

var stateCamera:FlxCamera = new FlxCamera();
var boxCamera:FlxCamera = new FlxCamera();
var r = new FlxRandom();

//Base menu stuff.
var box:FlxSprite = new FlxSprite(0, 394).loadGraphic(Paths.image('options/boxbase'));
var description:TypedBitmapText;
//Menu objects, data.
var selected:Int = 0;
var optionSelected:Bool = false;
var optionObjects:Array<Dynamic> = [];
var categories:Array<Dynamic> = [];
//Other.
var timer:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);

// ========== 触控拖拽相关变量 ==========
var isDragging:Bool = false;
var dragStartY:Float = 0;
var dragStartSelected:Int = 0;
var dragThreshold:Float = 5;
var dragSensitivity:Float = 0.014;
var lastDelta:Float = 0;
var velocityHistory:Array<Float> = [];
var inertiaTimer:FlxTimer;

// ========== 返回按钮和 UI 相机 ==========
var uiCamera:FlxCamera;
var backBtn:FlxSprite;

// ========== 输入模式 ==========
var inputMode:String = "keyboard";

// ★★★ 锁对象（兼容传递）★★★
var lockObj:Dynamic;

function create() {
    persistentUpdate = false;

    // ----- 修正 data 解析（兼容两种传递方式）-----
    if (data != null && data.length > 0) {
        // 如果 data[0] 具有 isSS 属性，则视为锁对象，data[1] 为 categories
        if (data[0].isSS != null) {
            lockObj = data[0];
            categories = (data.length > 1) ? data[1] : [];
        } else {
            // 否则 data 本身就是 categories 数组
            categories = data;
        }
    } else {
        categories = [];
    }

    FlxG.cameras.add(stateCamera, false);
    stateCamera.bgColor = FlxColor.TRANSPARENT;
    stateCamera.zoom = 4;
    
    FlxG.cameras.add(boxCamera, false);
    boxCamera.bgColor = FlxColor.TRANSPARENT;
    boxCamera.zoom = 3;
    boxCamera.visible = false;

    var v:Int = 10;
    var tile:FlxSprite = FlxGridOverlay.create(15, 15, 30, 30, true, 0xFF969696, 0xFF404040);
    bg = new FlxBackdrop(tile.pixels, FlxAxes.XY);
    bg.cameras = [stateCamera];
    bg.alpha = 0.5;
    bg.velocity.set(v, v);
    add(bg);
    
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
    
    var index:Int = 0;
    for (category in categories) {
        var button:UndertaleText = new UndertaleText(514, 0, category.title.toUpperCase(), 'left', FlxG.width, 1, 'FFFFFF', 'undertale-outline');
        button.autoSize = true;
        button.updateHitbox();
        button.screenCenter(FlxAxes.Y);
        button.ID = index;
        button.cameras = [stateCamera];
        add(button);
        
        var optionType:Dynamic;
        switch(category.type) {
            case 'checkbox':
                optionType = new Checkbox(0, 0, button, category.parentValue, category.defaultValue, (category.saveTo != null ? category.saveTo : null));
                optionType.cameras = [stateCamera];
                add(optionType);
            case 'slider':
                optionType = new Slider(0, 0, this, button, category.parentValue, category.defaultValue, category.min, category.max, (category.percentageDisplay != null ? category.percentageDisplay : null), (category.saveTo != null ? category.saveTo : null), (category.valueStep != null ? category.valueStep : null), (category.valueSuffix != null ? category.valueSuffix : null));
                optionType.cameras = [stateCamera];
                add(optionType);
            case 'choice':
                optionType = new Choice(0, 0, this, button, category.parentValue, category.defaultValue, category.choices, (category.saveTo != null ? category.saveTo : null));
                optionType.cameras = [stateCamera];
                add(optionType);
        }
        optionObjects.push({
            object: button,
            initX: button.x,
            initY: button.y,
            id: index,
            add: (category.type == 'checkbox' ? 13 : 0),
            option: optionType
        });
        index++;
    }
    
    for (object in optionObjects) {
        object.object.x = 100;
    }
    
    boxCamera.visible = true;
    updateSelection();

    #if mobile
        inputMode = "touch";
    #else
        inputMode = "keyboard";
    #end

    uiCamera = new FlxCamera();
    uiCamera.bgColor = FlxColor.TRANSPARENT;
    uiCamera.zoom = 1;
    uiCamera.antialiasing = false;
    FlxG.cameras.add(uiCamera, false);
    
    backBtn = new FlxSprite().loadGraphic(Paths.image('freeplay/backspace'));
    backBtn.antialiasing = false;
    backBtn.scale.set(6, 6);
    backBtn.updateHitbox();
    backBtn.setPosition(10, 10);
    backBtn.alpha = 1;
    backBtn.cameras = [uiCamera];
    add(backBtn);
}

var objectDistance:Int = 19;
var lerp:Float = 0;
var categoryTransitionTime:Float = 0.1;
var lastBeat:Int = 0;
var canChange:Bool = true;

function update(elapsed:Float) {
    // ========== 模式切换 ==========
    if (inputMode == "keyboard") {
        if (FlxG.mouse.justPressed) {
            inputMode = "touch";
        }
    } else {
        if (controls.LEFT_P || controls.RIGHT_P || controls.UP_P || controls.DOWN_P || controls.ACCEPT) {
            inputMode = "keyboard";
        }
    }

    // ========== 返回按钮交互 ==========
    var mousePoint = FlxG.mouse.getWorldPosition(uiCamera);
    var isHover = backBtn.overlapsPoint(mousePoint, false, uiCamera);
    backBtn.color = isHover ? FlxColor.YELLOW : FlxColor.WHITE;
    if (FlxG.mouse.justReleased && isHover) {
        FlxG.sound.play(Paths.sound('select'), Options.volumeSFX);
        performBack();
        return;
    }

    // 文字动画
    lerp = Math.exp(-elapsed * 24.6);
    for (object in optionObjects) {
        var text:UndertaleText = object.object;
        text.setPosition(FlxMath.lerp(object.initX + object.add + (4 * (object.id == selected && !optionSelected ? 1 : -1)), text.x, lerp), FlxMath.lerp(((object.id - selected) * objectDistance) + object.initY, text.y, lerp));
        text.updateHitbox();
        if (text.ID == selected) {
            text.offset.y += 1;
        }
    }

    // ========== 触控拖拽逻辑 ==========
    if (!optionSelected && canChange && this.substate == null && inputMode == "touch") {
        var mousePointMain = FlxG.mouse.getWorldPosition(stateCamera);
        
        if (FlxG.mouse.justPressed && !isDragging) {
            for (object in optionObjects) {
                var text:UndertaleText = object.object;
                if (text.overlapsPoint(mousePointMain, false, stateCamera)) {
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
            var clickedOption:Int = -1;
            for (object in optionObjects) {
                var text:UndertaleText = object.object;
                if (text.visible && text.overlapsPoint(mousePointMain, false, stateCamera)) {
                    clickedOption = object.id;
                    break;
                }
            }
            
            if (Math.abs(totalDelta) <= dragThreshold) {
                if (clickedOption != -1) {
                    if (clickedOption == selected) {
                        performAccept();
                    } else {
                        selected = clickedOption;
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
    }

    if (optionSelected) {
        return;
    }
    if (this.substate != null) {
        return;
    }
    
    // ========== 键盘输入 ==========
    if (inputMode == "keyboard") {
        if (FlxG.mouse.wheel != 0) {
            updateSelection(-FlxG.mouse.wheel);
        }
        if (controls.ACCEPT) {
            performAccept();
        } else if (controls.BACK) {
            performBack();
        } else if (controls.UP_P) {
            updateSelection(-1);
        } else if (controls.DOWN_P) {
            updateSelection(1);
        }
    }
    
    // 实时更新音量/帧率
    if (categories[selected].title == 'Music Volume') {
        FlxG.sound.music.volume = optionObjects[selected].option.currentValue;
    } else if (categories[selected].title == 'Framerate') {
        if (FlxG.updateFramerate < optionObjects[selected].option.currentValue)
            FlxG.drawFramerate = FlxG.updateFramerate = optionObjects[selected].option.currentValue;
        else
            FlxG.updateFramerate = FlxG.drawFramerate = optionObjects[selected].option.currentValue;
    }
}

// ========== 统一的退出函数（带退出动画） ==========
function performBack() {
    // 解锁父状态（若存在锁对象）
    if (lockObj != null) {
        lockObj.isSS = false;
    }

    if (!optionSelected) {
        for (object in optionObjects) {
            FlxTween.tween(object.object, {x: 100}, categoryTransitionTime, {ease: FlxEase.cubeInOut, onComplete: function() {
                object.object.visible = false;
            }});
        }
        FlxTween.tween(timer, {x: 1}, categoryTransitionTime, {onComplete: function() {
            close();
        }});
        boxCamera.visible = false;
        optionSelected = true;
    }
}

function updateSelection(?v:Int) {
    if (v != null) {
        FlxG.sound.play(Paths.sound('squeak'), Options.volumeSFX);
        selected += v;
        if (selected > optionObjects.length - 1) {
            selected = 0;
        } else if (selected < 0) {
            selected = optionObjects.length - 1;
        }
    }
    description.resetAndChangeText(categories[selected].description, true);
    description.startTyping(0.026, 'text-blip', true);
    description.advanceDialogue();
    for (object in optionObjects) {
        object.object.color = (object.id == selected ? FlxColor.YELLOW : FlxColor.WHITE);
    }
}

function performAccept() {
    if (categories[selected].type != 'slider') {
        FlxG.sound.play(Paths.sound('select'), Options.volumeSFX);
    }
    if (categories[selected].title == 'Edit Song Offset') {
        if (canChange) {
            openSubState(new ModSubState('OffsetEditorSubstate'));
        }
    } else if (categories[selected].title == 'Edit Ratings') {
        if (canChange) {
            openSubState(new ModSubState('RatingEditorSubstate'));
        }
    } else if (categories[selected].title == 'Reset Save Data') {
        FunkinSave.save.erase();
        FunkinSave.highscores.clear();
        FunkinSave.flush();
        FlxG.save.erase();
        FlxG.switchState(new ModState('ModTitle'));
    } else if (categories[selected].type == 'checkbox') {
        var checkbox:Checkbox = cast optionObjects[selected].option;
        checkbox.toggle();
    }
}