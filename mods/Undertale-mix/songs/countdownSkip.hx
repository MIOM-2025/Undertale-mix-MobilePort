import funkin.editors.charter.Charter;
import hxvlc.flixel.FlxVideoSprite;

var excluded:Bool = false;
var startCamera:FlxCamera = new FlxCamera();
var cover:FlxSprite;
var specialIntro:Bool = false;
var songName:String = '';
function create() {
	songName = PlayState.SONG.meta.name;
	if (songName == 'true-reset' || songName == 'vent' || songName == 'string-theory' || songName == 'temperate' || songName == 'temperate-cmix') {
		excluded = true;
	}
	if (songName == 'parchment-v1') {
		specialIntro = true;
	}
	if (PlayState.chartingMode) {
		excluded = true;
		specialIntro = false;
	}
	if (excluded) {
		introLength = 0;
	}
}

function postCreate() {
	// if (specialIntro) {
		// return;
	// }
	if (!excluded) {
		FlxG.cameras.insert(startCamera, FlxG.cameras.list.indexOf(camHUD), false);
		startCamera.bgColor = FlxColor.TRANSPARENT;
		startCamera.antialiasing = false;
		startCamera.zoom = 4;
		
		cover = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		cover.scrollFactor.set(0, 0);
		cover.cameras = [startCamera];
		add(cover);
		cover.alpha = specialIntro ? 0 : 1;
	}
}

function onStartCountdown(e) {
	if (specialIntro) {
		e.cancel();
		var real:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/deepersnowdin/p'));
		real.setGraphicSize(FlxG.width, FlxG.height);
		real.updateHitbox();
		real.screenCenter();
		real.cameras = [camHUD];
		add(real);
		if (songName == 'parchment-v1') {
			// e.cancel();
			var video2:FlxVideoSprite = makeVideo('fairytransition_2', function() {
				specialIntro = false;
				startCountdown();
			});
			var video1:FlxVideoSprite = makeVideo('fairytransition_1', function() {
				real.visible = false;
				
				add(video2);
				video2.play();
			});
			add(video1);
			video1.play();
		}
	}
}

function onCountdown(e) {
	if (excluded) {
		e.cancel();
	} else {
		switch(e.swagCounter) {
			case 0: 
				e.spritePath = null;
				e.soundPath = 'snd_noise';
			case 1: 
				e.spritePath = 'game/ready';
				e.soundPath = 'snd_noise';
			case 2: 
				e.spritePath = 'game/set';
				e.soundPath = 'snd_noise';
			case 3: 
				e.spritePath = 'game/go';
				e.soundPath = 'snd_battlefall';
				
		}
		
	}
}

function onPostCountdown(e) {
	if (e.sprite != null) {
		remove(cover);
		insert(0, cover);
		
		e.spriteTween.cancel();
		e.sprite.cameras = [startCamera];
		e.sprite.antialiasing = false;
		FlxTween.tween(e.sprite, {alpha: 0}, Conductor.crochet / 1000);
	}
}

function onSongStart() {
	if (cover != null) {
		FlxTween.tween(cover, {alpha: 0}, Conductor.stepCrochet / 1000, {onComplete: function() {	
			FlxG.cameras.remove(startCamera);
			startCamera.destroy();
		}});
	}
}

function makeVideo(videoFile:String, ?end:Void) {
	var video:FlxVideoSprite = new FlxVideoSprite();
	var greenScreen:CustomShader = new CustomShader('greenScreen');
	video.bitmap.onFormatSetup.add(function() {
		video.setGraphicSize(FlxG.width, FlxG.height);
		video.cameras = [camHUD];
		video.shader = greenScreen;
		video.updateHitbox();
		video.screenCenter();
	});
	video.bitmap.onEndReached.add(function () {
		if (end != null) {
			end();
		}
		video.destroy();
	});
	video.load(Paths.video(videoFile));
	return video;
}