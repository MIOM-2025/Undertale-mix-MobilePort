import funkin.backend.scripting.events.CancellableEvent;
import funkin.backend.scripting.events.sprite.PlayAnimEvent;
import flixel.tweens.FlxEase;
import flixel.math.FlxPoint;

using StringTools;

var camMovementTween:FlxTween;
var camMovementDistance:Float = 4;
var charOriginalOffsets:Map<String, Array<Float>> = [];

//Anchor.
var forceCamera = false;
var forcedCameraPosition = [0, 0];

function create() {
	if (FlxG.save.data.camFollowDistance != null) {
		camMovementDistance = FlxG.save.data.camFollowDistance;
	}
}

function postCreate()
{
	for (strum in strumLines.members)
	{
		for (character in strum.characters)
		{
			if (!charOriginalOffsets.exists(character.curCharacter))
				charOriginalOffsets.set(character.curCharacter, [character.cameraOffset.x, character.cameraOffset.y]);
		}
	}
}

function update(elapsed:Float)
{
	for (strum in strumLines.members)
	{
		for (character in strum.characters)
		{
			if (character.getAnimName().contains('idle') || character.getAnimName().contains('dance'))
			{
				if (!forceCamera) {
					character.cameraOffset.x = charOriginalOffsets.get(character.curCharacter)[0];
					character.cameraOffset.y = charOriginalOffsets.get(character.curCharacter)[1];
				} else {
					character.cameraOffset.x = forcedCameraPosition[0];
					character.cameraOffset.y = forcedCameraPosition[1];
				}
			}
		}
	}
	// trace(camFollow.x + ' ' + camFollow.y);
}

function onNoteHit(e:NoteHitEvent)
{
	if (e.note.isSustainNote)
		return;
	if (charOriginalOffsets.exists(e.character.curCharacter))
	{
		if (!forceCamera) {
			e.character.cameraOffset.x = charOriginalOffsets.get(e.character.curCharacter)[0];
			e.character.cameraOffset.y = charOriginalOffsets.get(e.character.curCharacter)[1];
		} else {
			e.character.cameraOffset.x = forcedCameraPosition[0];
			e.character.cameraOffset.y = forcedCameraPosition[1];
		}

		if (camMovementTween != null)
			camMovementTween.complete();

		switch (e.direction)
		{
			case 0:
				e.character.cameraOffset.x -= camMovementDistance;
			case 1:
				e.character.cameraOffset.y += camMovementDistance;
			case 2:
				e.character.cameraOffset.y -= camMovementDistance;
			case 3:
				e.character.cameraOffset.x += camMovementDistance;
		}
	}
}

function onEvent(event) {
	if (event.event.name == 'Force Camera Position') {
		var params = event.event.params;
		forceCamera = params[0];
		forcedCameraPosition = [params[1], params[2]];
	}
}

function updateOffsets() {
	for (strum in strumLines.members)
	{
		for (character in strum.characters)
		{
			if (!charOriginalOffsets.exists(character.curCharacter))
				charOriginalOffsets.set(character.curCharacter, [character.cameraOffset.x, character.cameraOffset.y]);
		}
	}
}