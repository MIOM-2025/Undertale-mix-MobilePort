import UndertaleText;
import StringTools;

var textCamera:FlxCamera = new FlxCamera();
// var text:UndertaleText = new UndertaleText(0, 0, '', 'left', FlxG.width, 2.8, 'FFFFFF', 'undertale-pixel');
// var background:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);

var subTexts:Array<Dynamic> = [
];
var timer:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
function create() {
	FlxG.cameras.add(textCamera, false);
	textCamera.antialiasing = false;
	textCamera.bgColor = FlxColor.TRANSPARENT;
	textCamera.pixelPerfectRender = true;
	
	timer.visible = false;
}

var timerTween:FlxTween;


function onEvent(e) {
	if (e.event.name == 'Subtitle' && FlxMath.inBounds(e.event.time / 1000, (Conductor.songPosition / 1000) - 2, (Conductor.songPosition / 1000) + 2)) {
		var texts:Array<String> = e.event.params[0].split('/');
		// if (texts.length > 1) {
			
		// }
		if (subTexts.length > 0) {
			for (sub in subTexts) {
				sub.visible = false;
			}
		}
		for (i in 0...texts.length) {
			if (subTexts[i] != null) {
				// for (sub in subTexts) {
				trace('hi ' + i);
					subTexts[i][0].text = texts[i];
					subTexts[i][0].color = e.event.params[1];
					subTexts[i][0].updateHitbox();
					subTexts[i][0].screenCenter(FlxAxes.X);
					subTexts[i][0].visible = true;
					
					subTexts[i][1].setGraphicSize(subTexts[i][0].width, subTexts[i][1].height);
					subTexts[i][1].updateHitbox();
					subTexts[i][1].setPosition(subTexts[i][0].x, subTexts[i][1].y);
					subTexts[i][0].offset.y = -12;
					subTexts[i][1].visible = true;
				// }
			} else {
				var text:UndertaleText = new UndertaleText(0, 0, texts[i], 'center', FlxG.width, 2.8, 'FFFFFF', 'undertale-outline');
				// trace(e.event.params[2]);
				text.color = e.event.params[1];
				text.autoSize = true;
				text.updateHitbox();
				text.cameras = [textCamera];
				text.screenCenter();
				text.y += (text.height - 18) * i;
				text.y += 160;
				text.offset.y += 5;
				// text.y -= 10;
				
				var background:FlxSprite = new FlxSprite(text.x, text.y).makeGraphic(1, 1, FlxColor.BLACK);
				background.setGraphicSize(text.width, text.height / 1.5);
				background.updateHitbox();
				background.setPosition(text.x, text.y);
				background.cameras = [textCamera];
				background.alpha = 0.8;
				add(background);
				
				add(text);
				
				subTexts.push([text, background]);
			}
		}

		if (e.event.params[2] > 0) {
			if (timerTween != null) {
				timerTween.cancel();
			}
			for (i in 0...texts.length) {
				subTexts[i][0].visible = true;
				subTexts[i][1].visible = true;
			}
			timerTween = FlxTween.tween(timer, {x: 1}, (Conductor.stepCrochet / 1000) * e.event.params[2], {onComplete: function() {
				for (i in 0...texts.length) {
					subTexts[i][0].visible = false;
					subTexts[i][1].visible = false;
				}
			}});
		} else {
			for (i in 0...texts.length) {
				subTexts[i][0].visible = true;
				subTexts[i][1].visible = true;
			}
		}
	}
}