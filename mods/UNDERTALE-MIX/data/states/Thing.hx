import hxvlc.flixel.FlxVideoSprite;

import flixel.math.FlxRandom;
import Sys;

var video:FlxVideoSprite = new FlxVideoSprite(0, 0);
var random:FlxRandom = new FlxRandom();
var doThisShitOnce:Bool = false;
function update() {
	if (!doThisShitOnce) {
		doThisShitOnce = true;
		if (FlxG.save.data.introChance != null) {
			FlxG.save.data.introChance = 0;
		}
		// trace(Paths.getFolderContent('videos/ignore'));
		var videos:Array<String> = Paths.getFolderContent('videos/ignore');
		video.antialiasing = false;
		video.bitmap.onFormatSetup.add(function() {
			video.setGraphicSize(FlxG.width, FlxG.height);
			video.updateHitbox();
			video.screenCenter();
		});
		video.bitmap.onEndReached.add(function () {
			FlxG.switchState(new TitleState());
		});
		add(video);
		
		var selectedVideo:String = videos[random.int(0, videos.length - 1)];
		if (video.load(Paths.video('ignore/' + selectedVideo.substring(0, selectedVideo.length - 4)))) {
			video.play();
		}
	}
}