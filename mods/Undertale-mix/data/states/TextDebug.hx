import UndertaleText;
import funkin.editors.ui.UIState;

var fonts = [
	'undertale' => 'AaBbCcDdEeFf\nGgHhIiJjKkLl\nMmNnOoPpQqRr\nSsTtUuVvWwXx\nYyZz01234567\n89!#%&$*"/@?\n+>}{<_~=-])[\n(,.|\'^;: \"',
	'undertale-pixel' => 'AaBbCcDdEeFf\nGgHhIiJjKkLl\nMmNnOoPpQqRr\nSsTtUuVvWwXx\nYyZz01234567\n89!#%&$*"/@?\n+>}{<_~=-])[\n(,.|\'^;: ñ¬°\",',
	'undertale-outline' => "AGMSY8+(ag\nmsy9>,BHNT\nZ!}.bhntz#\n{ñCIOU0%<c\niou1&-^DJP\nV2$~;djpv3\n*=:EKQW4\"\nekqw5/]FL\nRX6@)flrx7\n?[",
	'crypt' => "abcdefgh\nijklmnop\nqrstuvwx\nyz123456\n789.,:;'\"\n()!?+-/\n=0%[] ",
	'dotumche' => 'AaBbCcDdEeFf\nGgHhIiJjKkLl\nMmNnOoPpQqRr\nSsTtUuVvWwXx\nYyZz01234567\n89!#%&$*"/@?\n+>}{<_~=-])[\n(,.|^;:\' ',
	'wonder' => "abcdef\nghijkl\nmnopqr\nstuvwx\nyz1234\n567890\n'()<> ",
	'earthbound' => "ABCDEFGH\nIJKLMNOP\nQRSTUVWX\nYZabcdef\nghijklmn\nopqrstuv\nwxyz!?. \n*,",
];

var sizes = [
	'undertale' => [2, 15, 1.2],
	'undertale-outline' => [3, 17, 1.1],
	'undertale-pixel' => [3, 11, 1.1],
	'crypt' => [10, 12, 1.1],
	'dotumche' => [3, 11, 1.1],
	'wonder' => [7, 12, 1.1],
	'earthbound' => [5, 20, 1.1],
];

var selected:Int = 0;
var options = ['undertale', 'undertale-pixel', 'undertale-outline', 'crypt', 'dotumche', 'wonder', 'earthbound'];
var objects = [];
var top:FunkinText = new FunkinText(50, 50, FlxG.width, 'current font: ', 30);
function create() {
	var id:Int = 0;
	for (font in options) {
		var utText:UndertaleText = new UndertaleText(100, 100, fonts.get(font), 'left', FlxG.width, sizes.get(font)[0], 'FFFFFF', font);
		utText.autoSize = true;
		utText.updateHitbox();
		add(utText);
		
		var realText:FunkinText = new FunkinText(utText.x + utText.width, 100, FlxG.width, fonts.get(font), 16);
		realText.autoSize = true;
		realText.setGraphicSize(utText.width * sizes.get(font)[1], utText.height * sizes.get(font)[2]);
		realText.updateHitbox();
		add(realText);
		
		objects.push([id, utText, realText]);
		id++;
	}
	
	add(top);
	display();
}

function update() {
	if (FlxG.keys.justPressed.LEFT) {
		display(-1);
	} else if (FlxG.keys.justPressed.RIGHT) {
		display(1);
	} else if (FlxG.keys.justPressed.ESCAPE) {
				// case 'freeplay song editor':
					FlxG.switchState(new UIState(true, 'MasterDebugMenu'));
	}
}

function display(?v:Int) {
	if (v != null) {
		selected += v;
		if (selected > objects.length - 1) {
			selected = 0;
		} else if (selected < 0) {
			selected = objects.length - 1;
		}
	}
	top.text = 'current font: ' + options[selected];
	for (object in objects) {
		if (object[0] == selected) {
			object[1].visible = object[2].visible = true;
		} else {
			object[1].visible = object[2].visible = false;
		}
	}
}