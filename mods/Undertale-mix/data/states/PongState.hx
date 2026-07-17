import UndertaleText;
import funkin.backend.utils.DiscordUtil;

var ball:FlxSprite = new FlxSprite().loadGraphic(Paths.image('minigames/pong/ball'));
var paddle1:FlxSprite = new FlxSprite().loadGraphic(Paths.image('minigames/pong/paddle'));
var paddle2:FlxSprite = new FlxSprite().loadGraphic(Paths.image('minigames/pong/paddle'));
var playerPaddle:FlxSprite;
var nonPlayerPaddle:FlxSprite;
var ballSpeed:Int = 200;
//Counters.
var playerScore:Int = 0;
var playerScoreText:UndertaleText = new UndertaleText(770, 60, '0', 'left', FlxG.width, 3);
var opponentScore:Int = 0;
var opponentScoreText:UndertaleText = new UndertaleText(playerScoreText.x - 300, playerScoreText.y, '0', 'left', FlxG.width, 3);
//Other.
var pointsToWin:Int = 10;
function create() {
	FlxG.camera.zoom = 1;
	FlxG.camera.antialiasing = false;
	
	DiscordUtil.changePresenceAdvanced({
		state: 'Playing Pong (0 : 0)',
		details: 'Minigame time!'
	});
	
	for (i in 0...20) {
		var line:FlxSprite = new FlxSprite(0, 0 + (40 * i)).makeGraphic(1, 5, FlxColor.WHITE);
		line.scale.set(3, 3);
		line.screenCenter(FlxAxes.X);
		add(line);
	}
	
	playerScoreText.autoSize = true;
	playerScoreText.updateHitbox();
	playerScoreText.alpha = 0.5;
	add(playerScoreText);
	
	opponentScoreText.autoSize = true;
	opponentScoreText.updateHitbox();
	opponentScoreText.alpha = 0.5;
	add(opponentScoreText);
	
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
	ball.color = FlxColor.fromString('#' + soulColor);
	ball.scale.set(1.5, 1.5);
	ball.updateHitbox();
	ball.screenCenter();
	add(ball);
	
	paddle1.scale.set(2, 2.5);
	paddle1.updateHitbox();
	paddle1.screenCenter(FlxAxes.Y);
	add(paddle1);
	
	paddle2.scale.set(paddle1.scale.x, paddle1.scale.y);
	paddle2.updateHitbox();
	paddle2.screenCenter(FlxAxes.Y);
	paddle2.x = FlxG.width - paddle2.width;
	paddle2.flipX = true;
	add(paddle2);
	
	playerPaddle = paddle2;
	nonPlayerPaddle = paddle1;
	
	ballSpeed *= FlxG.random.float(1, 2);
	ball.velocity.set(ballSpeed * (FlxG.random.bool(50) ? 1 : -1), (ballSpeed / 3) * (FlxG.random.bool(50) ? 1 : -1));
	ball.angularVelocity = ball.velocity.x / 2;
	
	if (FlxG.save.data.pongWinCondition != null) {
		pointsToWin = FlxG.save.data.pongWinCondition;
	}
}
var baseMovementValue:Int = 400;
var movementValue:Float = 0;
function update(elapsed:Float) {
	movementValue = baseMovementValue * elapsed;
	
	if (controls.UP) {
		playerPaddle.y -= movementValue;
	} else if (controls.DOWN) {
		playerPaddle.y += movementValue;
	}
	nonPlayerPaddle.y += movementValue * (ball.y < nonPlayerPaddle.y ? -1 : 1);
}

var lost:Bool = false;
var playerLost:Bool = false;
var opponentLost:Bool = false;
function postUpdate(elapsed:Float) {
	if (playerPaddle.y < 0) {
		playerPaddle.y = 0;
	} else if (playerPaddle.y > FlxG.height - playerPaddle.height) {
		playerPaddle.y = (FlxG.height - playerPaddle.height);
	}
	
	if (nonPlayerPaddle.y < 0) {
		nonPlayerPaddle.y = 0;
	} else if (nonPlayerPaddle.y > FlxG.height - nonPlayerPaddle.height) {
		nonPlayerPaddle.y = FlxG.height - nonPlayerPaddle.height;
	}
	
	if (ball.y > FlxG.height - ball.height) {
		ball.y = FlxG.height - ball.height;
		ballBounce();
		ball.velocity.y *= -1;
	} else if (ball.y < 0) {
		ball.y = 0;
		ballBounce();
		ball.velocity.y *= -1;
	}
	
	if (ball.x > paddle2.x - paddle2.width) {
		if (!lost) {
			if (ball.y > (paddle2.y - 6) && ball.y < (paddle2.y + paddle2.height)) {
				ball.x = paddle2.x - paddle2.width;
				
				ballBounce();
				ball.velocity.x *= -1;
				ball.velocity.y *= (ball.y > paddle2.y - (paddle2.height / 2) ? 1 : -1);
			} else {
				lost = true;
				
				playerLost = true;
			}
		}
	}
	
	if (ball.x < paddle1.x + paddle1.width) {
		if (!lost) {
			if (ball.y > (paddle1.y - 6) && ball.y < (paddle1.y + paddle1.height)) {
				ball.x = paddle1.x + paddle1.width;
				
				ballBounce();
				ball.velocity.x *= -1;
				ball.velocity.y *= (ball.y > paddle1.y - (paddle1.height / 2) ? 1 : -1);
			} else {
				lost = true;
				
				opponentLost = true;
			}
		}
	}
	
	if ((ball.x < (0 - paddle1.width) || ball.x > FlxG.width) && lost) {
		FlxG.sound.play(Paths.sound(opponentLost ? 'snd_dumbvictory' : 'snd_wrongvictory'), Options.volumeSFX);
	
		if (opponentLost) {
			playerScore += 1;
			playerScoreText.text = playerScore;
		} else {
			opponentScore += 1;
			opponentScoreText.text = opponentScore;
		}
		
		DiscordUtil.changePresenceAdvanced({
			state: 'Playing Pong (' + opponentScore + ' : ' + playerScore + ')',
			details: 'Minigame time!'
		});
		
		if (playerScore >= pointsToWin || opponentScore >= pointsToWin) {
			persistentUpdate = false;
			persistentDraw = true;
			openSubState(new ModSubState('PongResults', {playerWin: playerScore >= pointsToWin, opponentWin: opponentLost >= pointsToWin}));
		}
	
		ball.screenCenter();
		
		ballSpeed = 200;
		ballSpeed *= FlxG.random.float(1, 2);
		ball.velocity.set(ballSpeed * (FlxG.random.bool(50) ? 1 : -1), (ballSpeed / 3) * (FlxG.random.bool(50) ? 1 : -1));
		ball.angularVelocity = ball.velocity.x / 2;
		
		playerLost = false;
		opponentLost = false;
		
		lost = false;
	}
}

function ballBounce() {
	// if (!opponentLost) {
		FlxG.sound.play(Paths.sound('snd_noise'), Options.volumeSFX);
	// } else if (opponentLost) {
		// FlxG.sound.play(Paths.sound('snd_victory'), Options.volumeSFX);
	// }
	
	ball.velocity.x *= 1.1;
	ball.velocity.y *= 1.1;
	
	ball.angularVelocity = ball.velocity.x / 2;
}