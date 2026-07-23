import flixel.math.FlxRandom;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import SeasonParticle;
import Math;

var particles:FlxTypedGroup<SeasonParticle> = new FlxTypedGroup();
var r = new FlxRandom();

var tobyBall:FlxSprite = new FlxSprite(108, -200).loadGraphic(Paths.image('stages/options/balltoby'), true, 23, 22);
var dither:FlxSprite = new FlxSprite(355, -80).loadGraphic(Paths.image('stages/options/dither'));
var bossSpiral:FlxSprite = new FlxSprite(30, 0);
var coverUp:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
var earthboundbgnew:FlxSprite = new FlxSprite(0, 9);
//Text stuff.
var undertaleFont:FlxBitmapFont;
var optionDisplay = [
	'controls',
	'gameplay',
	'appearance',
	'miscellaneous'
];

function create() {
	if (!FlxG.save.data.seasonParticles) {
		insert(members.indexOf(shrine) - 1, particles);
		new FlxTimer().start(0.05, function() {
			particle = new SeasonParticle(r.int(450, 700), -300, 3);
			particles.add(particle);
		}, 200);
	}
	
	coverUp.screenCenter();
	insert(members.indexOf(particles) + 1, coverUp);
	
	tobyBall.animation.add('spin', [0, 1, 2, 3], 8, true);
	tobyBall.antialiasing = false;
	
	//Text stuff.
	var index = 0;
	undertaleFont = getFont('ut-text', 'AaBbCcDdEeFf' + 'GgHhIiJjKkLl' + 'MmNnOoPpQqRr' + 'SsTtUuVvWwXx' + 'YyZz01234567' + '89!#%&$*"/@?' + '+>}{<_~=-])[' + "(,.|'^;: ");
	var title = bitmapText(-66, -248, 'OPTIONS', FlxTextAlign.CENTER, 'FFFFFF', FlxG.width, 0.8, undertaleFont);
	insert(members.indexOf(boyfriend) - 1, title);
	
	var luckyNumber = r.int(0, optionDisplay.length - 1);
	if (FlxG.save.data.devMode) {
		optionDisplay.push('debug options');
	}
	for (option in optionDisplay) {
		text = bitmapText(156, -218 + (16 * index), option.toUpperCase(), FlxTextAlign.LEFT, (luckyNumber == index ? 'FFFF00' : 'FFFFFF'), FlxG.width, 0.5, undertaleFont);
		insert(members.indexOf(boyfriend) - 1, text);
		index++;
	}
	
	for (hide in [dad, cpu.characters[1], player.characters[2], bf, coverUp, floaty]) {
		hide.visible = false;
	}
	
	var bgStuff = [
		['backgroundNew', 'backgroundnew0', 24],
		['runawaydog', 'runawaydog0', 24],
		// ['veinydih', 'waveylines0'],
		['prettypattern', 'prettypattern0', 12]
	];
	var selectedBackground = r.int(0, bgStuff.length - 1);
	earthboundbgnew.frames = Paths.getSparrowAtlas('stages/options/' + bgStuff[selectedBackground][0]);
	earthboundbgnew.animation.addByPrefix('idle', bgStuff[selectedBackground][1], bgStuff[selectedBackground][2], true);
	earthboundbgnew.animation.play('idle', true);
	insert(members.indexOf(boyfriend) - 1, earthboundbgnew);
	
	// box = new EarthboundBox();
	// add(box);
}

function postCreate() {
	camGame.pixelPerfectRender = true;
	// player.cpu = true;
	camFollow.setPosition(570, -170);
	camGame.snapToTarget();
	
	backgrounds();
	
	bossSpiral.frames = Paths.getSparrowAtlas('stages/options/bossspiral');
	bossSpiral.animation.addByPrefix('idle', 'spiral0', 24, false);
	bossSpiral.antialiasing = false;
	bossSpiral.alpha = 0;
	add(bossSpiral);
	bossSpiral.animation.finishCallback = function(name:String) {
		if (name == 'idle') {
			FlxTween.tween(bossSpiral, {alpha: 1}, 0.3, {ease: FlxEase.expoOut, onComplete: function() {
				camFollow.setPosition(earthboundbgnew.getMidpoint().x, 119);
				camGame.snapToTarget();
				camGame.zoom = 3.3;
				defaultCamZoom = 3.3;
				
				backgrounds('earthboundbgnew');
				
				bf.setPosition(0, 0);
				bf.visible = false;
				
				cpu.characters[1].setPosition(105, (downscroll ? 92 : 84));
				cpu.characters[1].visible = true;
				
				dad.visible = false;
				FlxTween.tween(bossSpiral, {alpha: 0}, 0.3, {ease: FlxEase.expoOut});
				executeEvent({name: 'HScript Call', params: ['earthboundHud', '']});
			}});
		}
	}
	
	add(tobyBall);
	add(dither);
	
	remove(shrine);
	insert(members.indexOf(boyfriend) - 1, shrine);
	
	curCameraTarget = -1;
}

function secretRoomTransition() {
	FlxTween.tween(camFollow, {y: camFollow.y + 200}, 0.5, {ease: FlxEase.quadIn});
	FlxTween.tween(dither, {y: dither.y - 100}, 0.5, {ease: FlxEase.quadIn});
	t = new FlxTimer().start(1.2, function() {
		stageParticles(false);
		backgrounds('secret');
		
		camFollow.setPosition(secret.getMidpoint().x - 10, -90);
		camGame.snapToTarget();
		
		FlxTween.tween(camFollow, {y: 100}, 0.5, {ease: FlxEase.quadIn});
		FlxTween.tween(tobyBall, {y: 108}, 0.8, {ease: FlxEase.quadIn, onComplete: function() {
			tobyBall.visible = false;
			dad.visible = true;
		}});
		
		bf.setPosition(150, 65);
		boyfriend.visible = true;
		
		dad.setPosition(95, 91);
		
		dither.visible = false;
	});
}

function shrineTransition() {
	camFollow.setPosition(shrine.getMidpoint().x, -171);
	camGame.snapToTarget();		
	camGame.zoom = 3.8;
	defaultCamZoom = 3.8;

	backgrounds('shrine');
	stageParticles(false);
	executeEvent({name: 'HScript Call', params: ['fadeInHud', '']});
	
	bf.setPosition(570, -205);
	bf.visible = true;
	remove(player.characters[1]);
	insert(members.indexOf(shrine) - 1, player.characters[1]);
	
	floaty.visible = true; spine = true;
	
	dad.setPosition(495, -178);
	dad.visible = true;
}

function shrineWipeAway() {
	var workingDog:FlxSprite = new FlxSprite(336, -251).loadGraphic(Paths.image('stages/options/tobyonthething'));
	workingDog.antialiasing = false;
	add(workingDog);
	
	FlxTween.tween(workingDog, {x: 390}, 0.26, {ease: FlxEase.linear, onComplete: function() {
		for (object in [workingDog, floaty, shrine, dad, bf]) {
			FlxTween.tween(object, {x: object.x + 350}, 1.5, {ease: FlxEase.linear});
		}
		FlxTween.tween(coverUp, {alpha: 0}, 1, {ease: FlxEase.expoOut});
		
		defaultCamZoom = 4;
		FlxTween.tween(camGame, {zoom: 4}, 0.5, {ease: FlxEase.quadOut});
	}});
}

function earthboundTransition() {
	bossSpiral.alpha = 0.5;
	bossSpiral.animation.play('idle', true);
	for (strum in playerStrums) {
		FlxTween.tween(strum, {x: strum.x - 320}, 1, {ease: FlxEase.quadInOut});
	}
	executeEvent({name: 'HScript Call', params: ['fadeAwayBullshit', 'false']});
}

function backgrounds(?show:String) {
	for (bg in [secret, shrine, earthboundbgnew]) {
		bg.visible = false;
		if (show != null) {
			if (stage.stageSprites[show] != null) {
				stage.stageSprites[show].visible = true;
			} else {
				bg.visible = true;
			}
		};
	}
}

function stageParticles(show:Bool) {
	coverUp.visible = !show;
}

function bitmapText(x:Int, y:Int, text:String, alignment:FlxTextAlign, color:String, width:Int, scale:Float, font:FlxBitmapFont) {
	var text = new FlxBitmapText(x, y, text, font);
	text.autoSize = false;
	text.alignment = alignment;
	text.fieldWidth = width;
	text.color = FlxColor.fromString('#' + color);
	text.scale.set(scale, scale);
	text.font = font;
	return text;
}

function getFont(image:String, letters:String) {
	return FlxBitmapFont.fromXNA(Assets.getBitmapData(Paths.image('fonts/' + image), true, false), letters);
}