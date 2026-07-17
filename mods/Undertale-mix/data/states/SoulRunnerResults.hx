import UndertaleText;
import Math;
import funkin.backend.utils.DiscordUtil;

var canExit:Bool = false;
function create() {
	// DiscordUtil.changePresenceAdvanced({
		// state: '',
		// details: 'Minigame time!'
	// });

	var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	bg.screenCenter();
	bg.alpha = 0.8;
	add(bg);
	
	var title:UndertaleText = new UndertaleText(0, 250, 'game ovah', 'left', FlxG.width, 2.5, 'FFFFFF');
	title.autoSize = true;
	title.screenCenter(FlxAxes.X);
	add(title);
	
	var score:UndertaleText = new UndertaleText(title.x, title.y + 100, 'YOU GOT: ' + Math.round(data.totalPoints), 'left', FlxG.width, 2, 'FFFF00');
	score.autoSize = true;
	score.screenCenter(FlxAxes.X);
	add(score);
	
	var taking:UndertaleText = new UndertaleText(title.x, score.y + 70, 'and im taking...', 'left', FlxG.width, 1.5, 'FFFFFF');
	taking.autoSize = true;
	taking.screenCenter(FlxAxes.X);
	add(taking);
	
	var control:UndertaleText = new UndertaleText(0, taking.y + 74, 'press enter to try again or escape to exit to run menu', 'left', FlxG.width, 1.5);
	control.autoSize = true;
	control.updateHitbox();
	control.screenCenter(FlxAxes.X);
	control.alpha = 0.5;
	add(control);
	control.alpha = 0;
	FlxTween.tween(taking, {y: taking.y}, 1.5, {onComplete: function() {
		if (data.maxHP > 1) {
			FlxTween.tween(taking, {y: score.y}, 0.1, {onComplete: function() {
				score.text = 'YOU GOT: ' + Math.round(data.totalPoints / data.maxHP);
				taking.text = 'and im taking ' + (Math.round(data.totalPoints) - Math.round(data.totalPoints / data.maxHP)) + ' points from you';
				taking.updateHitbox();
				taking.screenCenter();
				FlxTween.tween(taking, {y: score.y + 74}, 0.1, {onComplete: function() {
					control.alpha = 0.5;
					canExit = true;
				}});
				if (FlxG.save.data.runnerHighScore != null) {
					if (Math.round(data.totalPoints / data.maxHP) > FlxG.save.data.runnerHighScore) {
						FlxG.save.data.runnerHighScore = Math.round(data.totalPoints / data.maxHP);
					}
				} else if (FlxG.save.data.runnerHighScore == null) {
					FlxG.save.data.runnerHighScore = Math.round(data.totalPoints / data.maxHP);
				}
			}});
		} else {
			taking.text = 'nothing cause you only got 1 hp lol';
			control.alpha = 0.5;
			canExit = true;
		}
	}});
	
	DiscordUtil.changePresenceAdvanced({
		state: 'Died with ' + Math.round(data.totalPoints / data.maxHP) + ' points.',
		details: 'Minigame results!'
	});
}

function update() {
	if (canExit) {
		if (FlxG.keys.justPressed.ENTER) {
			FlxG.switchState(new ModState('SoulRunner'));
		} else if (FlxG.keys.justPressed.ESCAPE) {
			FlxG.switchState(new ModState('SoulRunnerTitle'));
		}
	}
}