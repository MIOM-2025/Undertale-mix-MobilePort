import Date;
import flixel.FlxState;
import funkin.backend.MusicBeatState;
import funkin.backend.FunkinText;
import funkin.backend.utils.DiscordUtil;

var time:Int = 0;
var redirectStates:Map<FlxState, Dynamic> = [
    TitleState => 'ModTitle',
	MainMenuState => 'ModMainMenu',
	FreeplayState => 'MixedFreeplayState',
];
function preStateSwitch() {
    for (redirectState in redirectStates.keys()) 
        if (Std.isOfType(FlxG.game._requestedState, redirectState))  {
            var State = redirectStates.get(redirectState);
            FlxG.game._requestedState = Std.isOfType(new State(), FlxState) ? new State() : new ModState(redirectStates.get(redirectState));
        }
}

function postCreate() {
	if (FlxG.save.data.timePlayed == null) {
		time = 0;
	}
	time = FlxG.save.data.timePlayed;
}

var lastSecond:Int = 0;
function update(elapsed:Float) {
	if (lastSecond != Date.now().getSeconds()) {
		FlxG.save.data.timePlayed++;
		time = FlxG.save.data.timePlayed;
		lastSecond = Date.now().getSeconds();
	}
}

function destroy() {
	FlxG.save.data.timePlayed = time;
}