import DialogueBox;

class Interactable extends FlxSprite {
	var dialogueBox:Dynamic;
	var playerObject:Dynamic;
	var heldDialogue:Array<Dynamic>;
	var dialogueBox:Dynamic;
	var beingUsed:Bool = false;
	override function new(x:Int, y:Int, width:Int, height:Int, dialogue:Array<Dynamic>, player:Dynamic, box:Dynamic) {
		super(x, y);
		makeGraphic(width, height, FlxColor.RED);
		playerObject = player;
		dialogueBox = box;
		heldDialogue = dialogue;
			// trace(dialogue);
	}
	
	override function update(elapsed:Float) {
		if ((FlxG.keys.justPressed.Z || FlxG.keys.justPressed.ENTER) && !beingUsed && FlxG.overlap(playerObject.collisionBox, this)) {
			dialogueBox.setupDialogue(heldDialogue[0]);
			beingUsed = true;
			playerObject.lockMovement = true;
			trace('ouh');
		}
		
		if (beingUsed) {
			if (!dialogueBox.active) {
				playerObject.lockMovement = false;
				beingUsed = false;
			}
		}
	
		super.update(elapsed);
	}
}