import UndertaleText;
import flixel.math.FlxRandom;
import StringTools;

var baseText:String = 'que mirai sapo ql';
var text:UndertaleText;
var r:FlxRandom = new FlxRandom();
function create() {
	text = new UndertaleText(0, 0, baseText, 'center', FlxG.width, 3, 'FFFFFF', 'undertale-pixel');
	text.screenCenter();
	add(text);
	trace(baseText.charAt(0));
}

var messages:Array<String> = [
	'hola',
	'que tal',
	'nananananan nanana',
	'que mirai sapo ql',
];
var revealing:Bool = false;
var frameElapsed:Float = 0;
function update(elapsed:Float) {
	if (FlxG.keys.justPressed.Q && !revealing) {
		var pickedMessage:String = messages[r.int(0, messages.length - 1)];
		baseText = pickedMessage;
		text.text = pickedMessage;
		
	
		exclude = [];
		curIndex = -1;
		
		text.text = randomString(baseText.length);
		revealing = true;
	}

	frameElapsed += elapsed;
	if (frameElapsed > 0.05) {
		frameElapsed = 0;
		tick();
	}
}

var exclude:Array<Int> = []; 
var curIndex:Int = -1;
function tick() {
	if (revealing) {
		if (curIndex < baseText.length) {
			var textSplit:Array<String> = text.text.split('');
			var index:Int = r.int(0, textSplit.length, exclude);
			trace(index);
			textSplit[index] = baseText.charAt(index);
			// trace(textSplit[index] = baseText.charAt(index));
			text.text = textSplit.join();
			exclude.push(index);
			curIndex++;
		} else {
			revealing = false;
		}
	}
}

function randomString(length:Int) {
	var chars:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&/()=1234567890';
	var resultString:String = '';
	for (i in 0...length) {
		resultString = resultString + chars.charAt(r.int(0, chars.length));
	}
	return resultString;
}