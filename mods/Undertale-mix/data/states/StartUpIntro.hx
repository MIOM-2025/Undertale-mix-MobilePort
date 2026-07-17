import UndertaleText;
import funkin.backend.utils.DiscordUtil;
import TypedBitmapText;

var camera:FlxCamera = new FlxCamera();
var typedText:TypedBitmapText;
var infoText:UndertaleText;
var canProceed:Bool = true;
var yea:Bool = true;
var picker:FlxSprite = new FlxSprite().loadGraphic(Paths.image('minigames/pong/ball'));
var yes:UndertaleText;
var no:UndertaleText;
function create() {
	DiscordUtil.changePresenceAdvanced({
		details: 'Getting started...',
	});
	

	FlxG.cameras.add(camera, false);
	camera.bgColor = FlxColor.TRANSPARENT;
	camera.antialiasing = false;
	camera.zoom = 3.0;
	camera.pixelPerfectRender = true;
	this.cameras = [camera];
	
	FlxG.sound.playMusic(Paths.music('menuthemes/startup'), 0.5, true);
	
	var text:UndertaleText = new UndertaleText(0, 0, '', 'left', FlxG.width, 0);
	
	infoText = new UndertaleText(450, 280, '--Information--', 'left', FlxG.width, 1, 'FFFFFF', 'undertale-pixel');
	infoText.alpha = 0.5;
	add(infoText);
	
	typedText = new TypedBitmapText(450, 280, 
		'\n \n \n*Hi, thanks for playing Undertale Mix!\n\nñBefore you start to actually play\nñthe mod we have to ask a few quick\nñquestions.:\n \n \n*This mod uses heavy flashing lights\nñin some songs which could trigger a seizure\nñor affect anyone with photosensitivity.\n \n*Do you want to keep flashing lights on?:\n \n \n*Like any Friday Night Funkin\' mod ever this\nñmod uses shaders.\n \n*Do you want to keep shaders on?:\n \n \n*With that out of the way we,\nñthe Undertale Mix team hope\nñyou enjoy the mod!', text.getFont('undertale-pixel'));
	typedText.setTextFormat(1, 'FFFFFF', FlxTextAlign.LEFT, FlxG.width);
	typedText.alpha = infoText.alpha;
	add(typedText);
	typedText.startTyping(0.03, null, true);
	
	yes = new UndertaleText(0, 300, 'Yes', 'left', FlxG.width, 1, 'FFFFFF', 'undertale-pixel');
	yes.autoSize = true;
	yes.updateHitbox();
	add(yes);
	yes.alpha = 1;
	
	no = new UndertaleText(yes.x + 50, yes.y, 'No', 'left', FlxG.width, 1, 'FFFFFF', 'undertale-pixel');
	no.autoSize = true;
	no.updateHitbox();
	add(no);
	no.alpha = yes.alpha;
	
	var total:Int = yes.width + 100 + no.width;
	yes.setPosition((FlxG.width - total) / 2, 444);
	no.setPosition(yes.x + 100, yes.y);
	
	picker.scale.set(0.5, 0.5);
	picker.updateHitbox();
	picker.setPosition((yes.x - picker.width) - 2, yes.y + 4);
	add(picker);
	
	yes.visible = no.visible = picker.visible = false;
	yes.color = FlxColor.YELLOW;
}

var canPick:Bool = false;
var textIndex:Int = 0;
var appearOnce:Bool = false;
var canActuallyPick:Bool = false;
var onlyMoveOnce = true;
var okNo:Bool = false;
function update(elapsed:Float) {
	if (typedText != null) {
		typedText.textUpdate(elapsed);
	}
	
	if (!typedText.typing && !okNo) {
		if (textIndex == 2) {
			canPick = true;
		}
		canProceed = true;
		appearOnce = true;
	}
	
	if (!typedText.typing && !canProceed && !appearOnce) {
		trace('hi');
		yes.visible = no.visible = picker.visible = true;
		appearOnce = true;
		canActuallyPick = true;
		picker.visible = false;
		okNo = true;
	}
	
	
	if (!canProceed && canPick) {
		okNo = true;
		if (controls.ACCEPT || FlxG.keys.justPressed.Z) {
			if (canActuallyPick) {
				if (textIndex == 2) {
					FlxG.save.data.flashingLights = yea;
					FlxG.save.flush();
					
				} else if (textIndex == 3) {
					Options.gameplayShaders = yea;
					FlxG.save.flush();
				}
				appearOnce = false;
				typedText.advanceDialogue();
				yes.visible = no.visible = picker.visible = false;
				FlxG.sound.play(Paths.sound('select'), Options.volumeSFX);
				textIndex++;
				canActuallyPick = false;
				if (textIndex == 4) {
					canPick = false;
					canProceed = true;
				}
				
			} else {
				// canActuallyPick = true;
				typedText.advanceDialogue();
			}
		} else if (controls.LEFT_P) {
			FlxG.sound.play(Paths.sound('squeak'), Options.volumeSFX);
			yea = true;
			picker.setPosition((yes.x - picker.width) - 2, yes.y + 4);
			yes.color = FlxColor.YELLOW;
			no.color = FlxColor.WHITE;
		} else if (controls.RIGHT_P) {
			FlxG.sound.play(Paths.sound('squeak'), Options.volumeSFX);
			yea = false;
			picker.setPosition((no.x - picker.width) - 2, no.y + 4);
			no.color = FlxColor.YELLOW;
			yes.color = FlxColor.WHITE; 
		}
		return;
	}
	
	if (controls.ACCEPT || FlxG.keys.justPressed.Z) {
		if (!typedText.typing) {
			trace('hey');
			textIndex++;
				
			if (textIndex == 2) {
				canProceed = false;
				canPick = true;
			}
		}
		if (typedText.active && canProceed) {
			typedText.advanceDialogue();

		} else if (!typedText.active && !canProceed) {
			// if (textIndex) {
				
			// }
		} else if (!typedText.active && canProceed) {
			FlxTween.tween(typedText, {x: typedText.x - 500, alpha: 0}, 0.5, {ease: FlxEase.cubeInOut, onComplete: function() {
				FlxG.switchState(new ModState('StartUp', 'startup'));
			}});
			FlxTween.tween(infoText, {alpha: 0}, 0.5, {ease: FlxEase.cubeInOut});
		}
	}

	

}