import NoteRating;
import Std;

var comboCamera:FlxCamera = new FlxCamera();
//Rating stuff.
var ratingX:Int = 100;
var ratingY:Int = 100;
var numberX:Int = 0;
var numberY:Int = 0;
var usedRatings:Array<Dynamic> = [];
//Default skin.
var ratingData = {
	skin: 'ut',
	atlasType: 'aseprite',
	numberOffsetX: 47,
	numberOffsetY: 47,
	scale: 1.5
}
//Save stuff.
var ratingSavedPos:Array<Int> = [254, 266];
var ratingEnabled:Bool = true;
var comboSavedPos:Array<Int> = [254, 331];
var comboEnabled:Bool = true;
var comboCache:Int = 4;
var fadeDelay:Float = 0.1;
var comboStacking:Bool = true;
var ratingOnTop:Bool = false;
function create() {
	
	comboCamera.bgColor = FlxColor.TRANSPARENT;
	
	//Combo cache.
	if (FlxG.save.data.comboCache == null) {
		FlxG.save.data.comboCache = 4;
	}
	comboCache = FlxG.save.data.comboCache;
	//Display rating.
	if (FlxG.save.data.displayRating == null) {
		FlxG.save.data.displayRating = true;
	}
	ratingEnabled = FlxG.save.data.displayRating;
	//Rating saved positions.
	if (FlxG.save.data.ratingPositions == null) {
		FlxG.save.data.ratingPositions = [254, 266];
	}
	ratingSavedPos = FlxG.save.data.ratingPositions;
	//Display combo.
	if (FlxG.save.data.displayCombo == null) {
		FlxG.save.data.displayCombo = true;
	}
	comboEnabled = FlxG.save.data.displayCombo;
	//Combo saved positions.
	if (FlxG.save.data.comboPositions == null) {
		FlxG.save.data.comboPositions = [254, 331];
	}
	comboSavedPos = FlxG.save.data.comboPositions;
	//Cache objects.
	for (i in 0...comboCache) {
		var rating:NoteRating = new NoteRating(0, 0, 'sick', 'ratings', ratingData.skin, ratingData.atlasType, ratingData.scale);
		rating.cameras = [comboCamera];
		add(rating);
		rating.kill();
		usedRatings.push(rating);
	}
	//Fade delay.
	if (FlxG.save.data.comboFadeDelay == null) {
		FlxG.save.data.comboFadeDelay = 0.1;
	}
	fadeDelay = FlxG.save.data.comboFadeDelay;
	//Combo stacking.
	if (FlxG.save.data.comboStack == null) {
		FlxG.save.data.comboStack = true;
	}
	comboStacking = FlxG.save.data.comboStack;
	if (FlxG.save.data.ratingsOnTop == null) {
		FlxG.save.data.ratingsOnTop = false;
	}
	ratingOnTop = FlxG.save.data.ratingsOnTop;
}

function postCreate() {
	FlxG.cameras.insert(comboCamera, FlxG.cameras.list.indexOf((ratingOnTop ? camHUD : camGame)) + 1, false);
}

function onPlayerHit(e) {
	if (e.countAsCombo) {
		if (ratingEnabled) {
			displayRating(e.rating, usedRatings[0]);
		}
		if (comboEnabled) {
			var separatedCombo:String = CoolUtil.addZeros(Std.string(combo + 1), 3);
			for (i in 0...separatedCombo.length) {
				displayNumber(separatedCombo.charAt(i), i, usedRatings[0]);
			}
		}
	}
}

function displayNumber(number:String, id:Int, ratingObject:NoteRating) {
	if (ratingObject == null) {
		ratingObject = new NoteRating(comboSavedPos[0] + (ratingData.numberOffsetX * id), comboSavedPos[1], number, 'ratings', ratingData.skin, ratingData.atlasType, ratingData.scale);
		ratingObject.velocity.set(FlxG.random.int(0, 10), -150);
		ratingObject.acceleration.y = 600;
		ratingObject.cameras = [comboCamera];
		add(ratingObject);
	} else {
		usedRatings.remove(ratingObject);
		ratingObject.reset(number, comboSavedPos[0] + (ratingData.numberOffsetX * id), comboSavedPos[1]);
		ratingObject.velocity.set(FlxG.random.int(0, 10), -150);
		ratingObject.acceleration.y = 600;
	}
	FlxTween.tween(ratingObject, {alpha: 0}, 0.2, {startDelay: fadeDelay, onComplete: function() {
		ratingObject.kill();
		ratingObject.velocity.set();
		ratingObject.acceleration.set();
		usedRatings.push(ratingObject);
	}});
}

function displayRating(noteRating:String, ratingObject:NoteRating) {
	if (ratingObject == null) {
		ratingObject = new NoteRating(ratingSavedPos[0], ratingSavedPos[1], noteRating, 'ratings', ratingData.skin, ratingData.atlasType, ratingData.scale);
		ratingObject.velocity.set(-FlxG.random.int(0, 10), -FlxG.random.int(140, 160));
		ratingObject.acceleration.y = FlxG.random.int(200, 300);
		ratingObject.cameras = [comboCamera];
		add(ratingObject);
	} else {
		usedRatings.remove(ratingObject);
		ratingObject.reset(noteRating, ratingSavedPos[0], ratingSavedPos[1]);
		ratingObject.velocity.set(-FlxG.random.int(0, 10), -FlxG.random.int(140, 160));
		ratingObject.acceleration.y = FlxG.random.int(200, 300);
	}
	FlxTween.tween(ratingObject, {alpha: 0}, 0.2, {startDelay: fadeDelay, onComplete: function() {
		ratingObject.kill();
		ratingObject.velocity.set();
		ratingObject.acceleration.set();
		usedRatings.push(ratingObject);
	}});
}