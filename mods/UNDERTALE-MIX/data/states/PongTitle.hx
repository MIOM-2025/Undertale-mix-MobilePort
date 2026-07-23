import UndertaleText;
import funkin.backend.utils.DiscordUtil;

var options:Array<String> = ['play', 'exit', 'options'];
var buttons:Array<UndertaleText> = [];
var soul:FlxSprite;
var selected:Int = 0;
var quotes:Array<String> = [
	'fuck the game lets play pong',
	'we all need a game of pong once in a while',
	'hi lol',
	'how it feels to consume queer people and gain their powers',
	'i be hard at work doing this shit',
	'winning at pong feels better than sex',
	'pong is my life',
	'if you dont like pong then go kill yourself',
	'fuck all of you who dont like pong ok',
	'this is what we were made for',
	'god didnt give us fingers to play an irrelevant shitty ddrr clone from 2020',
	'i coded this in 3 hours and im proud',
	'..-. .- --. --. --- -',
	'my soul is trapped here how do i get out',
	'what a clusterfuck',
	'it tung tung tung sahurts',
];
function create() {
	DiscordUtil.changePresenceAdvanced({
		state: 'Getting ready to play pong...',
		details: 'Minigame time!'
	});

	var title:UndertaleText = new UndertaleText(0, 150, 'SOUL PONG', 'left', FlxG.width, 3, 'FFFF00');
	title.autoSize = true;
	title.screenCenter(FlxAxes.X);
	add(title);
	
	var subtitle:UndertaleText = new UndertaleText(0, (title.y + title.height) + 30, quotes[FlxG.random.int(0, quotes.length - 1)], 'left', FlxG.width, 1);
	subtitle.alpha = 0.5;
	subtitle.autoSize = true;
	subtitle.screenCenter(FlxAxes.X);
	add(subtitle);
	
	var index:Int = 0;
	for (option in options) {
		var button:UndertaleText = new UndertaleText(280 + (300 * index), 600, option.toUpperCase(), 'left', FlxG.width, 2);
		button.autoSize = true;
		button.updateHitbox();
		add(button);
		button.ID = index;
		buttons.push(button); 	
		index++;
	}
	
	soul = new FlxSprite().loadGraphic(Paths.image('minigames/pong/ball'));
	soul.scale.set(2, 2);
	soul.updateHitbox();
	add(soul);
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
	
	selection();
} 

var inOptions:Bool = false;
var transition:Bool = false;
function update() {
	if (transition) {
		return;
	}

	if (inOptions) {
		if (controls.BACK) {
			inOptions = false;
		}
		return;
	}
	
	if (controls.ACCEPT) {
		FlxG.sound.play(Paths.sound('select'), Options.volumeSFX);
	
		var option:String = options[selected];
		switch (option) {
			case 'play':
				transition = true;
				FlxTween.tween(soul.scale, {x: 1.5, y: 1.5}, 1);
				FlxTween.tween(soul, {x: FlxG.width / 2, y: FlxG.height / 2}, 1, {ease: FlxEase.cubeInOut, onComplete: function() {
					FlxG.switchState(new ModState('PongState'));
				}});
			case 'exit':
				FlxG.switchState(new ModState('MiniGamesMenuState'));
			case 'options':
				openSubState(new ModSubState('OptionSubstateSubstate', [
					{
						type: 'slider',
						title: 'Score to Win',
						description: '*How many points either side/ñneeds to win.',
						defaultValue: 10,
						parentValue: 'pongWinCondition',
						valueSuffix: 'points',
						max: 100,
						min: 1,
						valueStep: 1,
					},
					{
						type: 'choice',
						title: 'Ball Start',
						description: '*Who starts after scoring a/ñpoint.',
						defaultValue: 0,
						parentValue: 'ballPlayerStart',
						choices: ['random', 'alternate between', 'player who scored', 'player who lost'],
					}
				]));
				inOptions = true;
		}
	} else if (controls.RIGHT_P) {
		selection(1);
	} else if (controls.LEFT_P) {
		selection(-1);
	}
}

function selection(?v:Int) {
	if (v != null) {
		selected += v;
		
		FlxG.sound.play(Paths.sound('squeak'), Options.volumeSFX);
		if (selected > buttons.length - 1) {
			selected = buttons.length - 1;
		} else if (selected < 0) {
			selected = 0;
		}
	}
	
	for (button in buttons) {
		button.color = button.ID == selected ? FlxColor.YELLOW : FlxColor.WHITE;
		if (button.ID == selected) {
			soul.setPosition((button.x - soul.width) - soul.width / 2, button.y + soul.height / 2);
		}
	}
}