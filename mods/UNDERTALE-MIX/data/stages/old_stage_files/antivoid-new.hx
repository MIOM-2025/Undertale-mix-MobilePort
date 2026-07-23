import flixel.FlxObject;
import StringedSoul;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;
import StringTools;
import flixel.tweens.FlxTweenType;
import UndertaleText;

import funkin.backend.utils.DiscordUtil;
import Sys;

var antivoid:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
var voidStatic:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/antivoid/static'), true, 340, 220);
var voidStaticAgain:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/antivoid/static'), true, 340, 220);
var darkDither:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/antivoid/blackdither'));
var transitionAnimation:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/antivoid/alltogethernow'));

var picoSoul:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/antivoid/picosoul'), true, 16, 16);
var masks:Array<FlxSprite> = [];
var strings:Array<FlxSprite> = [];

var sizeSlider:FlxObject = new FlxObject();
var binary = new CustomShader('binaryGlitch');
var bgCameraBinary = new CustomShader('barrel');
var mpeg = new CustomShader('mpegArtifacting');
var barrel = new CustomShader('barrel');
var r:FlxRandom = new FlxRandom();
var foundFrames:Array<String> = [];
var modsCamera:FlxCamera = new FlxCamera();
var realbf:Character;
public var error:Character;

var colors:Array<String> = [
	'FF0000',
	'003CFF',
	'00C000',
	'D535D9',
	'FFFF00',
	'FCA600',
	'42FCFF',
	'FFFFFF',
];

function onStageXMLParsed() {

	add(antivoid);
	
	// add(voidStatic);


	add(darkDither);
	
	if (!Options.lowMemoryMode) {
		for (i in 0...100) {
			var stageOrder:Int = 100 - i;
			var scaler:Float = 0.006 * stageOrder;
			var soulAlpha:Float = (stageOrder / 100) * 1;
			var scroll:Float = 0.4 - (0.01 * stageOrder);
			/*
			trace(0.5 - scaler);
			var soul:StringedSoul = new StringedSoul(r.int(300, 600), -20 + r.int(6 * (i / 7), 6 * (i / 7)), 0.5 - scaler);
			soul.alpha = 1 - scaler * 2;
			add(soul);
			*/
			var soulX:Float = 400;
			if ((0.5 - scaler) > 0) {
					var monsterSoul:Bool = r.bool(20);
					var string:FlxSprite = new FlxSprite(r.int(soulX, soulX + 500), -30 + r.int(5 * (stageOrder / 2.5), 5 * (stageOrder / 2.5))).loadGraphic(Assets.getBitmapData(Paths.image('stages/antivoid/souls/attached/' + (monsterSoul ? 'monstersoul' : 'string') + r.int(0, 7)), false, false));
					string.scale.set(0.5 - scaler, 0.5 - scaler);
					string.updateHitbox();
					if (!monsterSoul) {
						string.replaceColor(FlxColor.WHITE, FlxColor.fromString('#' + colors[r.int(0, colors.length - 1)]));
					}
					string.scrollFactor.set(scroll, 1);
					strings.push(string);
					add(string);
					
					var mask:FlxSprite = new FlxSprite(string.x, string.y).loadGraphic(Paths.image('stages/antivoid/souls/whitemask' + (monsterSoul ? '' : '-soul')));
					mask.scale.set(string.scale.x, string.scale.y);
					mask.updateHitbox();
					mask.alpha = soulAlpha;
					// mask.color = FlxColor.BLACK;
					mask.scrollFactor.set(string.scrollFactor.x, string.scrollFactor.y);
					masks.push(mask);
					add(mask);
				}
		}
	}
}

var playerUsername:String;
function create() {
error = strumLines.members[2].characters[0];
	foundFrames = Paths.getFolderContent('images/frame/shots', false, -1, false);
	var actualImages:Array<String> = [];
	for (file in foundFrames) {
		if (StringTools.endsWith(file, '.png')) {
			actualImages.push(StringTools.replace(file, '.png', ''));
		}
	}
	foundFrames = actualImages;
	// for (frame in foundFrames) {
	// }
	
	playerUsername = (DiscordUtil.user != null ? DiscordUtil.user.username.toUpperCase() : Sys.getEnv('USERNAME'));

	
	var image:FlxSprite = new FlxSprite();
	image.animation.addByIndices('i', 'frames', [0, 1], '', 8, true);
	image.animation.play('i', true);
	var scale:Float = r.float(0.05, 0.09);
	image.scale.set(scale, scale);
	image.cameras = [modsCamera];
	image.updateHitbox();
	image.screenCenter();
	add(image);

	add(sizeSlider);
	camGame.targetOffset.y = 3;
}

var black:Float = (0.5 / 1) * 255;
var blackColor:FlxColor;
var bubbleTimer:FlxTimer;
function postCreate() {
	blackColor = FlxColor.fromRGB(black, black, black);

	bf.color = FlxColor.BLACK;
	dad.color = FlxColor.BLACK;
	strumLines.members[3].characters[0].color = FlxColor.BLACK;
	strumLines.members[2].characters[0].visible = false;

	
	// makeBubble('carol');
	camGame.bgColor = FlxColor.TRANSPARENT;
	
	bgCameraBinary.dis1 = -0.6;
	bgCameraBinary.dis2 = -0.2;
	FlxG.cameras.insert(modsCamera, 0, false);
	modsCamera.bgColor = FlxColor.TRANSPARENT;
	modsCamera.antialiasing = false;
	modsCamera.addShader(bgCameraBinary);
	modsCamera.addShader(binary);
	// modsCamera.zoom = 0.5;q
	
	var pos:Int = 0;
	var row:Int = 0;
	if (!Options.lowMemoryMode) {
		for (frame in foundFrames) {
			var image:FlxSprite = new FlxSprite();
			image.frames = Paths.getAsepriteAtlas('frame/shots/' + frame);
			image.animation.addByIndices('i', 'frame', [0, 1], '', 8, true);
			image.animation.play('i', true);
			image.animation.curAnim.timeScale = r.float(0.2, 0.4);
			image.velocity.x = r.int(1, 3);
			
			var scale:Float = r.float(0.2, 0.3);
			image.scale.set(scale, scale);
			var black:Int = r.int(188, 255);
			image.color = FlxColor.fromRGB(black, black, black, 1);
			image.cameras = [modsCamera];
			image.updateHitbox();
			image.setPosition(-150 + (180 * pos), (100 + (110 * row)) + r.int(-10, 10));
			if (pos > 5) {
				pos = 0;
				row++;
			}
			pos++;
		
			var frame:FlxSprite = new FlxSprite().loadGraphic(Paths.image('frame/frame'));
			frame.frames = Paths.getAsepriteAtlas('frame/frame');
			frame.animation.addByPrefix('i', 'frame', 8, true);
			frame.animation.play('i', true);
			frame.animation.curAnim.timeScale = r.float(0.2, 0.4);
			frame.scale.set(scale + 0.2, scale + 0.2);
			frame.setPosition(-150 + (180 * pos), (100 + (110 * row)) + r.int(-10, 10));
			frame.updateHitbox();
			// frame.setPosition(image.getGraphicMidpoint().x, image.getGraphicMidpoint().y);
			frame.cameras = [modsCamera];
			add(frame);
			
			add(image);
			
			// trace(image.x);q
		}
	}
	modsCamera.visible = false;
	
	// var char:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/antivoid/charposition'));
	// char.antialiasing = false;
	// char.screenCenter();
	// char.setPosition(char.x + 234, char.y - 228);
	// add(char);
	
	transitionAnimation.frames = Paths.getAsepriteAtlas('stages/antivoid/alltogethernow');
	transitionAnimation.animation.addByPrefix('wholeanim', 'startup', 8, false);
	transitionAnimation.animation.addByPrefix('pull', 'pull0', 8, false);
	transitionAnimation.animation.addByPrefix('pullhard', 'pullhard0', 8, false);
	transitionAnimation.animation.addByPrefix('kill', 'kill0', 8, false);
	transitionAnimation.antialiasing = false;
	add(transitionAnimation);
	transitionAnimation.screenCenter();
	transitionAnimation.setPosition(transitionAnimation.x + 225, transitionAnimation.y - 239.5);
	transitionAnimation.visible = false;
	
	realbf = strumLines.members[3].characters[0];
	error = strumLines.members[2].characters[0];
	// camHUD.visible = false;
	// strumLines.members[3].cpu = true;
}

function onSongStart() {
	// if (strumLines.members[3].cpu) {
		// camHUD.visible = false;
	// }
	camGame.snapToTarget();
}

var updateShader:Bool = false;
var oppZoom:Bool = false;
function update(elapsed:Float) {
	
	if (updateShader) {
		binary.size = sizeSlider.x;
	}
	// transitionAnimatiwron.animation.play('wholeanim', true);
	// if (oppZoom) {
		// camGame.setScale(sizeSlider.y, sizeSlider.y);
	// }
}

function postUpdate(elapsed:Float) {
			// bf.alpha = 0;
	// dad.alpha = 0;
	// strumLines.members[3].characters[0].alpha = 0;
	// strumLines.members[2].characters[0].alpha = 0;
	// camGame.zoom = 1;
}

function errorAppear() {
	strumLines.members[2].characters[0].visible = true;
}

function bubbleSpawn() {
	bubbleTimer = new FlxTimer().start(r.float(1, 3), function() {
		makeBubble(foundFrames[r.int(0, foundFrames.length - 1)]);
		bubbleSpawn();
	});
}

function killMinions() {
	bf.visible = false;
	dad.visible = false;
}


function onEvent(e) {
	if (e.event.name == 'String Theory Stage Transition') {
		updateShader = true;
		for (sprite in stage.stageSprites) {
			sprite.shader = binary;
		}
		FlxTween.tween(sizeSlider, {x: -300}, (Conductor.crochet / 1000) * 2, {ease: FlxEase.quadInOut, onComplete: function() {
			updateShader = false;
			hall.visible = false;
			bf.color = FlxColor.WHITE;
			dad.color = FlxColor.WHITE;
			strumLines.members[3].characters[0].color = FlxColor.WHITE;
			for (sprite in stage.stageSprites) {
				sprite.visible = false;
			}

		}});
	// } else if (e.event.name == 'Change Character') {
	}
}

function recolorCharacters() {
	strumLines.members[3].characters[0].color = blackColor;
	strumLines.members[2].characters[0].color = blackColor;
}

function stageDangerous() {
	FlxTween.tween(camHUD, {alpha: 1}, Conductor.crochet / 1000);

	transitionAnimation.visible = false;
	barrel.dis1 = -0.6;
	barrel.dis2 = -0.2;
	voidStatic.animation.add('i', [0, 1, 2, 3], 16, true);
	voidStatic.animation.play('i', true);
	voidStatic.screenCenter();
	voidStatic.alpha = 0;
	voidStatic.setPosition(voidStatic.x + 400, voidStatic.y - 100);
	voidStatic.alpha = 0.5;
	voidStatic.antialiasing = false;
	voidStatic.scrollFactor.set(0, 0);
	voidStatic.cameras = [modsCamera];
	
	voidStatic.alpha = 0.5;
	voidStatic.scale.set(4, 4);
	voidStatic.updateHitbox();
	voidStatic.screenCenter();
	voidStatic.cameras = [modsCamera];

	voidStatic.shader = barrel;
	
	antivoid.alpha = 1;
	
	darkDither.screenCenter();
	darkDither.scrollFactor.set(0, 0);
	
	FlxTween.tween(voidStatic, {alpha: 1}, 2, {ease: FlxEase.cubeInOut});
	FlxTween.tween(darkDither, {alpha: 1}, 2, {ease: FlxEase.cubeInOut});
	FlxTween.tween(antivoid, {alpha: 0}, 2, {ease: FlxEase.cubeInOut});
	for (mask in masks) {
		FlxTween.color(mask, 2, mask.color, FlxColor.fromRGB(0, 0, 0, (mask.alpha / 1) * 255));
	}
	realbf = strumLines.members[3].characters[0];
	error = strumLines.members[2].characters[0];
	
	FlxTween.color(strumLines.members[3].characters[0], 2, strumLines.members[3].characters[0].color, blackColor);
	FlxTween.color(strumLines.members[2].characters[0], 2, strumLines.members[2].characters[0].color, blackColor);
	error.setPosition(error.x + 9, error.y + 12);
	realbf.y += 1;
	
	modsCamera.visible = true;
	updateShader = true;
	sizeSlider.x = 600;
	FlxTween.tween(sizeSlider, {x: 0}, 2, {ease: FlxEase.cubeInOut, onComplete: function() {
		updateShader = false;
		modsCamera.removeShader(binary);
	}});
}

function startAnimation() {
	bf.alpha = 0;
	dad.alpha = 0;
	error.alpha = 0;
	transitionAnimation.visible = true;
	transitionAnimation.animation.play('wholeanim', true);
	FlxTween.tween(camHUD, {alpha: 0}, Conductor.crochet / 1000);
}

function tAnim(a:String) {
	transitionAnimation.animation.play(a, true);
}

var gameOver:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameover/gameover'));
var evilGlow:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/antivoid/redglow'));
var evilText:UndertaleText;
var messages:Array<String> = [
	'* won\'t you join them?',
	'* what\'s wrong?',
	'* don\'t wander where you don\'t belong',
	'* don\'t worry, it\'s almost over',
	'* it\'s a whole different world out there',
	'* thank you for showing me more',
	'* it feels so small now',
	'* you\'re nothing in the grand scheme of things',
	'* just another anomaly',
	'* you should\'ve stayed in your lane.',
	'* HAHAHAHAHAHAHAHAHAHAHA',
	'* YOU THINK YOU CAN JUST RUN OFF TO ANOTHER GAME, ' + playerUsername + '?',
	'* YOU BROUGHT ME HERE.',
];
function stageHanger() {
	modsCamera.visible = false;
	// camGame.bgColor = FlxColor.fromRGB(255, 255, 255, (0.2 / 1) * 255);
	remove(darkDither);
	voidStatic.alpha = 0.1;
	voidStatic.cameras = [camGame];
	voidStatic.scale.set(1, 1);
	voidStatic.updateHitbox();
	voidStatic.screenCenter();
	remove(voidStatic);
	oppZoom = true;
	camGame.zoom = 10;
	
	executeEvent({name: 'Change Character', params: [2, 'error-front']});
	executeEvent({name: 'Glitch Shader', params: [false, 0, false, 0, true]});
	// executeEvent({name: 'Change Character', params: [3, 'bf-ut']});
	executeEvent({name: 'Change Character', params: [3, 'bf-hanging']});
	realbf = strumLines.members[3].characters[0];
	error = strumLines.members[2].characters[0];
	error.setPosition(realbf.x - 20, realbf.y - 100);
	
	realbf.setPosition(realbf.x - 180, realbf.y - 300);

	gameOver.scale.set(0.4, 0.4);
	gameOver.updateHitbox();
	gameOver.setPosition(error.x - 16, error.y - 40);
	gameOver.shader = binary;
	add(gameOver);
	remove(gameOver);
	insert(members.indexOf(error) - 1, gameOver);
	gameOver.alpha = 0;
	
	insert(0, voidStatic);
	
	// evilGlow.setPosition(gameOver.getGraphicMidpoint().x, gameOver.getGraphicMidpoint().y);
	evilGlow.setPosition(gameOver.x - 70, gameOver.y - 50);
	evilGlow.alpha = 0;
	evilGlow.blend = 0;
	evilGlow.scale.set(0.6, 0.6);
	evilGlow.updateHitbox();
	add(evilGlow);
	
	gameOver.offset.set(150, 76);
	evilGlow.offset.set(gameOver.offset.x, gameOver.offset.y);
	
	
	for (mask in masks) {
		mask.visible = false;
	}
	
	for (string in strings) {
		string.visible = false;
	}
	
	var bigBox:FlxSprite = new FlxSprite(error.getGraphicMidpoint().x - 200, error.y + 68).loadGraphic(Paths.image('stages/antivoid/bigbox'));
	bigBox.antialiasing = false;
	insert(members.indexOf(error) - 1, bigBox);
	
	evilText = new UndertaleText(bigBox.x, bigBox.y + 10, '*hello', 'left', bigBox.width, 1, 'FFFFFF', 'undertale-pixel');
	evilText.alpha = 0.1;
	evilText.shader = binary;
	insert(members.indexOf(bigBox) + 1, evilText);
			var pM:String = messages[3];
			evilText.text = pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM;
			// binary.size = r.float(0.1, 0.4);
	// trace(camGame.zoom);
}

var menacing:Bool = false;
function menacingStuff() {
	menacing = true;
	var pointInSong:Float = (inst.length - Conductor.songPosition) - 1000;
	FlxTween.tween(evilGlow, {alpha: 1}, pointInSong / 1000);
	FlxTween.tween(gameOver, {alpha: 1}, pointInSong / 1000);
}

function onCameraMove(e) {
	if (oppZoom) {
		if (e.strumLine.opponentSide) {
			camGame.targetOffset.y = -24;
			// FlxTween.tween(camGame, {zoom: 4.8}, (Conductor.crochet / 1000), {onComplete: function() {
				defaultCamZoom = 4.8;
			// }});
		} else {
			camGame.targetOffset.y = -60;
			// FlxTween.tween(camGame, {zoom: 4.4}, (Conductor.crochet / 1000), {onComplete: function() {
				defaultCamZoom = 4.4;
			// }});
		}
	}
}

function beatHit(curBeat:Int) {
	if (oppZoom) {
		if (curBeat % (menacing ? 1 : 2) == 0) {
				var pM:String = messages[r.int(0, messages.length - 1)];
			evilText.text = pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM;
			binary.size = r.float(0.1, 0.4);
		}
		// FlxTween.color(voidStatic, (Conductor.crochet / 1000), voidStatic.color, FlxColor.fromRGB(255, 0, 0, ((voidStatic.alpha + 0.1) / 1) * 255), {onComplete: function() {
			
			// camGame.scale.set(1.1, 1.1);
			FlxG.camera.zoom += 0.1;
		// sizeSlider.y = 2;
		// FlxTween.tween(sizeSlider, {y: 1}, (Conductor.crochet / 1000));
			// FlxTween.tween(camGame.scale, {x: 1, y: 1}, (Conductor.crochet / 1000));
			if (menacing) {
				FlxTween.color(voidStatic, (Conductor.crochet / 1000), FlxColor.fromRGB(255, 0, 0, ((voidStatic.alpha)  / 1) * 255), FlxColor.fromRGB(255, 255, 255, (voidStatic.alpha / 1) * 255));
				voidStatic.color = FlxColor.RED;
				FlxG.camera.zoom += 0.2;
			}
		// }});
	}
}

function endingStuff() {
	oppZoom = false;
	defaultCamZoom -= 0.4;
			var pM:String = messages[2];
			evilText.text = pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM + pM;
			binary.size = r.float(0.1, 0.4);
}

function killAll() {
	camGame.visible = false;
	camHUD.visible = false;
}

function makeBubble(image:String) {
	var bubble:FlxSprite = new FlxSprite();
	bubble.frames = Paths.getAsepriteAtlas('frame/shots/' + image);
	bubble.animation.addByIndices('i', 'frame', [0, 1], '', 8, true);
	bubble.animation.play('i', true);
	bubble.animation.curAnim.timeScale = r.float(0.1, 0.5);
	bubble.antialiasing = false;
	var scale:Float = r.float(0.05, 0.09);
	bubble.scale.set(scale, scale);
	bubble.origin.set(-10, -10);
	bubble.scrollFactor.set((scale / 0.1) * 1, (scale / 0.1) * 1);
	var shader = CustomShader('binaryGlitch');
	bubble.shader = shader;
	FlxTween.num(30, 0, 1, {}, function(value:Float) {
		bubble.shader.size = value;
	});
	bubble.velocity.x = 10 * ((scale / 0.1) * 1);
	var timer:FlxTimer = new FlxTimer().start(3, function() {
		FlxTween.tween(bubble.scale, {x: 0, y: 0}, {ease: FlxEase.cubeInOut});
	});
	var black:Int = r.int(70, 120);
	bubble.color = FlxColor.fromRGB(black, black, black, 1);
	bubble.screenCenter();
	bubble.setPosition((bubble.x + 200) + r.int(150, 300), (bubble.y + 350) - r.int(235, 280));
	add(bubble);
	remove(bubble);
	insert(members.indexOf(strumLines.members[3].characters[0]) - 1, bubble);
}