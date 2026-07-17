import UndertaleText;
import flixel.addons.display.FlxBackdrop;
import funkin.backend.utils.DiscordUtil;

var minigames:Array<Dynamic> = [];
var buttons:Array<UndertaleText> = [];
var texts:Array<String> = [
	'dont even ask',
	'whatever man',
	'i was bored',
	'play some actually good games',
];
var theme:FlxSound;
var transitionTime:Float = 0.25;
var soul:FlxSprite = new FlxSprite().loadGraphic(Paths.image('minigames/pong/ball'));
var gameSelected:Int = 0;
var themeVolume:Float = 1;
function create() {
	DiscordUtil.changePresenceAdvanced({
		state: 'Choosing a minigame to play',
		details: 'Minigame time!'
	});

	battleBackdrop = new FlxBackdrop(Paths.image('credits/background'), FlxAxes.XY);
	battleBackdrop.scale.set(1.5, 1.5);
	battleBackdrop.velocity.set(30, 0);
	battleBackdrop.antialiasing = false;
	// battleBackdrop.alpha = 0.5;
	add(battleBackdrop);
	
	battleBackdrop.cameras = [FlxG.camera];
	
	var vig = new FlxSprite().loadGraphic(Paths.image('minigames/vig'));
	vig.setGraphicSize(FlxG.width, FlxG.height);
	vig.updateHitbox();
	vig.screenCenter();
	// add(vig);
	
	themeVolume = Options.volumeMusic;
	theme = FlxG.sound.load(Paths.music('menuthemes/minigames'), themeVolume, true);
	theme.play();
	
	if (data != null && data == 'mainmenu') {
		FlxG.camera.zoom = 0.1;
		FlxG.camera.alpha = 0;
		battleBackdrop.alpha = 0;
		FlxTween.tween(FlxG.camera, {zoom: 1, alpha: 1}, transitionTime, {ease: FlxEase.cubeInOut, onComplete: function() {
			FlxTween.tween(battleBackdrop, {alpha: 0.5}, transitionTime / 2);
		}});
		

		theme.volume = 0;
		FlxG.sound.defaultMusicGroup.add(theme);
		FlxG.sound.music.volume = 0;
		
		theme.fadeIn(transitionTime, 0, themeVolume);
	}

	var title:UndertaleText = new UndertaleText(0, 44, 'MINIGAMES', 'left', FlxG.width, 3, 'FFFFFF');
	title.autoSize = true;
	title.updateHitbox();
	title.screenCenter(FlxAxes.X);
	add(title);
	
	var subtitle:UndertaleText = new UndertaleText(0, title.y + title.height / 1, texts[FlxG.random.int(0, texts.length - 1)], 'left', FlxG.width, 1, 'FFFFFF');
	subtitle.alpha = 0.5;
	subtitle.y -= 1;
	subtitle.autoSize = true;
	subtitle.updateHitbox();
	subtitle.screenCenter(FlxAxes.X);
	// subtitle.y = ;
	add(subtitle);
	
	if (FlxG.save.data.pong_unlock != null) {
		minigames.push(['soul pong', 'pong', 'PongTitle']);
	}
	if (FlxG.save.data.run_unlock != null) {
		minigames.push(['soul runner', 'run', 'SoulRunnerTitle']);
	}
	// minigames.push(['flappy soul', 'pong', 'FlappySoul']);
	// minigames.push(['kill toby fox', 'pong', 'KillTobyFox']);
	
	var index:Int = 0;
	for (minigame in minigames) {
		var game:UndertaleText = new UndertaleText(0, 233 + (99 * index), minigame[0].toUpperCase(), 'left', FlxG.width, 2, 'FFFFFF');
		game.autoSize = true;
		game.updateHitbox();
		game.screenCenter(FlxAxes.X);
		game.ID = index;
		add(game);
		
		var icon:FlxSprite = new FlxSprite(0, game.y - 6).loadGraphic(Paths.image('minigames/icon_' + minigame[1]));
		icon.antialiasing = false;
		icon.scale.set(0.5, 0.5);
		icon.updateHitbox();
		add(icon);
		
		var total:Float = game.width + 10 + icon.width;
		game.setPosition((FlxG.width - total) / 2, game.y);
		icon.x = (game.x + game.width) + 10;
		
		buttons.push(game);
		

		// icon.setPosition((FlxG.width - total) / 2, icon.y);
		
		index++;
	}
	
	var colors = [
		'determination' => 'FF0000',
		'patience' => '42FCFF',
		'bravery' => 'FCA600',
		'integrity' => '003CFF',
		'perseverance' => 'D535D9',
		'kindness' => '00C000',
		'justice' => 'FFFF00'
	];
	var thisColor:String = FlxG.save.data.soulColor;
	thisColor ??= 'determination';
	var soulColor:String = colors[thisColor];
	soul.color = FlxColor.fromString('#' + soulColor);
	soul.scale.set(2, 2);
	soul.updateHitbox();
	add(soul);
	
	selection();
	// var
}

function postCreate() {
}

var press:Bool = true;
function update() {
	if (!press) {
		return;
	}

	if (controls.ACCEPT) {
		FlxG.switchState(new ModState(minigames[gameSelected][2]));
	} else if (controls.UP_P) {
		selection(-1);
	} else if (controls.DOWN_P) {
		selection(1);
	}

	if (controls.BACK) {
		press = false;
		theme.fadeIn(transitionTime, themeVolume, 0);
		FlxTween.tween(battleBackdrop, {alpha: 0}, transitionTime / 2);
		if (FlxG.sound.music != null) {
			FlxG.sound.music.fadeIn(transitionTime * 1.2, 0, Options.volumeMusic);
		}
		FlxTween.tween(FlxG.camera, {zoom: 0.1, alpha: 0}, transitionTime, {ease: FlxEase.cubeInOut, onComplete: function() {
			FlxG.switchState(new ModState('ModMainMenu', 'minigames'));
		}});
			
	}
}

function selection(?v:Int) {
	if (v != null) {
		gameSelected += v;
		FlxG.sound.play(Paths.sound('squeak'), Options.volumeSFX);
		if (gameSelected > buttons.length - 1) {
			gameSelected = 0;
		} else if (gameSelected < 0) {
			gameSelected = buttons.length - 1;
		}
	}
	
	for (button in buttons) {
		button.color = button.ID == gameSelected ? FlxColor.YELLOW : FlxColor.WHITE;
		if (button.ID == gameSelected) {
			soul.setPosition(button.x - 50, button.y + 14);
		}
	}
}