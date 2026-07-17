import UndertaleText;
import flixel.addons.display.FlxBackdrop;
import flixel.input.mouse.FlxMouseEvent;
import flixel.input.mouse.FlxMouseEventManager;
import haxe.Json;
import sys.FileSystem;
import StringTools;
import funkin.backend.utils.DiscordUtil;

// ========== 模式管理变量 ==========
var inputMode:String = "keyboard";        // "keyboard" 或 "touch"
var hoveredButton:Int = -1;              // 当前鼠标悬停的按钮ID
var hoveredItem:Int = -1;                // 当前鼠标悬停的列表项ID
var lastHoveredButton:Int = -1;          // 上次悬停的按钮ID，用于判断变化播放声音
var lastHoveredItem:Int = -1;            // 上次悬停的列表项ID

var buttonOptions:Array<String> = [
	'art', 'music', 'code', 'chart', 'misc','port'
];
var dog:FlxSprite;
var battleBackdrop:FlxBackdrop;
var stateCamera:FlxCamera = new FlxCamera();
/* Submenu variables */
var createdCredits:FlxTypedGroup<UndertaleText>;
var currentRow:Int = 1;
var existingCredits:Array<Dynamic>;
var itemSelected:Int = -1;               // 当前选中的列表项索引（-1表示无选中）
var pageMult:Int = 1;
var realCurrentRow:Int = 0;
var maxPages:Int = 0;
var maxRows:Int = 1;
var page:UndertaleText;
var itemPointer:FlxSprite;               // 列表页的灵魂指针（跟随鼠标悬停）
/* Menu button variables */
var buttons:FlxTypedGroup<FlxSprite>;
var buttonSelected:Int = -1;             // 当前选中的分类索引
var buttonSubmenu:Bool = false;

var soulPointer:FlxSprite;               // 主界面的灵魂指针（跟随鼠标悬停）
var description:UndertaleText;
/* Credits entry variables. */
var inCredit:Bool = false;
var curPage:Int = 0;
var creditName:UndertaleText;
var creditDescription:UndertaleText;
var savedItemSelected:Int = -1;

// 主界面键盘高亮按钮
var highlightedButton:Int = -1;

// ---------- 退出按钮 ----------
var exitButton:FlxSprite;
var exitButtonHovered:Bool = false;

// 新增独立UI摄像机
var uiCamera:FlxCamera;

// ========== RB 彩蛋相关变量（详情页） ==========
var rbActive:Bool = false;
var rbTimer:Float = 0;
var rbTransitionDuration:Float = 1.0;
var rbColorStart:FlxColor = FlxColor.WHITE;
var rbColorTarget:FlxColor = FlxColor.WHITE;
var rbProgress:Float = 0;
var rbColorIndex:Int = 0;
var rbColors:Array<FlxColor> = [
	FlxColor.RED,
	FlxColor.ORANGE,
	FlxColor.YELLOW,
	FlxColor.GREEN,
	FlxColor.CYAN,
	FlxColor.BLUE,
	FlxColor.PURPLE
];

// ========== 列表页 RB 彩虹相关变量 ==========
var listRbActive:Bool = false;
var listRbColorStart:FlxColor = FlxColor.WHITE;
var listRbColorTarget:FlxColor = FlxColor.WHITE;
var listRbProgress:Float = 0;
var listRbColorIndex:Int = 0;
var listRbSelectedIndex:Int = -1; // 当前选中且为RB的条目索引

function create() {
	// ---- 创建 UI 摄像机（固定，不移动） ----
	uiCamera = new FlxCamera();
	uiCamera.bgColor = FlxColor.TRANSPARENT;
	uiCamera.zoom = 1;
	uiCamera.x = 0;
	uiCamera.y = 0;
	uiCamera.antialiasing = false;
	
	
	FlxG.cameras.add(stateCamera, false);
	FlxG.cameras.add(uiCamera, false); // false 不设为默认
	stateCamera.bgColor = FlxColor.TRANSPARENT;
	stateCamera.zoom = 1;
	stateCamera.x = 0;
	stateCamera.y = 0;
	this.cameras = [stateCamera];
	
	DiscordUtil.changePresenceAdvanced({
		details: 'Seeing Credits',
	});
	
	battleBackdrop = new FlxBackdrop(Paths.image('credits/background'), FlxAxes.XY);
	battleBackdrop.scale.set(1.5, 1.5);
	battleBackdrop.velocity.set(30, 0);
	battleBackdrop.antialiasing = true;
	add(battleBackdrop);
	battleBackdrop.cameras = [stateCamera];
	
	var dither:FlxSprite = new FlxSprite().loadGraphic(Paths.image('credits/dithereffect'));
	dither.scale.set(1.5, 1.5);
	dither.updateHitbox();
	dither.screenCenter();
	dither.antialiasing = true;
	add(dither);
	dither.cameras = [stateCamera];

	var box:FlxSprite = new FlxSprite().loadGraphic(Paths.image('credits/box'));
	box.scale.set(1.5, 1.5);
	box.updateHitbox();
	box.screenCenter();
	box.antialiasing = true;
	add(box);
	box.cameras = [stateCamera];

	description = new UndertaleText(249, 154, '* Pick a category!', 'left', FlxG.width, 1.6);
	description.text = '* ' + randomMessage();
	description.updateHitbox();
	add(description);
	description.cameras = [stateCamera];

	creditName = new UndertaleText(633, 164, '* Some guy.',  'left', FlxG.width, 1.6);
	creditName.visible = false;
	add(creditName);
	creditName.cameras = [stateCamera];

	creditDescription = new UndertaleText(249, 202, '* Who is this?', 'left', FlxG.width, 1.6);
	creditDescription.visible = false;
	add(creditDescription);
	creditDescription.cameras = [stateCamera];
	
	createdCredits = new FlxTypedGroup<UndertaleText>();
	add(createdCredits);
	createdCredits.cameras = [stateCamera];

	// ========== 按钮居中布局，间距 5 ==========
	buttons = new FlxTypedGroup<FlxSprite>();
	add(buttons);
	
	var tempButtons:Array<FlxSprite> = [];
	var totalWidth:Float = 0;
	var spacing:Float = 5;
	for (i => option in buttonOptions) {
		var button:FlxSprite = new FlxSprite(0, 620).loadGraphic(Paths.image('credits/buttons/' + option));
		button.scale.set(1.5, 1.5);
		button.updateHitbox();
		button.ID = i;
		button.antialiasing = true;
		tempButtons.push(button);
		totalWidth += button.width;
	}
	var totalGroupWidth:Float = totalWidth + (buttonOptions.length - 1) * spacing;
	var startX:Float = (FlxG.width - totalGroupWidth) / 2;
	for (i => button in tempButtons) {
		button.x = startX;
		startX += button.width + spacing;
		buttons.add(button);
		button.cameras = [stateCamera];
	}

	page = new UndertaleText(1210, 510, 'PAGE 1', 'left', FlxG.width, 1.6);
	page.color = FlxColor.WHITE;
	page.visible = false;  // 初始隐藏，仅在有内容时显示
	add(page);
	page.cameras = [stateCamera];

	dog = new FlxSprite(840, -17).loadGraphic(Paths.image('credits/dogs/default'));
	dog.scale.set(4, 4);
	dog.updateHitbox();
	dog.antialiasing = false;
	add(dog);
	dog.cameras = [stateCamera];
	
	soulPointer = new FlxSprite(0, 627).loadGraphic(Paths.image('credits/buttons/soul'));
	soulPointer.scale.set(1.5, 1.5);
	soulPointer.updateHitbox();
	var colors = [
		'determination' => 'FF0000',
		'patience' => '42FCFF',
		'bravery' => 'FCA600',
		'integrity' => '003CFF',
		'perseverance' => 'D535D9',
		'kindness' => '00C000',
		'justice' => 'FFFF00'
	];
	var thisColor:String = FlxG.save.data.soulColor;
	thisColor ??= 'determination';
	var soulColor:String = colors[thisColor];
	soulPointer.color = FlxColor.fromString('#' + soulColor);
	soulPointer.antialiasing = true;
	soulPointer.visible = false;
	add(soulPointer);
	soulPointer.cameras = [stateCamera];

	itemPointer = new FlxSprite().loadGraphic(Paths.image('credits/buttons/soul'));
	itemPointer.scale.set(1.5, 1.5);
	itemPointer.updateHitbox();
	itemPointer.color = soulPointer.color; // 固定颜色
	itemPointer.antialiasing = true;
	itemPointer.visible = false;
	add(itemPointer);
	itemPointer.cameras = [stateCamera];

	var header:UndertaleText = new UndertaleText(0, 52, 'CREDITS', 'center', FlxG.width, 3);
	add(header);
	header.cameras = [stateCamera];
	
	// ---------- 退出按钮（使用独立 uiCamera）----------
	exitButton = new FlxSprite().loadGraphic(Paths.image('pause/exit'));
	exitButton.scale.set(1.6, 1.6);
	exitButton.updateHitbox();
	exitButton.antialiasing = true;
	exitButton.cameras = [uiCamera];
	exitButton.alpha = 0;
	exitButton.y = -exitButton.height - 10;
	exitButton.x = FlxG.width - exitButton.width - 10;
	add(exitButton);
	
	#if mobile
		inputMode = "touch";
	#else
		inputMode = "keyboard";
	#end
	
	enterTransition(true);
	
	buttonSelected = -1;
	highlightedButton = -1;
	description.visible = true;
	updateButtons();
}

var press:Bool = true;

function getItemAt(mouseX:Float, mouseY:Float):Int {
	if (inCredit) return -1;
	var centerX:Float = FlxG.width / 2;
	var mouseSide:String = mouseX < centerX ? "left" : "right";
	for (item in createdCredits.members) {
		if (!item.visible) continue;
		var itemSide:String = item.x < centerX ? "left" : "right";
		if (mouseSide != itemSide) continue;
		if (mouseY >= item.y && mouseY <= item.y + item.height) {
			return item.ID;
		}
	}
	return -1;
}

function update(elapsed:Float) {
	if (inputMode == "keyboard") {
		if (FlxG.mouse.justPressed) switchToTouch();
	} else {
		if (controls.LEFT_P || controls.RIGHT_P || controls.UP_P || controls.DOWN_P || controls.ACCEPT || controls.BACK) {
			switchToKeyboard();
		}
	}
	
	var mouseScreenX = FlxG.mouse.screenX;
	var mouseScreenY = FlxG.mouse.screenY;
	
	// ---------- 退出按钮交互 ----------
	var onExit = (mouseScreenX >= exitButton.x && mouseScreenX <= exitButton.x + exitButton.width &&
	              mouseScreenY >= exitButton.y && mouseScreenY <= exitButton.y + exitButton.height);
	if (onExit != exitButtonHovered) {
		exitButtonHovered = onExit;
		exitButton.color = exitButtonHovered ? FlxColor.YELLOW : FlxColor.WHITE;
	}
	if (FlxG.mouse.justReleased && exitButtonHovered) {
		FlxG.sound.play(Paths.sound('select'), 1);
		enterTransition(false);
	}
	
	// ---------- 主界面 ----------
	if (!buttonSubmenu && !inCredit) {
		var newHover:Int = -1;
		for (btn in buttons.members) {
			if (mouseScreenX >= btn.x && mouseScreenX <= btn.x + btn.width &&
				mouseScreenY >= btn.y && mouseScreenY <= btn.y + btn.height) {
				newHover = btn.ID;
				break;
			}
		}
		if (newHover != hoveredButton) {
			hoveredButton = newHover;
			if (hoveredButton != -1) {
				soulPointer.visible = true;
				soulPointer.x = buttons.members[hoveredButton].x + 8;
				if (hoveredButton != lastHoveredButton) {
					FlxG.sound.play(Paths.sound('squeak'), 1);
					lastHoveredButton = hoveredButton;
				}
			} else {
				soulPointer.visible = false;
				lastHoveredButton = -1;
			}
			updateButtons();
		}
		
		if (FlxG.mouse.justReleased && hoveredButton != -1) {
			if (inputMode == "keyboard") switchToTouch();
			selectCategory(hoveredButton);
		}
		
		if (controls.LEFT_P) {
			if (highlightedButton == -1) highlightedButton = 0;
			else highlightedButton--;
			if (highlightedButton < 0) highlightedButton = buttonOptions.length - 1;
			FlxG.sound.play(Paths.sound('squeak'), 1);
			soulPointer.visible = false;
			updateButtons();
		} else if (controls.RIGHT_P) {
			if (highlightedButton == -1) highlightedButton = 0;
			else highlightedButton++;
			if (highlightedButton > buttonOptions.length - 1) highlightedButton = 0;
			FlxG.sound.play(Paths.sound('squeak'), 1);
			soulPointer.visible = false;
			updateButtons();
		}
		
		if (controls.ACCEPT && highlightedButton != -1) {
			selectCategory(highlightedButton);
		}
		
		if (controls.BACK) {
			page.visible = false;
			enterTransition(false);
		}
		return;
	}
	
	// ---------- 底部按钮（子菜单或详情） ----------
	if (buttonSubmenu || inCredit) {
		var newHover:Int = -1;
		for (btn in buttons.members) {
			if (mouseScreenX >= btn.x && mouseScreenX <= btn.x + btn.width &&
				mouseScreenY >= btn.y && mouseScreenY <= btn.y + btn.height) {
				newHover = btn.ID;
				break;
			}
		}
		if (newHover != hoveredButton) {
			hoveredButton = newHover;
			if (hoveredButton != -1) {
				soulPointer.visible = true;
				soulPointer.x = buttons.members[hoveredButton].x + 8;
				if (hoveredButton != lastHoveredButton) {
					FlxG.sound.play(Paths.sound('squeak'), 1);
					lastHoveredButton = hoveredButton;
				}
			} else {
				soulPointer.visible = false;
				lastHoveredButton = -1;
			}
			updateButtons();
		}
		
		if (FlxG.mouse.justReleased && hoveredButton != -1) {
			if (inputMode == "keyboard") switchToTouch();
			selectCategory(hoveredButton);
		}
	}
	
	// ---------- 列表页 ----------
	if (buttonSubmenu && !inCredit) {
		// 检测列表项悬停
		var newHoverItem = getItemAt(mouseScreenX, mouseScreenY);
		if (newHoverItem != hoveredItem) {
			hoveredItem = newHoverItem;
			if (hoveredItem != -1) {
				itemPointer.visible = true;
				var item = createdCredits.members[hoveredItem];
				if (item != null) {
					itemPointer.setPosition(item.x - 393, item.y - 14);
				}
				if (hoveredItem != lastHoveredItem) {
					FlxG.sound.play(Paths.sound('squeak'), 1);
					lastHoveredItem = hoveredItem;
				}
			} else {
				itemPointer.visible = false;
				lastHoveredItem = -1;
			}
			updateItem();
		}
		
		// ---------- 更新列表页 RB 彩虹 ----------
		if (listRbActive) {
			if (listRbProgress < 1) {
				listRbProgress += elapsed / rbTransitionDuration;
				if (listRbProgress > 1) listRbProgress = 1;
				var selItem = createdCredits.members[listRbSelectedIndex];
				if (selItem != null) {
					selItem.color = FlxColor.interpolate(listRbColorStart, listRbColorTarget, listRbProgress);
				}
			} else {
				listRbColorIndex = (listRbColorIndex + 1) % rbColors.length;
				var currentItem = createdCredits.members[listRbSelectedIndex];
				if (currentItem != null) {
					listRbColorStart = currentItem.color;
				} else {
					listRbColorStart = FlxColor.WHITE;
				}
				listRbColorTarget = rbColors[listRbColorIndex];
				listRbProgress = 0;
			}
		}
		
		// 列表项点击选择
		if (FlxG.mouse.justReleased) {
			var clickedID = getItemAt(mouseScreenX, mouseScreenY);
			if (clickedID != -1) {
				if (inputMode == "keyboard") switchToTouch();
				if (itemSelected == clickedID && itemSelected != -1) {
					savedItemSelected = itemSelected;
					enterCreditDetail();
					return;
				}
				itemSelected = clickedID;
				updateItem();
				return;
			}
		}
		
		// ---------- 页码区域点击翻页 ----------
		var pageHovering = (mouseScreenX > FlxG.width * 0.7 &&
		                    mouseScreenY >= page.y && mouseScreenY <= page.y + page.height);
		if (pageHovering && page.visible) {
			page.color = FlxColor.YELLOW;
		} else {
			page.color = FlxColor.WHITE;
		}
		if (FlxG.mouse.justReleased && pageHovering && page.visible) {
			if (inputMode == "keyboard") switchToTouch();
			pageMult++;
			if (pageMult > maxPages) pageMult = 1;
			itemSelected = -1;
			hoveredItem = -1;
			itemPointer.visible = false;
			updateItem();
			page.color = FlxColor.WHITE;
		}
		
		// 键盘控制
		if (controls.UP_P) updateItem(-1);
		else if (controls.DOWN_P) updateItem(1);
		else if (controls.LEFT_P) updateRow(-1);
		else if (controls.RIGHT_P) updateRow(1);
		else if (controls.ACCEPT) {
			if (itemSelected != -1) {
				savedItemSelected = itemSelected;
				enterCreditDetail();
			}
		} else if (controls.BACK) {
			buttonSubmenu = false;
			inCredit = false;
			// 重置列表彩虹
			listRbActive = false;
			listRbSelectedIndex = -1;
			createdCredits.clear();
			itemPointer.visible = false;
			soulPointer.visible = false;
			description.visible = true;
			description.text = '* ' + randomMessage();
			description.updateHitbox();
			curPage = 0;
			pageMult = 1;
			itemSelected = -1;
			buttonSelected = -1;
			highlightedButton = -1;
			page.visible = false;
			updateButtons();
		}
		
		if (FlxG.mouse.wheel != 0) updateItem(FlxG.mouse.wheel);
	}
	
	// ---------- 详情页 ----------
	if (inCredit) {
		// 处理 RB 彩蛋颜色动画（仅名字变色，狗保持白色）
		if (rbActive) {
			if (rbProgress < 1) {
				rbProgress += elapsed / rbTransitionDuration;
				if (rbProgress > 1) rbProgress = 1;
				creditName.color = FlxColor.interpolate(rbColorStart, rbColorTarget, rbProgress);
			} else {
				rbColorIndex = (rbColorIndex + 1) % rbColors.length;
				rbColorStart = creditName.color;
				rbColorTarget = rbColors[rbColorIndex];
				rbProgress = 0;
			}
		}
		
		if (FlxG.mouse.justReleased &&
			mouseScreenX >= dog.x && mouseScreenX <= dog.x + dog.width &&
			mouseScreenY >= dog.y && mouseScreenY <= dog.y + dog.height) {
			if (inputMode == "keyboard") switchToTouch();
			persistentUpdate = false;
			persistentDraw = true;
			openSubState(new ModSubState('LinkPrompt', existingCredits[itemSelected][3]));
			return;
		}
		
		// 页码悬停效果
		var pageHovering = (mouseScreenX > FlxG.width * 0.7 &&
		                    mouseScreenY >= page.y && mouseScreenY <= page.y + page.height);
		if (pageHovering && page.visible) {
			page.color = FlxColor.YELLOW;
		} else {
			page.color = FlxColor.WHITE;
		}
		
		if (FlxG.mouse.justReleased && pageHovering && page.visible) {
			if (inputMode == "keyboard") switchToTouch();
			updatePage(1);
			page.color = FlxColor.WHITE;
		}
		
		if (controls.LEFT_P) updatePage(-1);
		else if (controls.RIGHT_P) updatePage(1);
		else if (controls.BACK) {
			inCredit = false;
			rbActive = false;
			dog.color = FlxColor.WHITE;
			creditName.color = FlxColor.WHITE;
			createdCredits.visible = true;
			if (savedItemSelected != -1) {
				itemSelected = savedItemSelected;
			} else {
				itemSelected = -1;
			}
			creditName.visible = false;
			creditDescription.visible = false;
			dog.loadGraphic(Paths.image('credits/dogs/default'));
			dog.color = FlxColor.WHITE;
			dog.antialiasing = false;
			FlxG.mouse.visible = false;
			if (existingCredits != null && existingCredits.length > 14) {
				page.visible = true;
				page.text = 'PAGE ' + pageMult;
			} else {
				page.visible = false;
			}
			updateItem();
		}
	}
}

// ========== 核心函数 ==========
function enterCreditDetail() {
	page.visible = false;
	createdCredits.visible = false;
	soulPointer.visible = false;
	itemPointer.visible = false;
	updateCredit(
		existingCredits[itemSelected][1][0],
		existingCredits[itemSelected][0],
		existingCredits[itemSelected][2],
		existingCredits[itemSelected][4],
		existingCredits[itemSelected][5],
		existingCredits[itemSelected][6]
	);
	curPage = 0;
	updatePage();
	FlxG.mouse.visible = true;
	inCredit = true;
	updateButtons();
}

function switchToTouch() {
	if (inputMode == "touch") return;
	inputMode = "touch";
	updateButtons();
	updateItem();
}

function switchToKeyboard() {
	if (inputMode == "keyboard") return;
	inputMode = "keyboard";
	hoveredButton = -1;
	hoveredItem = -1;
	soulPointer.visible = false;
	itemPointer.visible = false;
	updateButtons();
	updateItem();
}

function selectCategory(catIndex:Int) {
	// 重置列表彩虹
	listRbActive = false;
	listRbSelectedIndex = -1;
	
	inCredit = false;
	creditName.visible = false;
	creditDescription.visible = false;
	dog.loadGraphic(Paths.image('credits/dogs/default'));
	dog.color = FlxColor.WHITE;
	dog.antialiasing = false;
	createdCredits.visible = true;
	buttonSelected = catIndex;
	buttonSubmenu = true;
	createdCredits.clear();
	existingCredits = formatCredits(buttonOptions[catIndex]);
	createCredits(existingCredits);
	if (existingCredits.length > 14) {
		page.visible = true;
		page.text = 'PAGE ' + pageMult;
	} else {
		page.visible = false;
	}
	pageMult = 1;
	curPage = 0;
	itemSelected = -1;
	currentRow = 1;
	realCurrentRow = 0;
	description.visible = false;
	FlxG.mouse.visible = false;
	highlightedButton = -1;
	updateButtons();
	updateItem();
	page.color = FlxColor.WHITE;
	itemPointer.visible = false;
	hoveredItem = -1;
}

function updateButtons(?a:Int) {
	if (a != null && !buttonSubmenu) return;
	for (button in buttons.members) {
		var isSelected = (buttonSelected == button.ID);
		var isHovered = (hoveredButton == button.ID && inputMode == "touch" && !buttonSubmenu && !inCredit);
		var isHighlighted = (highlightedButton == button.ID && !buttonSubmenu && !inCredit);
		
		if (isSelected || isHovered || isHighlighted) {
			button.color = FlxColor.fromString('#FFFF40');
		} else {
			button.color = FlxColor.fromString('#FF7F27');
		}
	}
}

// ========== 核心列表更新（支持 RB 彩虹） ==========
function updateItem(?a:Int) {
    if (!buttonSubmenu || inCredit) return;
    var totalItems = createdCredits.length;
    if (totalItems == 0) return;

    if (a != null) {
        FlxG.sound.play(Paths.sound('squeak'), 1);
        if (itemSelected == -1) {
            var first = 14 * (pageMult - 1);
            itemSelected = first < totalItems ? first : 0;
        } else {
            itemSelected += a;
        }
    }

    if (itemSelected != -1) {
        if (itemSelected < 0) itemSelected = 0;
        if (itemSelected >= totalItems) itemSelected = totalItems - 1;
    }

    if (itemSelected != -1) {
        var minItems = 14 * (pageMult - 1);
        var maxItems = Math.min(14 * pageMult - 1, totalItems - 1);
        if (itemSelected < minItems || itemSelected > maxItems) {
            var newPage = Math.floor(itemSelected / 14) + 1;
            if (newPage < 1) newPage = 1;
            if (newPage > maxPages) newPage = maxPages;
            pageMult = newPage;
        }
    }

    var minItems = 14 * (pageMult - 1);
    var maxItems = Math.min(14 * pageMult - 1, totalItems - 1);

    createdCredits.forEach(function(item:UndertaleText) {
        item.visible = false;
    });
    for (i in minItems...maxItems + 1) {
        var item:UndertaleText = createdCredits.members[i];
        if (item != null) {
            item.visible = true;
            item.color = FlxColor.WHITE;
        }
    }

    // ---------- 处理选中项颜色 ----------
    if (itemSelected != -1 && itemSelected >= minItems && itemSelected <= maxItems) {
        var selItem = createdCredits.members[itemSelected];
        if (selItem != null) {
            var colorStr = existingCredits[itemSelected][2];
            // 检查是否为 RB（触发列表彩虹）
            if (colorStr != null && colorStr.toUpperCase() == "RB") {
                // 如果之前不是激活状态或者索引变了，重置彩虹状态
                if (!listRbActive || listRbSelectedIndex != itemSelected) {
                    listRbActive = true;
                    listRbSelectedIndex = itemSelected;
                    listRbColorIndex = 0;
                    listRbProgress = 0;
                    listRbColorStart = rbColors[0];
                    listRbColorTarget = rbColors[1];
                }
                // 不在此处设置颜色，由 update 循环更新
            } else {
                // 如果之前有彩虹，现在选中非RB，关闭彩虹
                if (listRbActive) {
                    listRbActive = false;
                    // 将之前选中的RB项恢复白色（如果还存在）
                    if (listRbSelectedIndex != -1 && listRbSelectedIndex < createdCredits.length) {
                        var oldItem = createdCredits.members[listRbSelectedIndex];
                        if (oldItem != null) oldItem.color = FlxColor.WHITE;
                    }
                    listRbSelectedIndex = -1;
                }
                // 设置正常颜色
                if (colorStr != null && colorStr != "" && colorStr.toUpperCase() != "RB") {
                    selItem.color = FlxColor.fromString('#' + colorStr);
                } else {
                    selItem.color = FlxColor.WHITE;
                }
            }
        }
    } else {
        // 如果没有选中项，关闭彩虹
        if (listRbActive) {
            listRbActive = false;
            if (listRbSelectedIndex != -1 && listRbSelectedIndex < createdCredits.length) {
                var oldItem = createdCredits.members[listRbSelectedIndex];
                if (oldItem != null) oldItem.color = FlxColor.WHITE;
            }
            listRbSelectedIndex = -1;
        }
    }

    // ---------- 处理悬停项颜色（不与选中RB冲突） ----------
    if (inputMode == "touch" && hoveredItem != -1 && hoveredItem >= minItems && hoveredItem <= maxItems) {
        var hoverItem = createdCredits.members[hoveredItem];
        if (hoverItem != null && hoverItem.visible) {
            // 如果悬停项正是当前选中的RB项，且彩虹激活，则跳过（由彩虹控制）
            if (hoveredItem == itemSelected && listRbActive && listRbSelectedIndex == itemSelected) {
                // 不覆盖
            } else {
                var colorStr = existingCredits[hoveredItem][2];
                if (colorStr != null && colorStr != "" && colorStr.toUpperCase() != "RB") {
                    hoverItem.color = FlxColor.fromString('#' + colorStr);
                } else {
                    hoverItem.color = FlxColor.YELLOW; // 非RB或空颜色悬停高亮
                }
            }
        }
    }

    // 页码显示
    if (totalItems > 14) {
        page.visible = true;
        page.text = 'PAGE ' + pageMult;
    } else {
        page.visible = false;
    }
}

function updateRow(?a:Int) {
    if (a == null || !buttonSubmenu || inCredit) return;
    FlxG.sound.play(Paths.sound('squeak'), 1);
    currentRow += a;
    realCurrentRow += a;
    if (itemSelected == -1) {
        var first = 14 * (pageMult - 1);
        itemSelected = first < createdCredits.length ? first : 0;
    } else {
        itemSelected += (7 * a);
    }

    if (currentRow > 2) {
        currentRow = 1;
        if (pageMult < maxPages) pageMult += 1;
    } else if (currentRow < 1) {
        currentRow = 2;
        if (pageMult > 1) pageMult -= 1;
    }

    if (createdCredits.members[itemSelected] == null) {
        var mult:Int = ((maxRows - realCurrentRow) - 1);
        if (pageMult == maxPages) {
            currentRow = 1;
            pageMult = 1;
            realCurrentRow = 0;
            itemSelected -= 7 * ((maxRows - 1) - mult);
        } else if (pageMult < 1) {
            var result:Int = 7 * mult;
            var finalIndex:Int = result - 7;
            currentRow = (maxRows % 2 == 0 ? 2 : 1);
            pageMult = maxPages;
            realCurrentRow = (maxRows - 1);
            itemSelected += finalIndex;
            itemSelected += 7;
            if (createdCredits.members[itemSelected] == null) {
                currentRow = 1;
                realCurrentRow = (maxRows - 2);
                itemSelected -= 7;
                if (itemSelected < (13 * (pageMult - 1))) {
                    pageMult -= 1;
                    currentRow = 2;
                }
            }
        }
    }
    updateItem();
}

// ========== 详情页页码更新 ==========
function updatePage(?a:Int) {
    if (!inCredit) return;
    if (existingCredits == null || itemSelected < 0 || itemSelected >= existingCredits.length) return;
    var curDescription:Array<String> = existingCredits[itemSelected][1];
    if (curDescription == null || curDescription.length == 0) {
        page.visible = false;
        return;
    }
    if (a != null) {
        curPage += a;
        if (curPage > curDescription.length - 1) curPage = curDescription.length - 1;
        else if (curPage < 0) curPage = 0;
    }
    updateCredit(
		curDescription[curPage],
		existingCredits[itemSelected][0],
		existingCredits[itemSelected][2],
		existingCredits[itemSelected][4],
		existingCredits[itemSelected][5],
		existingCredits[itemSelected][6]
	);
    if (curDescription.length > 1) {
        page.visible = true;
        page.text = 'PAGE ' + (curPage + 1);
    } else {
        page.visible = false;
    }
}

// ========== 更新狗和名称（支持 antialiasing, tint, scale, 彩虹彩蛋） ==========
function updateCredit(description:String, ?name:String, ?color:String, ?antialiasing:Bool, ?tint:Bool, ?scale:Float) {
	if (tint == null) tint = true;
	if (scale == null || scale <= 0) scale = 4.0;
	
	if (name != null) {
		creditName.visible = true;
		creditName.text = '* ' + name;
		
		if (Paths.image('credits/dogs/' + name) != null) {
			dog.loadGraphic(Paths.image('credits/dogs/' + name));
		} else {
			dog.loadGraphic(Paths.image('credits/dogs/default'));
		}
		
		dog.antialiasing = (antialiasing != null) ? antialiasing : false;
		dog.scale.set(scale, scale);
		dog.updateHitbox();
		
		var isRB:Bool = (color != null && color.toUpperCase() == "RB");
		if (isRB) {
			rbActive = true;
			rbTimer = 0;
			rbProgress = 0;
			rbColorIndex = 0;
			rbColorStart = rbColors[0];
			if (rbColors.length > 1) {
				rbColorTarget = rbColors[1];
				rbColorIndex = 1;
			} else {
				rbColorTarget = rbColors[0];
				rbColorIndex = 0;
			}
			creditName.color = rbColors[0];
			dog.color = FlxColor.WHITE;
		} else {
			rbActive = false;
			if (tint && color != null && color != "") {
				var col = FlxColor.fromString('#' + color);
				creditName.color = col;
				dog.color = col;
			} else {
				creditName.color = FlxColor.WHITE;
				dog.color = FlxColor.WHITE;
			}
		}
	}
	
	var desc:String = StringTools.replace(description, '\n', '\n  ');
	creditDescription.visible = true;
	creditDescription.text = '* ' + desc;
	creditDescription.updateHitbox();
}

// ========== 创建列表与数据加载 ==========
function createCredits(credits:Array<Dynamic>) {
	maxRows = 1;
	realCurrentRow = 0;
	pageMult = 1;
	var mult:Int = 1;
	var row:Int = 1;
	if (credits != null && credits.length > 0) {
		for (i => entry in credits) {
			var credit:UndertaleText = new UndertaleText((633 * row) + (row > 1 ? -222 : 0), (164 + (48 * mult) - 48), '* ' + entry[0], 'left', FlxG.width, 1.6);
			credit.ID = i;
			createdCredits.add(credit);
			mult += 1;
			if (mult > 7) {
				row += 1;
				maxRows += 1;
				mult = 1;
			}
			if (row > 2) row = 1;
		}
	}
	maxPages = Math.ceil((credits != null ? credits.length : 0) / 14);
	if (maxPages < 1) maxPages = 1;
}

// ========== 解析 JSON，提取所有字段 ==========
function formatCredits(category:String) {
	var credits:Array<String> = getFileList(category);
	var formattedCredits:Array<Dynamic> = [];
	if (credits != null && credits.length > 0) {
		for (i => credit in credits) {
			var raw = Assets.getText(Paths.json('credits/' + category + '/' + StringTools.replace(credit, '.json', ''))); 
			var creditData:Dynamic = Json.parse(raw);
			var antialiasing:Bool = (creditData.antialiasing != null) ? creditData.antialiasing : false;
			var tint:Bool = (creditData.tint != null) ? creditData.tint : true;
			var scale:Float = (creditData.scale != null) ? creditData.scale : 4.0;
			var foundCredit:Array<Dynamic> = [
				creditData.name,
				creditData.desc,
				creditData.color,
				creditData.link,
				antialiasing,
				tint,
				scale
			];
			formattedCredits.push(foundCredit);
		}
	}
	return formattedCredits;
}

function randomMessage() {
	var messages:Array<String> = [
		'Pick a category!',
		'Come on, come on, pick one.',
		'Thanks for playing the mod!',
		'We hope you had\nfun playing the mod!',
		'Try click on a dog to go to\nthat person\'s social media page.',
		'There\'s a lot of dogs in here.',
		'Check out the people who\nwork on the mod!',
	];
	var pickedMessage:String = messages[FlxG.random.int(0, messages.length - 1)];
	return StringTools.replace(pickedMessage, '\n', '\n  ');
}

function getFileList(category:String) {
	var folderPath:String = 'data/credits/' + category;
	var files:Array<String> = [];
	for (file in Paths.getFolderContent(folderPath)) {
		if (!files.contains(file)) files.push(file);
	}
	return files;
}

var time:Int = 0.25;
function enterTransition(e:Bool) {
	press = false;
	if (e) {
		battleBackdrop.alpha = 0;
		FlxTween.tween(battleBackdrop, {alpha: 1}, time / 2, {startDelay: time / 1.5, ease: FlxEase.cubeIn});
		stateCamera.alpha = 0;
		stateCamera.x -= 500;
		FlxTween.tween(stateCamera, {alpha: 1, x: 0}, time, {ease: FlxEase.cubeInOut, onComplete: function() {
			press = true;
		}});
		exitButton.alpha = 0;
		exitButton.y = -exitButton.height - 10;
		FlxTween.tween(exitButton, {y: 20, alpha: 1}, 0.4, {ease: FlxEase.quartOut});
	} else {
		FlxTween.tween(battleBackdrop, {alpha: 0}, time / 3, {ease: FlxEase.cubeIn});
		FlxTween.tween(stateCamera, {alpha: 0, x: -500}, time, {ease: FlxEase.cubeInOut});
		var targetX = FlxG.width + 10;
		FlxTween.tween(exitButton, {x: targetX, alpha: 0}, 0.4, {ease: FlxEase.quartOut, onComplete: function() {
			FlxG.switchState(new ModState('ModMainMenu', 'credits'));
		}});
	}
}