import flixel.math.FlxRandom;
var colors = [
	"FF4040",
	"FFC14A",
	"FFFF80",
	"9CFF79",
	"4040FF",
	"C000C0"
];
var disabledColors = [
	"A2A2A2",
	"D9D9D9",
	"C8C8C8",
	"F0F0F0"
];
var tiles:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
var random:FlxRandom = new FlxRandom();
function postCreate() {
	camGame.pixelPerfectRender = true;
	add(tiles);
	
	var row = 0;
	var index = 0;
	for (i in 0...48) {
		var tile = new FlxSprite(480 + (20 * index), -220 + (20 * row)).loadGraphic(Paths.image('stages/snowdintilepuzzle/tile_s'));
		index += 1;
		if (index > 7) {
			row += 1;
			index = 0;
		}
		tiles.add(tile);
	}
}

function beatHit(curBeat:Int) {
	if (curBeat % 2 == 0) {
		tiles.forEach(function(tile:FlxSprite) {
			var color = colors[random.int(0, colors.length - 1)];
			tile.color = FlxColor.fromString('#' + color);
			FlxTween.color(tile, Conductor.crochet / 1000, tile.color, FlxColor.fromString('#' + disabledColors[random.int(0, disabledColors.length - 1)]), {ease: FlxEase.cubeIn});
		});
	}
}

function postUpdate() {
	curCameraTarget = -1;
	camFollow.setPosition(559, -180);
}