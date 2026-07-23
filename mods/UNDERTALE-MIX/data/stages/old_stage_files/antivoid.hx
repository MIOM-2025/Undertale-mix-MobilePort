import flixel.math.FlxRandom;
import flixel.FlxObject;
import StringedSoul;

var antivoid:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
var hall:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/antivoid/hall'));
var hallObjects:Array<Dynamic> = [];
var sizeSlider:FlxObject = new FlxObject();

var random = new FlxRandom();

//Shader variables.
var updateShader = false;
var binary = new CustomShader('binaryGlitch');

function create() {
	antivoid.screenCenter();
	add(sizeSlider);
	
	for (i in 1...30) {
		var scaler = 0.01 * i;
		var soul = new StringedSoul(random.int(360, 820), 70 - random.int(6 * (i / 3), 6 * (i / 3)), 'FF0000', random.int(1, 8), 0.5 - scaler, members.indexOf(bf) - 1);
	}
	
	for (i in 0...5) {
		var pillar = new FlxSprite(120 * i, 0).loadGraphic(Paths.image('stages/antivoid/pillar'));
		pillar.antialiasing = false;
		add(pillar);
		hallObjects.push(pillar);
	}
	
	var fpillar = new FlxSprite(700, 0).loadGraphic(Paths.image('stages/antivoid/pillar'));
	fpillar.antialiasing = false;
	add(fpillar);
	hallObjects.push(fpillar);
	
	var fapillar = new FlxSprite(830, 0).loadGraphic(Paths.image('stages/antivoid/pillar'));
	fapillar.antialiasing = false;
	add(fapillar);
	hallObjects.push(fapillar);
	
	hallObjects.push(hall);
	for (object in [antivoid, hall]) {
		insert(members.indexOf(bf) - 1, object);
	}
	
}

function postCreate() {
	dad.color = FlxColor.BLACK; bf.color = FlxColor.BLACK;
player.cpu = true;
	camGame.pixelPerfectRender = true;
	
	camFollow.setPosition(536, 100);
	camGame.snapToTarget();
	// add(hall);
}

function update() {
	if (updateShader) {
		binary.size = sizeSlider.x;
	}
	curCameraTarget = -1;
}

function onEvent(event) {
	if (event.event.name == 'String Theory Stage Transition') {
		updateShader = true;
		for (thing in hallObjects) {
			thing.shader = binary;
		}
		fapillar.shader = binary;
		FlxTween.tween(sizeSlider, {x: -300}, (Conductor.crochet / 1000) * 4, {ease: FlxEase.quadInOut, onComplete: function() {
			updateShader = false;
			dad.color = FlxColor.WHITE; bf.color = FlxColor.WHITE;
			for (thing in hallObjects) {
				thing.visible = false;
				thing.shader = null;
			}
			fapillar.shader = null;
			fapillar.visible = false;
		}});
	}
}