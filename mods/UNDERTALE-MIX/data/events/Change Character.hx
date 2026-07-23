import funkin.game.Character;

function onEvent(e) {
	if (e.event.name == 'Change Character') {
		var prop = {
			strum: e.event.params[0],
			character: e.event.params[1],
		}
		trace(prop);
		var chara = strumLines.members[prop.strum].characters[0];
		var newCharacter:Character = new Character(chara.x, chara.y, prop.character, !strumLines.members[prop.strum].opponentSide);
		
		var group = strumLines.members[prop.strum].characters;
		group.remove(chara);
		chara.kill();
		
		group.push(newCharacter);
		add(newCharacter);
		executeEvent({name: 'HScript Call', params: ['updateOffsets', '']});
	}
}