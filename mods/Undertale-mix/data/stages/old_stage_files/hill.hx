import flixel.addons.display.FlxBackdrop;

function onStrumCreation(event) {
    event.sprite = 'game/notes/NOTE_genesis';
}

var titleSonic:FlxSprite;
//Stage stuff.
var cloudsBig:FlxBackdrop = new FlxBackdrop(Paths.image('stages/hill/clouds-normal'), FlxAxes.X);
var cloudsSmallTop:FlxBackdrop = new FlxBackdrop(Paths.image('stages/hill/cloudssmall-normal'), FlxAxes.X);
var cloudsSmallBottom:FlxBackdrop = new FlxBackdrop(Paths.image('stages/hill/cloudssmall2-normal'), FlxAxes.X);
var mountains:FlxBackdrop = new FlxBackdrop(Paths.image('stages/hill/mountains-normal'), FlxAxes.X);
var oceanNormal:FlxBackdrop = new FlxBackdrop(null, FlxAxes.X);
var bloodOcean:FlxBackdrop = new FlxBackdrop(Paths.image('stages/hill/ocean'), FlxAxes.X);
var ground:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/hill/ground'));
//
function postCreate() {
	camGame.pixelPerfectRender = true;
	// player.cpu = true;
	
	//Hill background.
	oceanNormal.frames = Paths.getSparrowAtlas('stages/hill/ocean-normal');
	oceanNormal.animation.addByPrefix('idle', 'ocean0', 8, true);
	oceanNormal.animation.play('idle', true);
	oceanNormal.setPosition(0, 353);
	oceanNormal.velocity.set(-55, 0);
	
	for (sprite in [cloudsSmallBottom, mountains, cloudsSmallTop, cloudsBig, oceanNormal, bloodOcean, ground]) {
		sprite.antialiasing = false;
		if (sprite is FlxBackdrop) {
			sprite.scrollFactor.set(1, 0.03);
		}
		insert(members.indexOf(dad) - 1, sprite);
	}
	
	bloodOcean.setPosition(0, 353);
	bloodOcean.visible = false;
	bloodOcean.velocity.set(-55, 0);
	
	cloudsBig.setPosition(0, 242);
	cloudsBig.velocity.set(-90, 0);
	
	cloudsSmallTop.setPosition(0, 274);
	cloudsSmallTop.velocity.set(-65, 0);
	
	cloudsSmallBottom.setPosition(0, 290);
	cloudsSmallBottom.velocity.set(-25, 0);
	
	mountains.setPosition(0, 306);
	mountains.velocity.set(-35, 0);
	
	ground.screenCenter(FlxAxes.X);
	ground.setPosition(ground.x, 866);
	
	//Other stuff.
	titleSonic = new FlxSprite().loadGraphic(Paths.image('stages/hill/title_sonic'), true, 256, 150);
	titleSonic.animation.add('normal', [0, 1], 8, true);
	titleSonic.animation.add('exe', [2, 3], 8, true);
	titleSonic.animation.play('normal', true);
	titleSonic.screenCenter();
	titleSonic.antialiasing = false;
	add(titleSonic);
	
	camFollow.setPosition(titleSonic.getGraphicMidpoint().x, titleSonic.getGraphicMidpoint().y);
	camGame.snapToTarget();
	
}

function reveal() {
	titleSonic.animation.play('exe', true);
	cloudsBig.loadGraphic(Paths.image('stages/hill/clouds'));
	cloudsSmallTop.loadGraphic(Paths.image('stages/hill/cloudssmall'));
	cloudsSmallBottom.loadGraphic(Paths.image('stages/hill/cloudssmall2'));
	mountains.loadGraphic(Paths.image('stages/hill/mountains'));
	
	bloodOcean.visible = true;
	oceanNormal.visible = false;
}

var paneTime = 3;
function paneDown() {
	for (sprite in [cloudsSmallBottom, mountains, cloudsSmallTop, cloudsBig, oceanNormal, bloodOcean]) {
		FlxTween.tween(sprite.velocity, {x: 0}, 1, {ease: FlxEase.quadInOut});
	}
	FlxTween.tween(camFollow, {y: camFollow.y + 500}, paneTime, {ease: FlxEase.quadInOut});
	FlxTween.tween(camGame, {zoom: 3.6}, paneTime, {ease: FlxEase.quadInOut, onComplete: function() {
		PlayState.instance.defaultCamZoom = camGame.zoom;
	}});
	
	boyfriend.setPosition(ground.x + 414, 864);
	dad.setPosition(ground.x + 318, 840);
}

function update() {
	curCameraTarget = -1;
	// camGame.zoom = 1;
}

introLength = 0;
function onCountdown(event) event.cancel();