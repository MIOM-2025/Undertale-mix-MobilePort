import overworld.DialogueBox;
import UndertaleText;

var box:DialogueBox = new DialogueBox(0, 0, this);
var flowey:FlxSprite = new FlxSprite();
var frisk:FlxSprite = new FlxSprite().loadGraphic(Paths.image('overworld/chara-d'), true, 20, 30);
function create() {
	var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/flowey/floweyspot'));
	bg.scale.set(3, 3);
	bg.updateHitbox();
	bg.screenCenter();
	bg.y -= 266;
	add(bg);
	
	add(box);
	box.setupBox();
	
	if (FlxG.sound.music != null) {
		FlxG.sound.music.stop();
		FlxG.sound.music = null;
	}

	
	frisk.setPosition(bg.x + 206.8, bg.y + 100.3);
	frisk.scale.set(3, 3);
	frisk.updateHitbox();
	frisk.animation.add('left', [3, 4, 3, 4], 0, false);
	frisk.animation.add('down', [0, 1, 0, 2], 0, false);
	frisk.animation.add('down_w', [0, 1, 0, 2], 4, true);
	frisk.animation.add('up', [7, 8, 7, 9], 0, false);
	frisk.animation.add('right', [5, 6, 5, 6], 0, false);
	frisk.animation.play('right', true, false, 0);
	frisk.animation.play('down');
	add(frisk);
	
	FlxTween.tween(frisk, {y: frisk.y}, 1, {onComplete: function() {
		box.setupDialogue([
			['*Howdy!', null, '0', 0.03],
			['*Golly,° is it° finally° time?', null, '0', 0.03],
			['*How long has it been,\nñtwo years since we last°\nñgot to play?', null, '0', 0.03],
			['*Talk about slow and steady!', null, '0', 0.03],
			['*Hah,° more like dumb and lazy...', null, '0', 0.03],
			['*Anyways, °it doesn\'t matter.', null, '0', 0.03],
			['*We\'re gonna have so much\nñfun together now!', null, '0', 0.03],
			['*I\'ll see you soon,° in-', null, '0', 0.03],
		]);
		box.textSound = false;
	}});
	
	flowey.frames = Paths.getAsepriteAtlas('stages/flowey/flowey-ov');
	flowey.animation.addByPrefix('t', 'talk0', 24, true);
	flowey.animation.addByPrefix('r', 'rise0', 24, false);
	flowey.animation.addByPrefix('s', 'stfu0', 24, false);
	flowey.animation.addByPrefix('u', 'tf0', 24, false);
	flowey.animation.play('r', true);
	flowey.scale.set(3, 3);
	flowey.updateHitbox();
	flowey.setPosition(bg.x + 204, bg.y + 600);
	add(flowey);
}

var lastBox:Bool = true;
var lastType:Bool = false;
var dialog:Int = 0;
var voice = [
	0 => 'howdy',
	1 => 'golly',
	2 => 'howlong',
	3 => 'slow',
	4 => 'morelike',
	// 5 => 'dumb',
	5 => 'anyways',
	6 => 'weregonna',
	7 => 'seeyousoon',
	// 9 => null,
	8 => 'uhoh',
];
var lol:Int = 0;
var he:Bool = false;
function update() {
FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, camZoom, 0.05);
	// FlxG.camera.zoom = 0.5;
	if (lastBox != box.active) {
		trace('changed!!!');
		if (lol == 2) {
			flowey.animation.play('u', true);
			he = true;
			FlxTween.tween(flowey, {x: flowey.x}, 0.1, {onComplete: function() {
				box.setupDialogue([
					// ['*...', null, '0', 0.03],
					['*...!°°°°°\n*H-howdy, Ch-', null, '0', 0.03],
				]);
				box.textSound = false;
			}});
		}
		// if (lol) {
			// FlxTween.tween(frisk, {x: 1020}, 2, {onComplete: function() {
				// Options.freeplayLastSong = 'true-reset';
				// Options.freeplayLastDifficulty = 'normal';
				// Options.freeplayLastVariation = '';
				
				// PlayState.loadSong('true-reset', 'normal', false, false);
				// FlxG.switchState(new PlayState());
			// }});
		// 
		lol++;
		lastBox = box.active;
	}
	if (lastType != box.typing) {
		if (!lastType) {
			if (voice.get(dialog) != null) {
				FlxG.sound.play(Paths.sound('trailer_voiceclips/' + voice.get(dialog)));
			}
			if (!he) {
				flowey.animation.play('t', true);
			}
			if (dialog == 6) {
				trace('helo');
				frisk.animation.play('down_w', true);
				FlxTween.tween(frisk, {y: frisk.y +	410}, 4, {onComplete: function() {
					frisk.animation.play('down', true);
				}});
			}
			dialog++;
			trace('typing agia');
		} else if (lastType) {
			trace('uguudug');
				if (!he) {
					flowey.animation.play('s', true);
				} else {
					var o:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
					add(o);
					box.dialogueBox.visible = false;
				var slash:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/flowerbed/slash'), true, 26, 110);
	slash.animation.add('i', [0, 1, 2, 3, 4, 5, 6], 12, false);
	slash.animation.play('i', true);
	slash.scale.set(6.5, 6.5);
	slash.updateHitbox();
	slash.screenCenter();
	add(slash);
	makeSound('snd_laz_c', 1, function() {
				FlxG.camera.shake(0.01, 0.1);
			utLogo = new FlxSprite().loadGraphic(Paths.image('title/title/ut'));
			utLogo.screenCenter();
			utLogo.alpha = 1;
				
			utLogoBent = new FlxSprite(utLogo.x, utLogo.y).loadGraphic(Paths.image('title/title/utbent-alt'));
			
			fnfPart = new FlxSprite(utLogo.x - 2, utLogo.y - 47).loadGraphic(Paths.image('title/title/fnfpart'));
			
			mixPart = new FlxSprite(utLogo.x + 9, utLogo.y + 6).loadGraphic(Paths.image('title/title/mixpart'));
			
			for (part in [utLogo, utLogoBent, fnfPart, mixPart]) {
				part.visible = false;
				part.scale.set(6, 6);
				part.updateHitbox();
				part.screenCenter();
				add(part);
			}
			fnfPart.setPosition(utLogo.x - (2 * 6), utLogo.y - (47 * 6));
			mixPart.setPosition(utLogo.x + (9 * 6), utLogo.y + (6 * 6));
			utLogoBent.setPosition(utLogo.x, utLogo.y);
			titleEvent();
		makeSound('snd_damage_c', 1, function() {

		});
	});
				}
		}
		lastType = box.typing;
	}
}

var camZoom:Float = 1;
// function update() {

// }

var fnfPart:FlxSprite;
var mixPart:FlxSprite;
var utLogo:FlxSprite;
var utLogoBent:FlxSprite;
function makeSound(soundFile:String, soundPitch:Float, ?onFinished:Void->Void) {
	var sound:FlxSound = FlxG.sound.load(Paths.sound(soundFile), Options.volumeSFX, false, null, true, false, null, (onFinished != null ? onFinished : null));
	sound.pitch = soundPitch;
	sound.play();
}

var introStep:Int = 0;
function titleEvent() {
	switch(introStep) {
		case 0:
			introSound = FlxG.sound.load(Paths.sound('intro'), 1, false, null, false, true, null, function() {
				titleEvent();
			});
			utLogo.visible = true;
		case 1:
			canSkip = false;
		
			makeSound('intro', 1.3);
			makeSound('hey', 1);
			utLogo.visible = false;
			utLogoBent.visible = true;
			
			FlxG.camera.zoom += 0.02;
			fnfPart.visible = true;
			var timer:FlxTimer = new FlxTimer().start(0.3, function() {
				titleEvent();
			});
		case 2:
			FlxG.camera.zoom += 0.02;
			makeSound('intro', 1.6, function() {
				// promptText.visible = true;
			});
			mixPart.visible = true;
			introFinished = true;
			FlxTween.tween(fnfPart, {x: fnfPart.x}, 1, {onComplete: function() {
				var blak:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blak.screenCenter();
				blak.alpha = 0;
				add(blak);
				var text:UndertaleText = new UndertaleText(0, 0, 'OUT NOW!', 'left', FlxG.width, 9, 'FFFF00', 'undertale-pixel');
				text.autoSize = true;
		text.updateHitbox();
		text.screenCenter();
		text.visible = false;
		add(text);
				FlxTween.tween(blak, {x: blak.x}, 1, {onComplete: function() {
					blak.alpha = 0.4;
					text.angle = 13;
					text.visible = true;
					makeSound('mus_mode', 1);
				}});
			}});
	}
	introStep++;
}