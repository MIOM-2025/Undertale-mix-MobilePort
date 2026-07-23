import Math;
import BounceSmoke;
import overworld.DialogueBox;
import flixel.tweens.FlxTweenType;
import flixel.math.FlxMath;
import funkin.editors.charter.Charter;
import funkin.savedata.FunkinSave;

var p:String = 'stages/hotland/';
var map:FlxSprite = new FlxSprite().loadGraphic(Paths.image(p+'path'));
var smokeVent1:Array<FlxSprite> = [];
var smokeVent2:Array<FlxSprite> = [];
var bottomThing:Array<FlxSprite> = [];
var canEnd:Bool = false;

// var ventO:FlxSprite;
var box:DialogueBox = new DialogueBox(0, 0, this);
var generatedSmoke:Array<FlxSprite> = [];

function onStageXMLParsed() {
	camGame.antialiasing = false;
	
	map.screenCenter();
	
	var mapB:FlxSprite = new FlxSprite(map.x + 60, map.y + 40).loadGraphic(Paths.image(p+'pathbg'));
	add(mapB);
	
	for (i in 0...5) {
	
		var ventO:FlxSprite = new FlxSprite((map.x + 120) + (60 * i), map.y).loadGraphic(Paths.image(p+'ventoutl'));
		ventO.visible = (i % 2 == 0);
		
		var pillar:FlxSprite = new FlxSprite(ventO.x, ventO.y + 40).loadGraphic(Paths.image(p+'rockp'));
		pillar.visible = (i == 0 ? false : ventO.visible);
		add(pillar);
		
		var pillarExtend:FlxSprite = new FlxSprite(pillar.x, pillar.y + pillar.height).loadGraphic(Paths.image(p+'rockp'));
		pillarExtend.visible = pillar.visible;
		add(pillarExtend);
		
		add(ventO);
		
		var vent:FlxSprite = new FlxSprite(ventO.x + 20, ventO.y + 20).loadGraphic(Paths.image(p+'vent'), true, 20, 20);
		vent.animation.add('v', [0,1,0,2], 8, true);
		vent.animation.play('v', true);
		add(vent);
		vent.visible = ventO.visible;
		vent.flipX = (i == 4);
		
		if (vent.visible) {
			steamCreate(vent.x, vent.y);
		}

	}
	
		// for (i in 0...13) {
			// var scale:Float = 0.6 + (0.07 * i);
			// var smoke:FlxSprite = new FlxSprite((map.x + 248) + (i + 6), (map.y - (i + 6)) - 1 * i).loadGraphic(Paths.image(p+'smoke'));
			// smoke.scale.set(scale, scale);
			// smoke.updateHitbox();
			// smoke.offset.set(-10 * (i * 0.3), 10 * (i * 0.2));
			// smoke.offset.y -= 25;
			// smoke.alpha = 1 - (0.1 + (0.07 * i));
			// add(smoke);
			// smoke.visible = false;
			// smokeVent1.push(smoke);
		// }
		
		// for (i in 0...13) {
			// var scale:Float = 0.6 + (0.07 * i);
			// var smoke:FlxSprite = new FlxSprite((map.x + 382) + (i + 6), (map.y - (i + 6)) - 1 * i).loadGraphic(Paths.image(p+'smoke'));
			// smoke.scale.set(scale, scale);
			// smoke.updateHitbox();
			// smoke.offset.set(20 * (i * 0.3), 10 * (i * 0.2));
			// smoke.offset.y -= 25;
			// smoke.alpha = 1 - (0.1 + (0.07 * i));
			// add(smoke);
			// smoke.visible = false;
			// smokeVent2.push(smoke);
		// }
		for (i in 0...13) {
			var smoke:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/hotland/smoke'));
			smoke.ID = i;
			generatedSmoke.push(smoke);
		}
		
		for (i in 0...10) {
			var b:FlxSprite = new FlxSprite(map.x, map.y + map.height + (i / 10) * i).makeGraphic(FlxG.width, 100, FlxColor.RED);
			b.offset.y = -8;
			b.alpha = 0.02 * (i * 0.5);
			b.ID = i;
			// bottomThing.push(b);
			FlxTween.tween(b, {y: b.y - 50 * (i / 5)}, 1.5, {type: FlxTweenType.PINGPONG, startDelay: 0.05 * (i / 10), ease: FlxEase.quadInOut});
			add(b);
		}
		add(map);
		
		add(box);
		box.setupBox();
		
	var showPath:FlxSprite = new FlxSprite(map.x + 500, map.y).loadGraphic(Paths.image('stages/hotland/thing'));
	add(showPath);

		
	if (FunkinSave.getSongHighscore('vent', 'normal').date != null) {
		canEnd = true;
		sawDialogue = true;
	}
	// add(ventO);
}

var direction:String = 'up';
var time:Float;
function create() {
	time = (Conductor.crochet / 1000) * 2;
}

function postCreate() {
	playerStrums.characters[1].visible = false;
	dad.alpha = 0;
	camGame.followLerp = 0.15;
	
		remove(dad);
		insert(0, dad);
		dad.idleSuffix = '-arm';
	for (strumLine in strumLines.members) {
		if (strumLine.opponentSide) {
			for (note in strumLine.notes) {
				note.alpha = PlayState.opponentMode ? 1 : 0;
			}
			for (strum in strumLine) {
				strum.alpha = PlayState.opponentMode ? 1 : 0;
			}
		} else {
			if (PlayState.opponentMode) {
				for (note in strumLine.notes) {
					note.alpha = 0;
				}
				for (strum in strumLine) {
					strum.alpha = PlayState.opponentMode ? 0 : 1;
				}
			}
		}
		// for (
	}
}

var vented:Bool = false;
var venting:Bool = false;
var distance:Int = 120;
// function beatHit(beat:Int) {
	// if (beat % 5 == 0) {
		// FlxTween.tween(bf, {x: bf.x + (vented ? -distance : distance)}, (Conductor.crochet / 1000) * 2);
		// vented = !vented;
	// }
// }

var lastV:Int = 0;
var sine:Float = 0;
var mettatonFollow:Bool = false;
function update(elapsed:Float) {
	bf.animation.play(playerStrums.characters[1].animation.curAnim.name + '-' + direction, true, false, playerStrums.characters[1].animation.curAnim.curFrame);
	
	if (lastV != Conductor.getBeats(0, 4, -2)) {
		lastV = Conductor.getBeats(0, 4, -2);
		vent();
	}
	
	if (seeingDialogue && lastBoxState != box.active) {
		seeingDialogue = false;
		canEnd = true;
		camHUD.fade(FlxColor.BLACK, 2, false, function() {
			endSong();
		}, true);
		lastBoxState = box.active;
	}
	// sine++;
	// for (t in bottomThing) {
		// t.y += Math.cos(sine * t.ID);
	// }
}

function postUpdate(elapsed:Float) {
	// if (mettatonFollow) {
		// camGame.zoom = 1;
	// }
}

var lastBoxState:Bool = true;
var seeingDialogue:Bool = false;
var sawDialogue:Bool = false;
function onSongEnd(e) {
	if (!sawDialogue) {
		endingSong = true;
		canPause = false;
		for (strumLine in strumLines.members) {
			strumLine.vocals.stop();
			strumLine.vocals.pitch = 0;
		}
		inst.stop();
		inst.pitch = 0;
		vocals.stop();
		vocals.pitch = 0;

		
		FlxG.sound.play(Paths.sound('snd_phone'), Options.volumeSFX);
		box.setupDialogue([
			['*Ring...° Ring...', null, '0', 0.03],
			['*Oh my god...', 'alphys', '2', 0.03],
			['*I\'ve been trying to\nñreach you for so long!', 'alphys', '3', 0.03],
			['*S... °sorry if that took\nña while!', 'alphys', '14', 0.03],
			['*The vents system...°\nñI-it\'s kind of...°\nñ°archaic...', 'alphys', '13', 0.03],
			['*A-and...° Was Mettaton...°\nñS-singing, with you???', 'alphys', '10', 0.03],
			['*Umm... that\'s fine,\nñI-it\'s not important!', 'alphys', '11', 0.03],
			['*I c-cut off the steam to\nñthe area so y-you\nñknow...', 'alphys', '14', 0.03],
			['*Y-you...° could take a\nñbreak f-from all that\nñspinning...', 'alphys', '10', 0.03],
			['*I-I uh...° can\'t fix that\nñvent remotely...', 'alphys', '13', 0.03],
			['*So I-I\'ll have to send a\nñbot to do the job.', 'alphys', '13', 0.03],
			['*D-don\'t worry!°\n*It won\'t\nñtake long!', 'alphys', '9', 0.03],
			['*J-just...° hang in there!', 'alphys', '16', 0.03],
			['*You\'ll be able to\nñcontinue your journey in\nñn-no time!', 'alphys', '14', 0.03]
		]);
		seeingDialogue = true;
		sawDialogue = true;
	}
	if (!canEnd) {
		e.cancel();
	}
}

var dir = [
	0 => 'left',
	1 => 'down',
	2 => 'right',
	3 => 'up',
];
var curDirection:Int = 0;
function stepHit() {
	if (venting) {
		direction = dir.get(curDirection);
		curDirection++;
		if (curDirection > 3) {
			curDirection = 0;
		}
	}
}

var dontVent:Bool = false;
function vent() {
	if (dontVent) {
		return;
	}
	venting = true;
	steamEffect(bf.x + (vented ? 13 : 6), bf.y + 9, vented);
	FlxTween.tween(bf, {x: bf.x + (vented ? -distance : distance)}, time, {onComplete: function() {
		direction = (vented ? 'left' : 'right');
		venting = false;
	}});
	FlxTween.tween(bf, {y: bf.y - (distance / 2)}, time / 2, {ease: FlxEase.quadOut, onComplete: function() {
		FlxTween.tween(bf, {y: bf.y + (distance / 2)}, time / 2, {ease: FlxEase.quadIn});
	}});
	vented = !vented;
}

function steamCreate(whereX:Int, whereY:Int) {
	for (i in 0...2) {
		// trace('teataet');
		var steam:BounceSmoke = new BounceSmoke(whereX, whereY, 0.5, i > 0 ? 0.2 : 0);
		add(steam);
	}
}

var curSmoke:FlxSprite;
function steamEffect(whereX:Int, whereY:Int, ?rev:Bool = false) {
	for (curSmoke in generatedSmoke) {
		// curSmoke = generatedSmoke[i];
		remove(curSmoke);
		curSmoke.setPosition((whereX) + (curSmoke.ID + 6), (whereY - (curSmoke.ID + 6)) - 1 * curSmoke.ID);
		curSmoke.scale.set(0.46 + (0.07 * curSmoke.ID), 0.46 + (0.07 * curSmoke.ID));
		curSmoke.updateHitbox();
		curSmoke.offset.set((!rev ? -10 : 20) * (curSmoke.ID * 0.3), 10 * (curSmoke.ID * 0.2));
		curSmoke.offset.y -= 25;
		curSmoke.alpha = 1 - (0.1 + (0.07 * curSmoke.ID));
		insert(members.indexOf(bf) - 1, curSmoke);
		curSmoke.visible = false;
		curSmoke.angularVelocity = 500;
		FlxTween.tween(curSmoke, {y: curSmoke.y}, 0.02 * curSmoke.ID, {startDelay: 0.01 * curSmoke.ID, onComplete: function() {
			curSmoke.visible = true;
		}});
		FlxTween.tween(curSmoke, {x: curSmoke.x}, 0.65, {startDelay: 0.04 * curSmoke.ID, onComplete: function() {
			// smoke.destroy();
			curSmoke.visible = false;
		}});
	}
	
}

var flyTween:FlxTween;
function mettatonAppear() {
	// trace(dad);
	// if (t == 1) {
	dad.alpha = 1;
	// if (t == 0) {
	if (Charter.startHere) {
		dad.setPosition(dad.x + 30, dad.y - 90);
		flyTween = FlxTween.tween(dad, {x: dad.x + 60}, 1.6, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
		return;
	}
		FlxTween.tween(dad, {y: dad.y - 90}, 1, {ease: FlxEase.quadIn});
		FlxTween.tween(dad, {x: dad.x + 30}, 1, {ease: FlxEase.quadInOut, onComplete: function() {
			flyTween = FlxTween.tween(dad, {x: dad.x + 60}, 1.6, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
		}});
		
	// }
	// t++;
}

function mettCenter() {
	if (Charter.startHere) {
		return;
	}
	flyTween.cancel();
	FlxTween.tween(dad, {x: 860, y: 200}, 1, {ease: FlxEase.quadInOut});
}

function mettFollow() {
	if (Charter.startHere) {
		return;
	}
	FlxTween.tween(dad, {x: (vented ? 900 : 800)}, 1, {ease: FlxEase.quadInOut});
}

var verticalFloat:FlxTween;
function mettFlyOver() {
	if (Charter.startHere) {
		return;
	}
	verticalFloat = FlxTween.tween(dad, {y: dad.y - 10}, 1, {ease: FlxEase.quadInOut});
	FlxTween.tween(dad, {x: 1000}, 6, {ease: FlxEase.quadInOut, onComplete: function() {
		verticalFloat.cancel();
		remove(dad);
		insert(99999, dad);
		dad.y += 100;
		verticalFloat = FlxTween.tween(dad, {y: dad.y - 10}, 1, {ease: FlxEase.quadInOut});
		FlxTween.tween(dad, {x: 600}, 5, {ease: FlxEase.quadInOut, onComplete: function() {
			verticalFloat.cancel();
			remove(dad);
			insert(0, dad);
			dad.y -= 70;
			verticalFloat = FlxTween.tween(dad, {y: dad.y - 10}, 1, {ease: FlxEase.quadInOut});
			FlxTween.tween(dad, {x: 800}, 3, {ease: FlxEase.quadInOut, onComplete: function() {
			}});
		}});
	}});
}

function mettFlyAway() {
	// if (Charter.startHere) {
		// return;
	// }
	FlxTween.tween(dad, {x: dad.x + 100, y: dad.y - 400}, 2, {ease: FlxEase.quadInOut});
}

var upTween:FlxTween;
function mettatonReAppear() {
	// if (Charter.startHere) {
		// return;
	// }
	flyTween.cancel();
	dad.setPosition(1000, 180);
	verticalFloat = FlxTween.tween(dad, {y: dad.y - 10}, 1, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
	FlxTween.tween(dad, {x: 640}, 5, {ease: FlxEase.quadInOut, onComplete: function() {
		verticalFloat.cancel();
		// dad.x += 100;
		dad.y += 120;
		verticalFloat = FlxTween.tween(dad, {y: dad.y - 10}, 1, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
		remove(dad);
		insert(999999, dad);
		FlxTween.tween(dad, {x: 1100}, 5, {ease: FlxEase.sineInOut, onComplete: function() {
			verticalFloat.cancel();
			dad.y -= 100;
			verticalFloat = FlxTween.tween(dad, {y: dad.y - 10}, 1, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
			remove(dad);
			insert(0, dad);
			FlxTween.tween(dad, {x: 600}, 5, {ease: FlxEase.sineInOut, onComplete: function() {
				// FlxTween.tween(dad, {x: 860, y: 200}, 1, {ease: FlxEase.quadInOut});
				verticalFloat.cancel();
				dad.setPosition(860, 380);
				upTween = FlxTween.tween(dad, {y: 60}, 6, {ease: FlxEase.sineInOut, onComplete: function() {
					FlxTween.tween(dad, {y: 200}, 5, {ease: FlxEase.sineInOut, onComplete: function() {
						verticalFloat = FlxTween.tween(dad, {y: dad.y - 14}, 1, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
						FlxTween.tween(dad, {x: dad.x + 100}, 1, {ease: FlxEase.sineInOut, onComplete: function() {
							flyTween = FlxTween.tween(dad, {x: dad.x - 200}, 5, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
						}});
						// FlxTween.tween(dad
					}});
				}});
			}});
		}});
	}});
}

function setupMettLastPart() {
	flyTween.cancel();
	if (verticalFloat != null) {
		verticalFloat.cancel();
	}
	dad.setPosition(960, 180);
}

function mettLastPart() {
	FlxTween.tween(dad, {x: dad.x - 100}, 2, {ease: FlxEase.quadInOut, onComplete: function() {
		FlxTween.tween(dad, {y: dad.y + 20}, 2, {ease: FlxEase.quadOut});
		FlxTween.tween(dad, {x: dad.x - 50}, 2, {ease: FlxEase.quadInOut, onComplete: function() {
			FlxTween.tween(dad, {y: dad.y - 40}, 2, {ease: FlxEase.quadIn});
			FlxTween.tween(dad, {x: dad.x - 20}, 2, {ease: FlxEase.quadOut, onComplete: function() {
				FlxTween.tween(dad, {y: dad.y + 60}, 2, {ease: FlxEase.quadIn});
				FlxTween.tween(dad, {x: dad.x + 70}, 3, {ease: FlxEase.quadInOut, onComplete: function() {
					FlxTween.tween(dad, {y: dad.y - 36}, 3, {ease: FlxEase.quadInOut, onComplete: function() {
						verticalFloat = FlxTween.tween(dad, {y: dad.y - 14}, 1, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
						FlxTween.tween(dad, {x: dad.x - 100}, 2, {ease: FlxEase.quadInOut, startDelay: 2, onComplete: function() {
							flyTween = FlxTween.tween(dad, {x: dad.x + 200}, 2, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
						}});
					}});
				}});
			}});
		}});
	}});
}

function mettaStop() {
	flyTween.cancel();
	FlxTween.tween(dad, {x: 860}, 1, {ease: FlxEase.quadInOut});
}


function mettaFlyAwayEnding() {
	verticalFloat.cancel();
	FlxTween.tween(dad, {x: dad.x + 100, y: dad.y - 400}, 2, {ease: FlxEase.quadInOut});
}

function dontVent() {
	dontVent = !dontVent;
}

// functio