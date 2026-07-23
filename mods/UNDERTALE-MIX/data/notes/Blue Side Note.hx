function onNoteCreation(event) {
	if (event.noteType == 'Blue Side Note') {
		if (FlxG.save.data.shrine_mechanics_allowed) {
			event.noteSprite = "game/notes/circlenotes";
			event.note.color = FlxColor.fromString('#00ccff');
		}
	}
}