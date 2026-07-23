var outlineBoyfriendLeft:Character;
var boyfriendLeft:Character;
var outlineBoyfriendRight:Character;
var boyfriendRight;
var splitAnimation:FlxSprite;
function create() {
	boyfriendLeft = createCharacter(boyfriend.x, boyfriend.y, 'bf-split');
	// outlineBoyfriendLeft = createCharacter(boyfriendLeft.x, boyfriendLeft.y, 'bf-outline');
	
	boyfriendRight = createCharacter(boyfriend.x, boyfriend.y, 'bf-split');
	boyfriendRight.idleSuffix = '-alt';
	// outlineBoyfriendRight = createCharacter(boyfriendRight.x + 0.1, boyfriendRight.y + 0.1, 'bf-outline');
	
	splitAnimation = new FlxSprite(bf.x, bf.y);
	splitAnimation.frames = Paths.getSparrowAtlas('stages/dogshrine-switch/bf_splitanimation');
	splitAnimation.animation.addByPrefix('split', 'splitanim0', 10, false);
	splitAnimation.animation.finishCallback = function(name:String) {
		if (name == 'split') {
			boyfriendLeft.visible = true; boyfriendRight.visible = true;
			splitAnimation.visible = false;
		}
	};
	splitAnimation.antialiasing = false;
	splitAnimation.visible = false;
	add(splitAnimation);
	
	for (char in [boyfriendRight, boyfriendLeft]) { add(char); char.visible = false; }
	updateVisibility();
}

function postCreate() {
	// outlineBoyfriendLeft.pixelPerfectRender = false;
	// outlineBoyfriendRight.pixelPerfectRender = false;
}

// function beatHit(curBeat:Int) {
	// if (curBeat % 2 == 0) {
		// boyfriendRight.playAnim('idle', true);
	// }
// }

function onEvent(event) {
	if (event.event.name == 'Boyfriend Split' && FlxG.save.data.shrine_mechanics_allowed) {
		splitAnimation.visible = true;
		splitAnimation.animation.play('split', true);
		bf.alpha = 0;
		
		FlxG.sound.play(Paths.sound('shatter'), 1);
		camGame.flash(FlxColor.WHITE, 1);
	} else if (event.event.name == 'HScript Call') {
		if (event.event.params[0] == 'battleSection') {
			boyfriendLeft.visible = false;
			boyfriendRight.visible = false;
		} else if (event.event.params[0] == 'unBattleSection') {
			boyfriendLeft.visible = true;
			boyfriendRight.visible = true;
		}
	}
}

var currentAnimation:String;
var oldSwitched = false;
function update() {
	if (oldSwitched != switched) {
		oldSwitched = switched;
		updateVisibility();
	}
	currentAnimation = bf.animation.curAnim.name;
	if (switched && currentAnimation != 'idle') {
		boyfriendLeft.playAnim(currentAnimation, true, null, false, bf.animation.curAnim.curFrame);
	}
	if (!switched && currentAnimation != 'idle') {
		boyfriendRight.playAnim(currentAnimation + '-alt', true, null, false, bf.animation.curAnim.curFrame);
	}
	// trace(boyfriend.x + ' ' + boyfriend.y);
	// camGame.zoom = 2;
}

//lol why did i make this???
function createCharacter(x:Int, y:Int, character:String) {
	var char:Character = new Character(x, y, character, true);
	return char;
}

var s:Bool = false;
var soulLeft:Character;
var soulRight:Character;
function charSwitch() {	
	// remove(boyfriendLeft);
	// boyfriendLeft = createCharacter(boyfriend.x, boyfriend.y, (s ? 'soul-split' : 'soul-split'));
	// add(boyfriendLeft);
	
	// soulLeft = createCharacter(boyfriend.x, boyfriend.y, 'soul-split');
	// soulRight = createCharacter(boyfriend.x, boyfriend.y, 'soul-split');
	// soulRight.idleSuffix = '-alt';
	// add(soulLeft);
	// add(soulRight);
	
	// remove(boyfriendRight);
	// boyfriendRight = createCharacter(boyfriend.x, boyfriend.y, (s ? 'soul-split' : 'soul-split'));
	// boyfriendRight.idleSuffix = '-alt';
	// trace('hola');
	// add(boyfriendRight);
	// updateVisibility();
}

function battleStart() {
	boyfriend.setPosition(104, 160);

	if (FlxG.save.data.shrine_mechanics_allowed) {
		remove(boyfriendLeft);
		boyfriendLeft = createCharacter(boyfriend.x, boyfriend.y, 'soul-split');
		add(boyfriendLeft);
		
		remove(boyfriendRight);
		boyfriendRight = createCharacter(boyfriend.x, boyfriend.y, 'soul-split');
		boyfriendRight.idleSuffix = '-alt';
		add(boyfriendRight);
	} else {
		boyfriend.visible = true;
		executeEvent({name: 'Change Character', params: [1, 'soul']});
		// boyfriend.setPosition(
		
		boyfriend.scale.set(1, 1);
	}
		
		updateVisibility();
	
	boyfriend.setPosition(boyfriend.x + 24, boyfriend.y - 40);
	boyfriend.setPosition(104, 160);
	
	if (FlxG.save.data.shrine_mechanics_allowed) {
		boyfriend.setPosition(boyfriend.x + 25, boyfriend.y);
	}
	//154, 124
}

function battleStop() {
	boyfriend.setPosition(164, 55);
	
	if (FlxG.save.data.shrine_mechanics_allowed) {
		remove(boyfriendLeft);
		boyfriendLeft = createCharacter(boyfriend.x, boyfriend.y, 'bf-split');
		add(boyfriendLeft);
		
		remove(boyfriendRight);
		boyfriendRight = createCharacter(boyfriend.x, boyfriend.y, 'bf-split');
		boyfriendRight.idleSuffix = '-alt';
		add(boyfriendRight);
	} else {
		executeEvent({name: 'Change Character', params: [1, 'bf-ut']});
		// boyfrien
	}
	
	updateVisibility();
}

function updateVisibility() {
	boyfriendLeft.alpha = (switched ? 1 : 0.5);
	boyfriendRight.alpha = (!switched ? 1 : 0.5);
	if (switched) {
		remove(boyfriendLeft);
		insert(members.indexOf(boyfriendRight) + 1, boyfriendLeft);
	} else {
		remove(boyfriendRight);
		insert(members.indexOf(boyfriendLeft) + 1, boyfriendRight);
	}
}