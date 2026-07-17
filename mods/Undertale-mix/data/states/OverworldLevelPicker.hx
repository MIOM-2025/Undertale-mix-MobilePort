import UndertaleText;

import funkin.editors.ui.UIState;

var levelButtons:Array<UndertaleText> = [];
var overworldList:Array<String> = [
	'pre_truereset',
	'pre_vents',
];
var cur:Int = 0;
function create() {
	var title:UndertaleText = new UndertaleText(100, 100, 'LEVEL:', 'left', FlxG.width, 3, 'FFFFFF', 'undertale-pixel');
	title.autoSize = true;
	title.updateHitbox();
	add(title);

	var index:Int = 0;
	for (level in overworldList) {
		var level:UndertaleText = new UndertaleText(title.x + title.width / 1.8, (title.y + title.height) + (55 * index), level, 'left', FlxG.width, 3, 'FFFFFF', 'undertale-pixel');
		level.autoSize = true;
		level.updateHitbox();
		add(level);
		level.ID = index;
		levelButtons.push(level);
		index++;
	}
	
	selection();
}

function selection(?v:Int) {
	if (v != null) {
		cur += v;
		if (cur > overworldList.length - 1) {
			cur = 0;
		} else if (cur < 0) {
			cur = overworldList.length - 1;
		}
	}
	for (button in levelButtons) {
		button.color = button.ID == cur ? FlxColor.YELLOW : FlxColor.WHITE;
	}
}

function update(elapsed:Float) {
	if (controls.BACK) {
		FlxG.switchState(new UIState(true, 'MasterDebugMenu'));
	}
	
	if (controls.UP_P) {
		selection(1);
	} else if (controls.DOWN_P) {
		selection(-1);
	} else if (controls.ACCEPT) {
		FlxG.switchState(new ModState(overworldList[cur], true));
	}
}