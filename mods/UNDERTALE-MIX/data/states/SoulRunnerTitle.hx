import funkin.backend.utils.DiscordUtil;
import UndertaleText;

var options:Array<String> = ['play', 'exit', 'options'];
var buttons:Array<UndertaleText> = [];
var soul:FlxSprite;
var fakeSoul:FlxSprite = new FlxSprite();
var selected:Int = 0;
var soul:FlxSprite = new FlxSprite();
var quotes:Array<String> = [
	'ok what???',
	'i mean ok',
	'this one took a bit longer',
	'i tried making the google dinosaur game but i fucked up',
	' y',
	'did you know'
];
function create() {
	DiscordUtil.changePresenceAdvanced({
		state: 'Getting ready to run.',
		details: 'Minigame time!'
	});

	var floor:FlxSprite = new FlxSprite(0, 530).makeGraphic(FlxG.width, 8);
	add(floor);
	
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
	var actualColor:FlxColor = FlxColor.fromString('#' + soulColor);
	fakeSoul.color = actualColor;
	fakeSoul.frames = Paths.getAsepriteAtlas('minigames/runner/soul');
	fakeSoul.animation.addByPrefix('s', 'still0', 12, true);
	fakeSoul.animation.play('s', true);
	fakeSoul.scale.set(3, 3);
	fakeSoul.updateHitbox();
	fakeSoul.flipX = true;
	// add(fakeSoul);
	fakeSoul.setPosition(floor.x + 100, floor.y - fakeSoul.height);
	
	soul = new FlxSprite().loadGraphic(Paths.image('minigames/pong/ball'));
	soul.scale.set(2, 2);
	soul.updateHitbox();
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

	var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	bg.screenCenter();
	bg.alpha = 0.5;
	add(bg);
	
	var title:UndertaleText = new UndertaleText(0, 150, 'SOUL RUNNER', 'left', FlxG.width, 3, 'FFFF00');
	title.autoSize = true;
	title.screenCenter(FlxAxes.X);
	add(title);
	
	var subtitle:UndertaleText = new UndertaleText(0, (title.y + title.height) + 30, quotes[FlxG.random.int(0, quotes.length - 1)], 'left', FlxG.width, 1);
	subtitle.alpha = 0.5;
	subtitle.autoSize = true;
	subtitle.screenCenter(FlxAxes.X);
	add(subtitle);
	
	var high:UndertaleText = new UndertaleText(0, subtitle.y + 50, 'highest score: ', 'left', FlxG.width, 1.5);
	high.autoSize = true;
	high.screenCenter(FlxAxes.X);
	add(high);
	if (FlxG.save.data.runnerHighScore == null) {
		high.text = 'highest score... play the game first';
	} else {
		high.text = 'highest score: ' + FlxG.save.data.runnerHighScore;
	}
	high.screenCenter(FlxAxes.X);

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
	
	add(soul);
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
				FlxTween.tween(soul.scale, {x: 3, y: 3}, 1);
				FlxTween.tween(soul, {x: fakeSoul.x + 8, y: fakeSoul.y + 8}, 1, {ease: FlxEase.cubeInOut, onComplete: function() {
					FlxG.switchState(new ModState('SoulRunner'));
				}});
			case 'exit':
				FlxG.switchState(new ModState('MiniGamesMenuState'));
			case 'options':
				openSubState(new ModSubState('OptionSubstateSubstate', [
					{
						type: 'slider',
						title: 'Health Points',
						description: '*How many hits you can take./*Also divides your final score.',
						defaultValue: 3,
						parentValue: 'runnerHealth',
						valueSuffix: 'hp',
						max: 20,
						min: 1,
						valueStep: 1,
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