import flixel.util.FlxSpriteUtil;

class GlitchFrame extends FlxSprite {
	var image:FlxSprite = new FlxSprite();
	override function new(x:Int, y:Int, image:String, order:Int, parent:Dynamic) {
		super(x, y);
		// image.loadGraphic(Paths.image('frame/shots/image2'));
	
		// frames = Paths.getAsepriteAtlas('frame/frame');
		// animation.addByIndices('i', 'frame', [0, 1], '', 8, true);
		// animation.play('i', true);
		// image.updateHitbox();
		
		// setGraphicSize(image.width, image.height);
		// PlayState.instance.add(image);
		
		// FlxSpriteUtil.alphaMaskFlxSprite(image, this, this);
		
		// frames = Paths.getAsepriteAtlas('frame/shots/' + image);
		// animation.addByIndices('i', 'frames', [0, 1], '', 8, true);
		// animation.play('i', true);
		// animation.curAnim.timeScale = r.float(0.1, 0.5);
		// bubble.antialiasing = false;
	}
}

	var bubble:FlxSprite = new FlxSprite();
	bubble.frames = Paths.getAsepriteAtlas('frame/shots/' + image);
	bubble.animation.addByIndices('i', 'frames', [0, 1], '', 8, true);
	// bubble.animation.addByPrefix('i', 'frame', 8.0, true);
	bubble.animation.play('i', true);
	bubble.animation.curAnim.timeScale = r.float(0.1, 0.5);
	bubble.antialiasing = false;
	var scale:Float = r.float(0.05, 0.09);
	bubble.scale.set(0, 0);
	bubble.origin.set(-10, -10);
	bubble.scrollFactor.set((scale / 0.1) * 1, (scale / 0.1) * 1);
	FlxTween.tween(bubble.scale, {x: scale, y: scale}, 2, {ease: FlxEase.cubeInOut});
	// FlxTween.tween(bubble, {x: bubble.x + -10}, 5, {onComplete: function() {
		// FlxTween.tween(bubble.scale, {x: 0, y: 0}, {ease: FlxEase.cubeInOut});
	// }});
	bubble.velocity.x = 10 * ((scale / 0.1) * 1);
	var timer:FlxTimer = new FlxTimer().start(3, function() {
		FlxTween.tween(bubble.scale, {x: 0, y: 0}, {ease: FlxEase.cubeInOut});
	});
	// bubble.updateHitbox();
	var black:Int = r.int(70, 120);
	bubble.color = FlxColor.fromRGB(black, black, black, 1);
	bubble.screenCenter();
	bubble.setPosition((bubble.x + 200) + r.int(150, 300), (bubble.y + 350) - r.int(235, 280));
	add(bubble);
	remove(bubble);
	insert(members.indexOf(strumLines.members[3].characters[0]) - 1, bubble);