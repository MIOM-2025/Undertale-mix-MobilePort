import UndertaleText;
import TypedBitmapText;

import flixel.addons.display.FlxGridOverlay;
import flixel.input.mouse.FlxMouseEvent;
import flixel.input.mouse.FlxMouseEventManager;

import funkin.editors.ui.UIState;
import funkin.editors.ui.UITextBox;
import funkin.editors.charter.CharterSelection;
import funkin.editors.character.CharacterSelection;
import funkin.editors.stage.StageSelection;

var menuSelected:Int = 0;
var modMenus = [
	['Freeplay Song Editor', 'Use this to add songs/in the freeplay menu.    /Instead of editing the/raw .json.'],
	['Credits Editor', 'Make new or edit/credit entries here.    /Instead of just/editing a .json.'],
	['Overworld Levels', 'Enter overworld/sections without/having to reset your/data.'],
	['Text Debug', ' '],
	['Trailer Thing', 'awagga'],
	['Chart Editor', 'Base Codename Engine/charter.    /Chart your songs/here.'],
	['Character Editor', 'Base Codename Engine/character editor, add/or change characters/here.'],
	['Stage Editor', 'Base Codename Engine/stage editor, edit/or add stages here.']
];
var menuObjects:FlxTypedGroup<UndertaleText> = new FlxTypedGroup();
var talker:FlxSprite;
var talkerBox:FlxSprite;
var talkerText:TypedBitmapText;
var miniCutscene:Bool = false;
var sawMiniCutscene:Bool = false;
var intervention:Bool = false;
var pressed:Int = 0;
var pressedMax:Int = 0;
var weirdName:Bool = false;
var nameBox:UITextBox;

function create() {
	weirdName = FlxG.save.data.playerName.length > 6;
	pressedMax = (weirdName ? 0 : 20);

	var bg:FlxSprite = FlxGridOverlay.create(39, 39, -1, -1, true, 0xFF68A8D8, 0xFF80D890);
	add(bg);
	
	var topBar:FlxSprite = new FlxSprite(94, 73).makeGraphic(413, 5, FlxColor.WHITE);
	add(topBar);
	topBar.alpha = 0.8;
	var topName:UndertaleText = new UndertaleText(topBar.x + 512, topBar.y - 30, 'Mod Editors', 'left', FlxG.width, 1.8);
	topName.alpha = topBar.alpha;
	add(topName);
	
	var bottomBar:FlxSprite = new FlxSprite(94, 348).makeGraphic(413, 5, FlxColor.WHITE);
	add(bottomBar);
	bottomBar.alpha = 0.8;
	var bottomName:UndertaleText = new UndertaleText(bottomBar.x + 512, bottomBar.y - 30, 'Base Engine Editors', 'left', FlxG.width, 1.8);
	bottomName.alpha = bottomBar.alpha;
	add(bottomName);
	
	add(menuObjects);
	
	var id:Int = 0;
	for (menu in modMenus) {
		var text:UndertaleText = new UndertaleText(607, 91 + (46 * (id > 4 ? id + 1 : id)), menu[0], 'left', FlxG.width, 1.8);
		text.ID = id;
		menuObjects.add(text);
		id++;
	}
	
	
	// talker = new FlxSprite(78, 624).loadGraphic(Paths.image('title/thetalker'), true, 31, 32);
	// talker.antialiasing = false;
	// talker.scale.set(3, 3);
	// talker.updateHitbox();
	// talker.animation.add('talk', [1, 0], 6, true);
	// talker.animation.add('shut', [0], 0, false);
	// add(talker);
	
	talker = new FlxSprite(74, 624);
	talker.frames = Paths.getAsepriteAtlas('title/d');
	talker.antialiasing = false;
	talker.scale.set(3, 3);
	talker.updateHitbox();
	talker.animation.addByPrefix('talk', 'talk', 8, true);
	talker.animation.addByIndices('shut', 'talk', [0], '', 0, false);
	talker.animation.addByPrefix('talk-alt', 'what', 8, true);
	talker.animation.addByIndices('shut-alt', 'what', [0], '', 0, false);
	talker.animation.addByPrefix('walk', 'walk', 8, true);
	talker.animation.addByPrefix('walkstruggle', 'pushstruggle', 8, true);
	talker.animation.addByPrefix('idle', 'idle', 8, true);
	add(talker);
	FlxMouseEvent.add(talker, function onMouseDown(d:FlxSprite) {
		if (!intervention && !sawMiniCutscene) {
			pressed++;
			if (pressed >= pressedMax) {
				intervention = true;
				talkStuff((weirdName ? 'I\'m going... I\'m going...' : 'Okay, if you\'re/clicking me it\'s cause/you want something/from me.       /Right?:Now I guess you/didn\'t do this out/of curiosity.:Like what are you?             /Six?             /Pressing little things/seeing what they gonna /do.:But whatever I\'ll bring/what you want...             /...Or accidentally found.'));
			}
		}
	});
	
	talkerBox = new FlxSprite(talker.x + 102, talker.y - 108).loadGraphic(Paths.image('title/talkerboxSmaller'));
	talkerBox.antialiasing = false;
	talkerBox.scale.set(3, 3);
	talkerBox.updateHitbox();
	add(talkerBox);

	talkerText = new TypedBitmapText(talkerBox.x + 66, talkerBox.y + 24, 'Hello!', topName.getFont('dotumche'));
	talkerText.setTextFormat(1.5, '000000', topName.alignment, FlxG.width);
	talkerText.lineOffset = 318;
	talkerText.talker = talker;
	talkerText.parentState = this;
	talkerText.startTyping((0.03 * 30) * FlxG.elapsed);
	add(talkerText);
	
	nameBox = new UITextBox(talker.x + 106, 688, FlxG.save.data.playerName);
	nameBox.onChange = function() {
		FlxG.save.data.playerName = nameBox.label.text;
		// FlxG.save.data.changedPlayer
	};
	add(nameBox);
	nameBox.visible = false;
	
	updateSelection();
	
	
}

function update(elapsed:Float) {
	if (talkerText != null) {
		talkerText.textUpdate(elapsed);
	}
	if (intervention) {
		if (controls.ACCEPT) {
			if (talkerText.active && !talkerText.typing) {
				trace('hi');
				talkerText.advanceDialogue();
				talker.animation.play('talk' + (intervention ? '-alt' : ''), true);
			} else if (!talkerText.active && !miniCutscene && !sawMiniCutscene) {
				talkerBox.visible = false;
				for (line in talkerText.lines) {
					line.visible = false;
				}
				miniCutscene = true;
				talker.animation.play('walk', true);
				talker.flipX = true;
				FlxTween.tween(talker, {x: talker.x - 200}, (weirdName ? 1 : 3), {onComplete: function() {
					talker.flipX = false;
					talker.animation.play('walkstruggle', true);
					talker.x = -450;
					nameBox.visible = true;
					FlxTween.tween(talker, {x: 74}, (weirdName ? 2 : 10), {onComplete: function() {
						talker.animation.play('idle', true);
						timer = new FlxTimer().start(0.5, function() {
							talker.animation.play('shut', true);
							talkerBox.visible = true;
							for (line in talkerText.lines) {
								line.visible = true;
							}
							// talkStuff('Alright, there you go.:');
							talkerText.resetAndChangeText((weirdName ? 'Go ahead.' : 'Alright, there you go.:If you want to/change your name to/literally anything/then do it here.:No six letter limit,             /stupid name restriction/you told me to add.:If you want a name/just type it here/and press enter.'), true);
							talkerText.startTyping(0.02, 'text-blip');
							talker.animation.play('talk' + (weirdName ? '-alt' : ''), true);
							miniCutscene = false;
							sawMiniCutscene = true;
						});
					}});
				}});
				
			} else if (!talkerText.active && sawMiniCutscene) {
				// talkerBox.visible = false;
				// for (line in talkerText.lines) {
					// line.visible = false;
				// }
				talkStuff(modMenus[menuSelected][1]);
				timer = new FlxTimer().start(0.1, function() {
					intervention = false;
				});
				talker.animation.play('talk', true);
			}
			// if (miniCutscene) {
				
			// }
		}
		if (miniCutscene) {
			nameBox.x = talker.x + 111;
		}
		// if (talkerText.active) {
			// if (controls.ACCEPT) {
				// talkerText.advanceDialogue();
			// }
			// if (talkerText.active) {
					// if (controls.ACCEPT) {
						// talkerText.advanceDialogue();
					// }
				// } else {
				// }
			// }
		// }
	}
	if (talkerText != null && !miniCutscene && !talkerText.typing) {
		talker.animation.play('shut' + (intervention ? '-alt' : ''), true);
		// talker.animation.play('walk', true);
	}
	
	if (controls.UP_P) {
		updateSelection(-1);
	} else if (controls.DOWN_P) {
		updateSelection(1);
	}
	
	// if (miniCutscene) { return; }
	if (!intervention) {
		if (nameBox.__wasFocused) { return; }
		if (controls.ACCEPT) {
			var selection = modMenus[menuSelected][0].toLowerCase();
			switch(selection) {
				case 'credits editor':
					FlxG.switchState(new UIState(true, 'CreditEditorNew'));
				case 'chart editor':
					FlxG.switchState(new CharterSelection());
				case 'overworld levels':
					FlxG.switchState(new ModState('OverworldLevelPicker'));
				case 'character editor':
					FlxG.switchState(new CharacterSelection());
				case 'stage editor':
					FlxG.switchState(new StageSelection());
				case 'freeplay song editor':
					FlxG.switchState(new UIState(true, 'FreeplaySongEditor'));
				case 'text debug':
					FlxG.switchState(new ModState('TextDebug'));
				case  'trailer thing':
					FlxG.switchState(new ModState('TrailerThing'));
				default:
					talkStuff("I haven't done this/one yet.        /Whoops.");
					FlxG.sound.play(Paths.sound('hurt'), 1);
			}
		} else if (controls.BACK) {
			FlxG.switchState(new MainMenuState());
		}
	}
}

function updateSelection(?v:Int) {
	if (intervention) { return; }
	if (v != null) {
		menuSelected += v;
		FlxG.sound.play(Paths.sound('squeak'), 1);
		if (menuSelected > menuObjects.length - 1) {
			menuSelected = 0;
		} else if (menuSelected < 0) {
			menuSelected = menuObjects.length - 1;
		}
	}
	for (menu in menuObjects) {
		menu.color = (menu.ID == menuSelected ? FlxColor.YELLOW : FlxColor.WHITE);
	}
	talkStuff(modMenus[menuSelected][1]);
}

function talkStuff(text:String) {
	talkerText.resetAndChangeText(text, true);
	talkerText.startTyping(0.02, 'text-blip');
	talker.animation.play('talk' + (intervention ? '-alt' : ''), true);
}