import Reflect;
function onEvent(event) {
	var params = event.event.params;
	var objects = [];
	if (params[2] == '' || params[3] == '') {
		trace('ERROR: Property or Value fields empty.');
		return;
	}
	if (params[1] != '') {
		objects.push(PlayState.instance.stage.stageSprites[params[1]]);
	} else {
		for (char in strumLines.members[params[0]].characters) {
			objects.push(char);
		}
	}
	
	for (thing in objects) {
		Reflect.setProperty(thing, params[2], params[3]);
	}
}