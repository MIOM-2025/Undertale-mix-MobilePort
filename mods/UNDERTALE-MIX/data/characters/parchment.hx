var cape:FlxSprite;
var game = PlayState.instance;
var face:FlxSprite = new FlxSprite().loadGraphic(Paths.image('face'));
var faceSplat:FlxSprite = new FlxSprite().loadGraphic(Paths.image('facesplat'));
var offsets = [
	'idle' => [[7, 30], [8, 29], [8, 28], [8, 27]],
	'singLEFT' => [[25, 27], [27, 27]],
	'singDOWN' => [[7, 36], [7, 34]],
	'singUP' => [[9, 25], [8, 29]],
	'singRIGHT' => [[33, 28], [30, 28]]
];
function create() {
	cape = new FlxSprite();
	cape.frames = Paths.getSparrowAtlas('cape');
	cape.animation.addByPrefix('cape', 'cape0', 8, true);
	cape.animation.play('cape');
	cape.antialiasing = false;
	
	face.setPosition(x + 532, y - 176);
	face.visible = false;
	game.add(face);
	
	faceSplat.visible = false;
	game.add(faceSplat);
}

var added = false;
function update() {
	var animName = animation.curAnim.name;
	cape.flipX = (animName == 'idle' || animName == 'singDOWN' || animName == 'singUP');
	cape.visible = !(animName == 'transformation');
	cape.color = color;
	cape.alpha = alpha;
	if (cape.visible) {
		var xOffset = offsets.get(animation.curAnim.name)[animation.curAnim.curFrame][0];
		var yOffset = offsets.get(animation.curAnim.name)[animation.curAnim.curFrame][1];
		cape.setPosition(x + xOffset, y + yOffset);
	}
	if (!added && game != null) {
		game.insert(game.members.indexOf(game.dad), cape);
		added = true;
	}
	
	if (animName == 'transformation' && animation.curAnim.curFrame == 30) {
		faceFall();
	}
	face.color = color;
	faceSplat.color = face.color;
	faceSplat.setPosition(face.x - 1, face.y + 3);
	
	if (face.angle > 90) {
		face.angularVelocity = 0;
		face.angle = 90;
	}
	if (face.y > -140) {
		face.velocity.x = 0;
		face.acceleration.x = 0;
		face.acceleration.y = 0;
		face.velocity.y = 0;
		face.visible = false;
		faceSplat.visible = true;
	}
}

function faceFall() {
	face.visible = true;
	face.velocity.x = 250;
	face.acceleration.set(-700, 500);
	face.angularVelocity = 200;
}