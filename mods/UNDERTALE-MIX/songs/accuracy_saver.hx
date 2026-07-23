var foundSaved:Map<String, Float> = [];
function create() {
	if (FlxG.save.data.savedAcc == null) {
		FlxG.save.data.savedAcc = foundSaved;
	} else {
		foundSaved = FlxG.save.data.savedAcc;
	}
	// trace(FlxG.save.data.savedAcc);
}

function onSongEnd() {
	saveAccuracy();
}

//yo i was doing some genuine bullshit before i gotta start thinking about maps more
function saveAccuracy() {
	var foundAccuracy:Float = foundSaved.get(curSongID);
	if (foundAccuracy == null) {
		foundSaved.set(curSongID, accuracy);
	} else if (foundAccuracy != null) {
		if (accuracy > foundAccuracy) {
			foundSaved.set(curSongID, accuracy);
		} else {
			trace('It\'s not bigger.');
		}
	}
}