import Reflect;
import Math;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

class Kris extends FlxSprite {
	var collisionBox:FlxSprite;
	var interactBox:FlxSprite;
	var mapCollision:Dynamic;

	var direction:String = 'down';
	var animationSet:Bool = false;
	var walkSpeed:Float = 90;
	var runSpeed:Float = 1;
	var runTimer:Int = 1;
	var frameTimer:Float = 0;
	var walkFrame:Int = 0;
	var lockMovement:Bool = false;
	var devMode:Bool = false;
	var cutsceneFrameTimer:Float = 0;

	// ========== 摇杆相关 ==========
	var joystickBase:FlxSprite;
	var joystickKnob:FlxSprite;
	var uiCam:FlxCamera;
	var joystickActive:Bool = false;
	var joystickTouchID:Int = -1;
	var joystickCenterX:Float = 0;
	var joystickCenterY:Float = 0;
	var joystickRadius:Float = 80;
	var joystickDeadzone:Float = 5;
	var joystickMaxDist:Float = 100;
	var joystickScale:Float = 12;
	var joystickSpeed:Float = 120;
	var rawDirX:Float = 0;
	var rawDirY:Float = 0;
	// ============================

	override function new(x:Int, y:Int, parent:Dynamic, collisionGroup:Dynamic) {
		super(x, y);
		devMode = Options.devMode;
		
		loadGraphic(Paths.image('overworld/players/frisk'), true, 20, 30);
		animation.add('left', [3, 4, 3, 4], 0, false);
		animation.add('down', [0, 1, 0, 2], 0, false);
		animation.add('up', [7, 8, 7, 9], 0, false);
		animation.add('right', [5, 6, 5, 6], 0, false);
		updateHitbox();
		offset.y = 2;
		
		collisionBox = new FlxSprite(x, y).makeGraphic(width, height / 2.3, FlxColor.RED);
		collisionBox.alpha = (devMode ? 0 : 0);
		parent.add(collisionBox);
		
		mapCollision = collisionGroup;

		initJoystick(parent);
	}

	function initJoystick(parent:Dynamic) {
		uiCam = new FlxCamera();
		uiCam.bgColor = FlxColor.TRANSPARENT;
		uiCam.zoom = 1;
		uiCam.antialiasing = false;
		FlxG.cameras.add(uiCam, true);

		joystickBase = new FlxSprite();
		try {
			joystickBase.loadGraphic(Paths.image('YG/D'));
		} catch (e:Dynamic) {
			joystickBase.makeGraphic(Std.int(joystickRadius * 2), Std.int(joystickRadius * 2), 0xFF555577);
		}
		joystickBase.scale.set(joystickScale, joystickScale);
		joystickBase.updateHitbox();
		// ★ 左边缘 120 像素，下边缘 100 像素
		joystickBase.x = 120;
		joystickBase.y = FlxG.height - joystickBase.height - 100;
		joystickBase.alpha = 0.6;
		joystickBase.cameras = [uiCam];
		parent.add(joystickBase);

		joystickKnob = new FlxSprite();
		try {
			joystickKnob.loadGraphic(Paths.image('YG/C'));
		} catch (e:Dynamic) {
			var knobRadius:Float = joystickRadius * 0.45;
			joystickKnob.makeGraphic(Std.int(knobRadius * 2), Std.int(knobRadius * 2), 0xCC88CCFF);
		}
		joystickKnob.scale.set(joystickScale, joystickScale);
		joystickKnob.updateHitbox();
		joystickKnob.x = joystickBase.x + joystickBase.width / 2 - joystickKnob.width / 2;
		joystickKnob.y = joystickBase.y + joystickBase.height / 2 - joystickKnob.height / 2;
		joystickKnob.alpha = 0.6;
		joystickKnob.cameras = [uiCam];
		parent.add(joystickKnob);

		joystickCenterX = joystickBase.x + joystickBase.width / 2;
		joystickCenterY = joystickBase.y + joystickBase.height / 2;
		joystickMaxDist = 100;
		joystickDeadzone = 5;
	}

	function quantizeDirection(dx:Float, dy:Float):Void {
		var dist = Math.sqrt(dx*dx + dy*dy);
		if (dist < joystickDeadzone) {
			rawDirX = 0;
			rawDirY = 0;
			return;
		}
		
		var angle = Math.atan2(-dy, dx) * 180 / Math.PI;
		if (angle < 0) angle += 360;
		
		var halfAngle = 17.5;
		var dirX:Float = 0;
		var dirY:Float = 0;
		
		if ((angle >= 0 && angle < 17.5) || (angle >= 342.5 && angle <= 360)) {
			dirX = 1; dirY = 0;
		} else if (angle >= 72.5 && angle < 107.5) {
			dirX = 0; dirY = -1;
		} else if (angle >= 162.5 && angle < 197.5) {
			dirX = -1; dirY = 0;
		} else if (angle >= 252.5 && angle < 287.5) {
			dirX = 0; dirY = 1;
		} else {
			if (angle >= 17.5 && angle < 72.5) {
				dirX = 1; dirY = -1;
			} else if (angle >= 107.5 && angle < 162.5) {
				dirX = -1; dirY = -1;
			} else if (angle >= 197.5 && angle < 252.5) {
				dirX = -1; dirY = 1;
			} else if (angle >= 287.5 && angle < 342.5) {
				dirX = 1; dirY = 1;
			}
		}
		
		var len = Math.sqrt(dirX*dirX + dirY*dirY);
		if (len > 0) {
			rawDirX = dirX / len;
			rawDirY = dirY / len;
		} else {
			rawDirX = 0;
			rawDirY = 0;
		}
	}

	function updateJoystick(elapsed:Float) {
		var mouseActive:Bool = false;
		if (FlxG.mouse.justPressed) {
			var mouseInUi = FlxG.mouse.getWorldPosition(uiCam);
			if (joystickKnob.overlapsPoint(mouseInUi, false, uiCam)) {
				joystickActive = true;
				mouseActive = true;
			}
		}
		if (joystickActive && FlxG.mouse.pressed) {
			mouseActive = true;
		}
		if (FlxG.mouse.justReleased) {
			joystickActive = false;
			resetJoystickKnob();
			mouseActive = false;
		}

		var touchFound:Bool = false;
		var touch:FlxTouch = null;
		if (joystickTouchID >= 0) {
			for (t in FlxG.touches.list) {
				if (t.id == joystickTouchID) {
					touch = t;
					touchFound = true;
					break;
				}
			}
			if (!touchFound) {
				joystickActive = false;
				joystickTouchID = -1;
				resetJoystickKnob();
			}
		} else {
			for (t in FlxG.touches.list) {
				if (t.justPressed) {
					var touchInUi = t.getWorldPosition(uiCam);
					if (joystickKnob.overlapsPoint(touchInUi, false, uiCam)) {
						joystickTouchID = t.id;
						touch = t;
						touchFound = true;
						joystickActive = true;
						break;
					}
				}
			}
		}

		var targetX:Float = joystickCenterX;
		var targetY:Float = joystickCenterY;
		var hasInput:Bool = false;

		if (mouseActive && FlxG.mouse.pressed) {
			var mouseInUi = FlxG.mouse.getWorldPosition(uiCam);
			targetX = mouseInUi.x;
			targetY = mouseInUi.y;
			hasInput = true;
		} else if (touchFound && touch != null) {
			var touchInUi = touch.getWorldPosition(uiCam);
			targetX = touchInUi.x;
			targetY = touchInUi.y;
			hasInput = true;
		}

		if (hasInput && joystickActive) {
			var dx = targetX - joystickCenterX;
			var dy = targetY - joystickCenterY;
			var dist = Math.sqrt(dx * dx + dy * dy);

			if (dist > joystickMaxDist) {
				dx = dx / dist * joystickMaxDist;
				dy = dy / dist * joystickMaxDist;
				dist = joystickMaxDist;
			}

			joystickKnob.x = joystickCenterX + dx - joystickKnob.width / 2;
			joystickKnob.y = joystickCenterY + dy - joystickKnob.height / 2;

			var rawDx = targetX - joystickCenterX;
			var rawDy = targetY - joystickCenterY;
			quantizeDirection(rawDx, rawDy);
		} else {
			if (!mouseActive && joystickTouchID < 0) {
				resetJoystickKnob();
			}
		}

		if (!mouseActive && joystickTouchID < 0) {
			joystickActive = false;
			rawDirX = 0;
			rawDirY = 0;
		}
	}

	function resetJoystickKnob() {
		if (joystickKnob != null && joystickBase != null) {
			joystickKnob.x = joystickBase.x + joystickBase.width / 2 - joystickKnob.width / 2;
			joystickKnob.y = joystickBase.y + joystickBase.height / 2 - joystickKnob.height / 2;
		}
		rawDirX = 0;
		rawDirY = 0;
	}

	var LEFT:Bool;
	var DOWN:Bool;
	var UP:Bool;
	var RIGHT:Bool;
	var SHIFT:Bool;

	override function update(elapsed:Float) {
		updateJoystick(elapsed);

		var useJoystick = joystickActive && (rawDirX != 0 || rawDirY != 0) && !lockMovement;

		if (useJoystick) {
			var speed = joystickSpeed;
			var moveX = rawDirX * speed * elapsed;
			var moveY = rawDirY * speed * elapsed;

			if (moveX != 0) {
				collisionBox.x += moveX;
				if (FlxG.collide(collisionBox, mapCollision)) {
					collisionBox.x -= moveX;
				}
			}
			if (moveY != 0) {
				collisionBox.y += moveY;
				if (FlxG.collide(collisionBox, mapCollision)) {
					collisionBox.y -= moveY;
				}
			}

			if (Math.abs(rawDirX) >= Math.abs(rawDirY)) {
				direction = (rawDirX > 0) ? 'right' : 'left';
			} else {
				direction = (rawDirY > 0) ? 'down' : 'up';
			}
			animationSet = true;

			setPosition(collisionBox.x + 1, collisionBox.y - 15);

			var isMoving = (moveX != 0 || moveY != 0);
			if (isMoving) {
				var pixelDiff = Math.abs(moveX) + Math.abs(moveY);
				frameTimer += pixelDiff / 6;
			} else {
				frameTimer = 0;
			}
			if (frameTimer > 3) {
				frameTimer = 0;
				walkFrame++;
				if (walkFrame > 3) walkFrame = 0;
			}
			animation.play(direction, true, false, (isMoving ? walkFrame : 0));

			super.update(elapsed);
			return;
		}

		// ========== 原键盘移动 ==========
		LEFT = FlxG.keys.pressed.LEFT;
		DOWN = FlxG.keys.pressed.DOWN;
		UP = FlxG.keys.pressed.UP;
		RIGHT = FlxG.keys.pressed.RIGHT;
		SHIFT = FlxG.keys.pressed.SHIFT;

		if (keyReleased(direction.toUpperCase())) {
			animationSet = false;
		}

		if (lockMovement) {
			setPosition(collisionBox.x + 1, collisionBox.y - 15);
			if (getPixelDifferenceCutscene() != null && cutsceneFrameTimer > 0) {
				frameTimer += ((cutsceneFrameTimer * 30) * elapsed) / 6;
			} else {
				walkFrame = 0;
				frameTimer = 0;
			}
			if (frameTimer > 3) {
				frameTimer = 0;
				walkFrame++;
				if (walkFrame > 3) walkFrame = 0;
			}
			animation.play(direction, true, false, walkFrame);
			super.update(elapsed);
			return;
		}

		if (SHIFT) {
			runTimer += (0.9 * elapsed) * 22;
			if (runTimer < 10) {
				runSpeed = 60;
			} else if (runTimer > 10) {
				runSpeed = 90;
			} else if (runTimer > 60) {
				runSpeed = 120;
			}
		} else {
			runTimer = 0;
			runSpeed = 30;
		}

		if (DOWN) {
			collisionBox.y += movementValue(elapsed);
			if (FlxG.collide(collisionBox, mapCollision)) {
				runSpeed = (SHIFT ? 60 : 30); runTimer = 0;
			}
			setAnimation('down');
		}
		if (UP) {
			collisionBox.y -= movementValue(elapsed);
			if (FlxG.collide(collisionBox, mapCollision)) {
				runSpeed = (SHIFT ? 60 : 30); runTimer = 0;
			}
			setAnimation('up');
		}
		if (LEFT) {
			collisionBox.x -= movementValue(elapsed);
			if (FlxG.collide(collisionBox, mapCollision)) {
				runSpeed = (SHIFT ? 60 : 30); runTimer = 0;
			}
			setAnimation('left');
		}
		if (RIGHT) {
			collisionBox.x += movementValue(elapsed);
			if (FlxG.collide(collisionBox, mapCollision)) {
				runSpeed = (SHIFT ? 60 : 30); runTimer = 0;
			}
			setAnimation('right');
		}
		setPosition(collisionBox.x + 1, collisionBox.y - 15);

		if (isWalking()) {
			frameTimer += getPixelDifference() / 6;
		} else {
			frameTimer = 0;
		}
		if (frameTimer > 3) {
			frameTimer = 0;
			walkFrame++;
			if (walkFrame > 3) walkFrame = 0;
		}
		animation.play(direction, true, false, (isWalking() ? walkFrame : 0));

		super.update(elapsed);
	}

	function setAnimation(facing:String) {
		if (!animationSet) {
			direction = facing;
			animationSet = true;
		}
	}

	function keyReleased(direction:String) {
		return Reflect.getProperty(FlxG.keys.justReleased, direction);
	}

	function isWalking() {
		if ((!LEFT && !RIGHT && !UP && !DOWN) || getPixelDifference() == null) {
			return false;
		} else {
			return true;
		}
	}

	function getPixelDifference() {
		var xDiff:Float = last.x - x;
		var yDiff:Float = last.y - y;
		if ((LEFT || RIGHT) && xDiff != 0) {
			return Math.abs(xDiff);
		} else if ((UP || DOWN) && yDiff != 0) {
			return Math.abs(yDiff);
		}
		return 0;
	}

	function getPixelDifferenceCutscene() {
		var xDiff:Float = last.x - x;
		var yDiff:Float = last.y - y;
		if (xDiff != 0) return Math.abs(xDiff);
		else if (yDiff != 0) return Math.abs(yDiff);
		return null;
	}

	function movementValue(elapsed) {
		if (LEFT && RIGHT || UP && DOWN) {
			return 0;
		} else {
			return (walkSpeed + runSpeed) * elapsed;
		}
	}

	function bfSkin() {
		loadGraphic(Paths.image('overworld/players/bf'), true, 24, 31);
		animation.add('left', [9, 8, 9, 8], 0, false);
		animation.add('down', [1, 0, 1, 2], 0, false);
		animation.add('up', [6, 5, 6, 7], 0, false);
		animation.add('right', [4, 3, 4, 3], 0, false);
		updateHitbox();
		offset.set(2, 3);
	}

	override function destroy() {
		super.destroy();
		if (joystickBase != null) joystickBase.destroy();
		if (joystickKnob != null) joystickKnob.destroy();
		if (uiCam != null) {
			FlxG.cameras.remove(uiCam);
			uiCam.destroy();
		}
	}
}