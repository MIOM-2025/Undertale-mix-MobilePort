import DialogueBox;

class MapTeleport extends FlxSprite {
	// var dialogueBox:Dynamic;
	var playerObject:Dynamic;
	var parentCamera:FlxCamera;
	var soundToPlay:String;
	var teleport:String;
	// var heldDialogue:Array<Dynamic>;
	override function new(x:Int, y:Int, width:Int, height:Int, teleportTo:String, sound:String, player:Dynamic, camera:FlxCamera) {
		super(x, y);
		makeGraphic(width, height, FlxColor.RED);
		playerObject = player;
		soundToPlay = sound;
		parentCamera = camera;
		teleport = teleportTo;
	}
	
	var teleported:Bool = false;
	override function update(elapsed:Float) {
		if (FlxG.overlap(this, playerObject.collisionBox) && !teleported) {
			teleported = true;	
			FlxG.sound.play(Paths.sound(soundToPlay), 1);
			playerObject.lockMovement = true;
			if (FlxG.sound.music != null) {
				FlxG.sound.music.fadeOut(0.2, 0);
			}
			parentCamera.fade(FlxColor.BLACK, 0.2, false, function () {
				var timer:FlxTimer = new FlxTimer().start(0.1, function() {
					FlxG.switchState(new ModState(teleport, true));
				});
			});
			trace('GOING AWAY!!!!');
		}
		super.update(elapsed);
	}
}