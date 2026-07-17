import flixel.FlxObject;
import StringTools;
import UndertaleText;

var antivoid:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
var soulStrings:Array<FlxSprite> = [];
var soulMasks:Array<FlxSprite> = [];
var mainStage:Array<FlxSprite> = [];
var bgFrames:Array<FlxSprite> = [];
var allTogetherNow:FlxSprite = new FlxSprite();
var darkGradient:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/antivoid/blackdither'));
var usableFrames:Array<String> = [];
var bgCamera:FlxCamera = new FlxCamera();
var bgStatic:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/antivoid/static'), true, 340, 220);
var splitter:CustomShader = new CustomShader('textureSplitter');
var bigBoxText:UndertaleText;
var gfBodyHanging:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/antivoid/gfbodyhanging'));
var gfHeadHanging:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/antivoid/gfheadhanging'));
var picoHanging:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/antivoid/picohanging'));
function onStageXMLParsed() {
	antivoid.scrollFactor.set(0, 0);
	insert(0, antivoid);
	
	if (!Options.lowMemoryMode) {
		for (i in 0...100) {
			var order:Int = 100 - i;
			var scale:Float = 0.006 * order;
			var alpha:Float = (order / 100) * 1;
			var scroll:Float = 0.4 - (0.01 * order);
			
			var x:Int = 400;
			if ((0.5 - scale) > 0) {
				var isMonster:Bool = FlxG.random.bool(50);
				var string:FlxSprite = new FlxSprite(FlxG.random.int(x, x + 500), -30 + FlxG.random.int(5 * (order / 2.5), 5 * (order / 2.5))).loadGraphic(Assets.getBitmapData(Paths.image('stages/antivoid/souls/attached/' + (isMonster ? 'monstersoul' : 'string') + FlxG.random.int(0, 7)), false, false));
	
				string.scale.set(0.5 - scale, 0.5 - scale);
				string.updateHitbox();
				if (!isMonster) {
					string.replaceColor(FlxColor.WHITE, FlxG.random.color());
				}
				string.scrollFactor.set(scroll, 1);
				soulStrings.push(string);
				add(string);
				
				var mask:FlxSprite = new FlxSprite(string.x, string.y).loadGraphic(Paths.image('stages/antivoid/souls/whitemask' + (isMonster ? '' : '-soul')));
				mask.scale.set(string.scale.x, string.scale.y);
				mask.updateHitbox();
				mask.alpha = alpha;
				mask.scrollFactor.set(string.scrollFactor.x, string.scrollFactor.y);
				soulMasks.push(mask);
				add(mask);
			}
		}
		
		
		
		var foundFrames:Array<String> = Paths.getFolderContent('images/frame/shots', false, -1, false);
		var index:Int = 0;
		for (frame in foundFrames) {
			if (StringTools.endsWith(frame, '.png')) {
				usableFrames.push(StringTools.replace(frame, '.png', ''));
			}
		}
		
		var position:Int = 0;
		var row:Int = 0;
		for (frame in usableFrames) {
			var frameSprite:FlxSprite = new FlxSprite();
			frameSprite.frames = Paths.getAsepriteAtlas('frame/shots/' + frame);
			frameSprite.animation.addByIndices('i', 'frame', [0, 1], '', 8, true);
			frameSprite.animation.play('i', true);
			frameSprite.animation.curAnim.timeScale = FlxG.random.float(0.2, 0.4);
			var scale:Float = FlxG.random.float(0.08, 0.12);
			frameSprite.scale.set(scale, scale);
			frameSprite.updateHitbox();
			frameSprite.scrollFactor.set(0, 0);
			insert(members.indexOf(antivoid) + 1, frameSprite);
			frameSprite.setPosition(340 + (FlxG.random.int(60, 80) * position), frameSprite.y + 250 + (FlxG.random.int(50, 55) * row));
			frameSprite.cameras = [bgCamera];
			bgFrames.push(frameSprite);
			if (position > 5) {
				position = 0;
				row++;
			}
			position++;
			
			var blank:FlxSprite = new FlxSprite(frameSprite.x + FlxG.random.int(-5, 5), frameSprite.y + FlxG.random.int(-5, 5));
			blank.frames = Paths.getAsepriteAtlas('frame/frame');
			blank.animation.addByIndices('i', 'frame', [0, 1, 2, 3], '', 8, true);
			blank.animation.play('i', true);
			blank.animation.curAnim.timeScale = FlxG.random.float(0.1, 0.5);
			blank.scale.set(frameSprite.scale.x + FlxG.random.float(0.1, 0.2), frameSprite.scale.y + FlxG.random.float(0.1, 0.2));
			blank.updateHitbox();
			blank.scrollFactor.set(0, 0);
			blank.cameras = [bgCamera];
			blank.color = FlxColor.WHITE;
			insert(members.indexOf(frameSprite) - 1, blank);
			bgFrames.push(blank);
			
			bgStatic.scrollFactor.set(0, 0);
			bgStatic.animation.add('i', [0, 1, 2, 3], 16, true);
			bgStatic.animation.play('i', true);
			bgStatic.screenCenter();
			bgStatic.alpha = 0.1;
			bgStatic.cameras = [bgCamera];
			insert(0, bgStatic);
			add(bgStatic);
		}
	}
	
	var hall:FlxSprite = new FlxSprite(140, 0).loadGraphic(Paths.image('stages/antivoid/hall'));
	add(hall);
	mainStage.push(hall);
	
	allTogetherNow.frames = Paths.getAsepriteAtlas('stages/antivoid/alltogethernow');
	allTogetherNow.animation.addByPrefix('wholeanim', 'startup', 8, false);
	allTogetherNow.animation.addByPrefix('pull', 'pull0', 8, false);
	allTogetherNow.animation.addByPrefix('pullhard', 'pullhard0', 8, false);
	allTogetherNow.animation.addByPrefix('kill', 'kill0', 8, false);
	add(allTogetherNow);
	allTogetherNow.screenCenter();
	allTogetherNow.setPosition(allTogetherNow.x + 225, allTogetherNow.y - 239.5);
	allTogetherNow.visible = false;
	
	darkGradient.screenCenter();
	darkGradient.scrollFactor.set(0, 0);
	darkGradient.alpha = 0;
	add(darkGradient);
	
	setStringVisible(false);
}

function create() {
	camGame.antialiasing = false;
	
	for (i in 0...8) {
		var pillar:FlxSprite = new FlxSprite(120 * i, 0).loadGraphic(Paths.image('stages/antivoid/pillar'));
		mainStage.push(pillar);
		if (i > 3) {
			pillar.x += 120;
		}
		pillar.scrollFactor.set(1.2, 1);
		add(pillar);
	}
}

var pico:Character;
var gf:Character;
var realBoyfriend:Character;
var error:Character;
function postCreate() {
	pico = strumLines.members[0].characters[0];
	gf = strumLines.members[1].characters[0];
	realBoyfriend = strumLines.members[3].characters[0];
	error = strumLines.members[2].characters[0];
	
	picoHanging.setPosition(realBoyfriend.x - 84, realBoyfriend.y - 140);
	picoHanging.scrollFactor.set(0.9, 0.9);
	add(picoHanging);
	
	gfHeadHanging.scrollFactor.set(0.9, 0.9);
	add(gfHeadHanging);
	
	gfBodyHanging.setPosition(picoHanging.x + 44, picoHanging.y);
	gfBodyHanging.scrollFactor.set(0.9, 0.9);
	add(gfBodyHanging);
	gfHeadHanging.setPosition(gfBodyHanging.x + 4, gfBodyHanging.y - 5);
	picoHanging.visible = gfHeadHanging.visible = gfBodyHanging.visible = false;
	
	pico.color = gf.color = realBoyfriend.color = FlxColor.BLACK;
	error.visible = false;
	
	// glitcher.glitchIntensity = 0;
	FlxG.cameras.insert(bgCamera, 0, false);
	bgCamera.bgColor = FlxColor.BLACK;
	bgCamera.addShader(splitter);
	// antivoid.visible = false;
	bgCamera.visible = false;
	camGame.bgColor = FlxColor.TRANSPARENT;
	bgCamera.zoom = 3.8;
}

var binary:CustomShader = new CustomShader('binaryGlitch');
var binarySlider:FlxObject = new FlxObject();
var updateShader:Bool = false;
var splitSlider:FlxObject = new FlxObject();
var updateSplit:Bool = false;
function update() {
	if (updateShader) {
		binary.size = binarySlider.x;
	}
	bgCamera.zoom = camGame.zoom - 0.2;
	if (updateSplit) {
		splitter.ring1 = splitSlider.x;
		splitter.ring2 = splitSlider.x;
		splitter.push1 = splitSlider.x * 6;
		splitter.push2 = splitSlider.x * 6;
	}
}

function postUpdate() {
	// camGame.zoom = 0.1;
}


// function changeFrames(t:Float, i:Float) {

// }

function setStringVisible(v:Bool) {
	for (string in soulStrings) {
		string.visible = v;
	}
	for (mask in soulMasks) {
		mask.visible = v;
	}
}

function stageTransition() {
	setStringVisible(true);
	
	updateShader = true;
	for (object in mainStage) {
		object.shader = binary;
	}
	FlxTween.tween(binarySlider, {x: -300}, (Conductor.crochet / 1000) * 2, {ease: FlxEase.quadInOut, onComplete: function() {
		updateShader = false;
		for (object in mainStage) {
			object.visible = false;
			object.shader = null;
		}
	}});
	for (char in [realBoyfriend, gf, pico])	{
		FlxTween.color(char, (Conductor.crochet / 1000) * 2, FlxColor.BLACK, FlxColor.WHITE);
	}
}

//944, 130
function errorAppear() { 
	error.visible = true; 
	
	executeEvent({name: 'Change Character', params: [3, 'bf-worried']});
	realBoyfriend = strumLines.members[3].characters[0];
	realBoyfriend.color = FlxColor.BLACK;
}

function darkenTransition() {
	FlxTween.tween(darkGradient, {alpha: 1}, 12, {ease: FlxEase.quadIn});
	for (mask in soulMasks) {
		FlxTween.color(mask, 12, mask.color, FlxColor.fromRGB(0, 0, 0, (mask.alpha / 1) * 255));
	}
}

function playTransitionAnimation(a:String) {
	if (a == 'wholeanim') {
		FlxTween.tween(camHUD, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.quadInOut});
	}
	gf.visible = pico.visible = error.visible = false;
	allTogetherNow.visible = true;
	allTogetherNow.animation.play(a, true);
}

var phaseThreeActive:Bool = false;
function phaseThree() {
	phaseThreeActive = true;
	
	picoHanging.visible = gfHeadHanging.visible = gfBodyHanging.visible = true;

	FlxTween.tween(camHUD, {alpha: 1}, Conductor.crochet / 1000, {ease: FlxEase.quadInOut});
	
	allTogetherNow.visible = false;
	
	executeEvent({name: 'Change Character', params: [3, 'bf-st']});
	realBoyfriend = strumLines.members[3].characters[0];
	realBoyfriend.y += 1;

	executeEvent({name: 'Change Character', params: [2, 'error']});
	error = strumLines.members[2].characters[0];
	error.setPosition(error.x + 9, error.y + 12);
	
	remove(darkGradient);
	insert(members.length, darkGradient);
	
	camGame.targetOffset.set(0, 11);
	
	antivoid.visible = false;
	bgCamera.visible = true;
	for (frame in bgFrames) {
		frame.velocity.set(FlxG.random.float(-1, 1), FlxG.random.float(-1, 1));
	}
	updateSplit = true;
	splitSlider.x = 200;
	FlxTween.tween(splitSlider, {x: 0}, 1, {ease: FlxEase.expoOut, onComplete: function() {
		bgCamera.removeShader(splitter);
		updateSplit = false;
	}});
}

var anims = [
	'idle' => ['starcatcher', 'corruption'],
	'singLEFT' => ['b3', 'bsides'],
	'singDOWN' => ['ce', 'dsides'],
	'singUP' => ['csides', 'arrowfunk'],
	'singRIGHT' => ['djx', 'hellbeats'],
];
var singAnim = [
	0 => 'singLEFT',
	1 => 'singDOWN',
	2 => 'singUP',
	3 => 'singRIGHT',
];
function onPlayerHit(e) {
	if (!PlayState.opponentMode) {
		if (phaseThreeActive) {
			animSuffix = anims.get(singAnim.get(e.direction));
			animSuffix = animSuffix[FlxG.random.int(0, animSuffix.length - 1)];
			anim = singAnim.get(e.direction) + (FlxG.random.bool(50) ? '-' + animSuffix : '');
			PlayState.instance.executeEvent({name: 'Glitched Sing Animation', params: [3, anim], time: Conductor.songPosition});
			
			tryIconUpdate(animSuffix);
		}
	}
}

function onDadHit(e) {
	if (PlayState.opponentMode) {
		if (phaseThreeActive) {
			animSuffix = anims.get(singAnim.get(e.direction));
			animSuffix = animSuffix[FlxG.random.int(0, animSuffix.length - 1)];
			anim = singAnim.get(e.direction) + (FlxG.random.bool(50) ? '-' + animSuffix : '');
			PlayState.instance.executeEvent({name: 'Glitched Sing Animation', params: [3, anim], time: Conductor.songPosition});
			
			tryIconUpdate(animSuffix);
		}
	}
}

function randomSingAnim() {
	var direction:Int = FlxG.random.int(0, 3);
	animSuffix = anims.get(singAnim.get(direction));
	animSuffix = animSuffix[FlxG.random.int(0, animSuffix.length - 1)];
	anim = singAnim.get(direction) + (FlxG.random.bool(50) ? '-' + animSuffix : '');
	PlayState.instance.executeEvent({name: 'Glitched Sing Animation', params: [3, anim], time: Conductor.songPosition});
		
	tryIconUpdate(animSuffix);
}

function stepHit(step:Int) {
	if (phaseThreeActive && step % 4 == 0 && realBoyfriend.lastHit + (Conductor.stepCrochet * realBoyfriend.holdTime) < Conductor.songPosition) {
		tryIconUpdate('bf');
	}
}

function beatHit(beat:Int) {
	if (phaseThreeActive) {
		if (beat % 4 == 0 && realBoyfriend.lastHit + (Conductor.stepCrochet * realBoyfriend.holdTime) < Conductor.songPosition) {
			animSuffix = anims.get('idle');
			animSuffix = animSuffix[FlxG.random.int(0, animSuffix.length - 1)];
			anim = 'idle' + (FlxG.random.bool(50) ? '-' + animSuffix : '');
			PlayState.instance.executeEvent({name: 'Glitched Sing Animation', params: [3, anim], time: Conductor.songPosition});
			
			tryIconUpdate(animSuffix);
		}
	}
	
	if (frontMode) {
		if (beat % camZoomingInterval == 0) {
			bigBoxText.text = CoolUtil.repeat(messages[FlxG.random.int(0, messages.length - 1)], 36);
		}
	}
}

var lastSuffix:String = '';
var colors = [
	'bf' => '32B1D1',
	'starcatcher' => '32B1D1',
	'corruption' => '000000',
	'b3' => '56FA57',
	'bsides' => 'E86ACB',
	'ce' => '4947D4',
	'dsides' => 'E455D8',
	'csides' => '0065CC',
	'arrowfunk' => '9FFE29',
	'djx' => 'FF6397',
	'hellbeats' => 'D4AC4A',
];
function tryIconUpdate(suffix:String) {
	if (lastSuffix != suffix) {
		PlayState.instance.executeEvent({name: 'Change Icons', params: [suffix, '',  colors[suffix], '']});
		lastSuffix = suffix;
	}
}

var messages:Array<FlxSprite> = [
	'* Where\'d that smile go?',
	'* Don\'t wander where you don\'t belong.',
	'* It\'s a whole different world out there, huh?',
	'* Can\'t you see? This world SCREAMS for your death.',
	'* Only buying time.',
	'* Keep struggling, it\'ll make this much more fun.',
	'* You\'ve shown me so many new things, so much that\'s out there.',
	'* What\'s with that look? Aren\'t we having fun?',
	'* What a pest.',
	'* You can\'t and couldn\'t run from me FOREVER!',
];
var frontMode:Bool = false;
var gameOver:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameover/gameover'));
var evilGlow:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/antivoid/redglow'));
function stageFront() {
	frontMode = true;
	
	picoHanging.visible = gfHeadHanging.visible = gfBodyHanging.visible = false;

	phaseThreeActive = false;
	
	for (frame in bgFrames) {
		frame.visible = false;
	}
	bgCamera.visible = false;
	
	antivoid.alpha = 0.5;
	antivoid.visible = true;

	realBoyfriend.shader = error.shader = null;
	executeEvent({name: 'Change Character', params: [3, 'bf-hanging']});
	realBoyfriend = strumLines.members[3].characters[0];
	realBoyfriend.setPosition(error.x - 162, error.y - 190);
	
	PlayState.instance.executeEvent({name: 'Change Icons', params: ['bf', '',  '32B1D1', '']});
	
	executeEvent({name: 'Change Character', params: [2, 'error-front']});
	error = strumLines.members[2].characters[0];
	
	remove(darkGradient);
	insert(members.indexOf(error) + 1, darkGradient);
	FlxTween.tween(darkGradient, {alpha: 0.6}, Conductor.crochet / 1000, {ease: FlxEase.quadInOut});
	darkGradient.scrollFactor.set(0, 0);
	darkGradient.y -= 20;
	
	var bigBox:FlxSprite = new FlxSprite(error.getGraphicMidpoint().x - 200, error.y + 68).loadGraphic(Paths.image('stages/antivoid/bigBox'));
	insert(members.indexOf(realBoyfriend) - 1, bigBox);
	
	bigBoxText = new UndertaleText(bigBox.x, bigBox.y + 12, '*tung tung tung sahur', 'left', bigBox.width, 1, 'FFFFFF', 'undertale-pixel');
	bigBoxText.alpha = 0.1;
	insert(members.indexOf(bigBox) + 1, bigBoxText);
	bigBoxText.text = CoolUtil.repeat(messages[FlxG.random.int(0, messages.length - 1)], 36);
	
	gameOver.scale.set(0.4, 0.4);
	gameOver.updateHitbox();
	gameOver.setPosition(error.x - 16, error.y - 40);
	gameOver.shader = binary;
	add(gameOver);
	remove(gameOver);
	insert(members.indexOf(error) - 1, gameOver);
	gameOver.alpha = 0;
	gameOver.offset.set(150, 76);
	
	evilGlow.setPosition(gameOver.x - 70, gameOver.y - 50);
	evilGlow.alpha = 0;
	evilGlow.blend = 0;
	evilGlow.scale.set(0.6, 0.6);
	evilGlow.updateHitbox();
	add(evilGlow);
	evilGlow.offset.set(gameOver.offset.x, gameOver.offset.y);
	
	bgStatic.cameras = [camGame];
	remove(bgStatic);
	insert(members.indexOf(antivoid) + 1, bgStatic);
}

function onCameraMove(e) {
	if (frontMode) {
		camGame.targetOffset.y = (e.strumLine.opponentSide ? 0 : -13);
	}
}

function menacingStuff() {
	var pointInSong:Float = (inst.length - Conductor.songPosition) - 1000;
	FlxTween.tween(evilGlow, {alpha: 1}, pointInSong / 1000);
	FlxTween.tween(gameOver, {alpha: 1}, pointInSong / 1000);
}

function disablePhaseThreeStuffBrah() {
	phaseThreeActive = false;
}

function resetBf() {
	executeEvent({name: 'Change Character', params: [3, 'bf-worried']});
	realBoyfriend = strumLines.members[3].characters[0];
	realBoyfriend.y += 1;
	
	remove(darkGradient);
	insert(members.length, darkGradient);
}

var middle = [412, 524, 636, 748];
var originalValuesPlayer = [];
var originalValuesOpponent = [];
function strumChange() {
	for (strumLine in strumLines.members) {
		if (strumLine.opponentSide) {
			for (note in strumLine.notes) {
				note.alpha = (PlayState.opponentMode ? 1 : 0);
			}
		} else {
			if (PlayState.opponentMode) {
				for (note in strumLine.notes) {
					note.visible = false;
				}
			}
		}
		for (strum in strumLine) {
			if (strumLine.opponentSide) {
				strum.alpha = (PlayState.opponentMode ? 1 : 0);
				originalValuesOpponent.push(strum.x);
			} else {
				strum.visible = (PlayState.opponentMode ? false : true);
				originalValuesPlayer.push(strum.x);
			}
			strum.x = middle[strum.ID];
		}
	}
}