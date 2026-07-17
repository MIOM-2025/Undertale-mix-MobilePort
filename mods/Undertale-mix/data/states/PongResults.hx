import UndertaleText;
import funkin.backend.utils.DiscordUtil;

function create() {
	var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	bg.screenCenter();
	bg.alpha = 0.5;
	add(bg);
	
	var you:UndertaleText = new UndertaleText(0, 200, 'YOU...', 'left', FlxG.width, 2);
	you.autoSize = true;
	you.updateHitbox();
	you.screenCenter(FlxAxes.X);
	add(you);
	
	var result:UndertaleText = new UndertaleText(0, you.y + 50, data.playerWin ? 'WON' : 'LOST', 'left', FlxG.width, 4, data.playerWin ? 'FFFF00' : 'FF0000');
	result.autoSize = true;
	result.updateHitbox();
	result.screenCenter(FlxAxes.X);
	add(result);
	
	var sub:UndertaleText = new UndertaleText(0, result.y + 200, data.playerWin ? 'yay' : 'HOW COULD YOU LOSE THAT', 'left', FlxG.width, 1);
	sub.autoSize = true;
	sub.updateHitbox();
	sub.screenCenter(FlxAxes.X);
	sub.alpha = 0.5;
	add(sub);
	
	var control:UndertaleText = new UndertaleText(0, sub.y + 40, 'press enter to try again or escape to exit to pong menu' + (data.playerWin ? '!' : ' ok just get out'), 'left', FlxG.width, 1);
	control.autoSize = true;
	control.updateHitbox();
	control.screenCenter(FlxAxes.X);
	control.alpha = 0.5;
	add(control);
	
	DiscordUtil.changePresenceAdvanced({
		state: FlxG.save.data.playerName + ' ' + (data.playerWin ? 'won!' : 'lost.'),
		details: 'Minigame results!'
	});
}

function update() {
	if (FlxG.keys.justPressed.ENTER) {
		FlxG.switchState(new ModState('PongState'));
	} else if (FlxG.keys.justPressed.ESCAPE) {
		FlxG.switchState(new ModState('PongTitle'));
	}
}