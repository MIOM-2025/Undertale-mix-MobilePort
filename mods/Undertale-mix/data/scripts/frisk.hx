import flixel.math.FlxRandom;

var fps:Int = 8;
var friskCamera = new FlxCamera();
var curPath:Int = 7;
var pathPhase:Int = 0;
var startPosition:Bool = false;
var r = new FlxRandom();
var frisk:FlxSprite;
var paths = [
	0 => [
			{
				startX: -100,
				startY: 400,
				anim: 'wright',
				x: 40,
				y: 0,
				runTime: 15,
			},
			{
				anim: 'iright',
				x: 0,
				y: 0,
				runTime: 10,
			},
			{
				anim: 'idown',
				x: 0,
				y: 0,
				runTime: 5,
			},
			{
				anim: 'ileft',
				x: 0,
				y: 0,
				runTime: 4,
			},
			{
				anim: 'wright',
				x: 40,
				y: 0,
				runTime: 1,
			},
			{
				anim: 'wright',
				x: 40,
				y: 40,
				runTime: 4,
			},
			{
				anim: 'wright',
				x: 40,
				y: 0,
				runTime: 2,
			},
			{
				anim: 'wright',
				x: 40,
				y: -40,
				runTime: 4,
			},
			{
				anim: 'wright',
				x: 40,
				y: 0,
				runTime: 15,
			},
		],
	1 => [
			{
				startX: -100,
				startY: 410,
				anim: 'wright',
				x: 40,
				y: 0,
				runTime: 50,
			},
		],
	2 => [
			{
				startX: 500,
				startY: 1000,
				anim: 'wup',
				x: 0,
				y: -40,
				runTime: 50,
			},
			{
				anim: 'wright',
				x: 40,
				y: 0,
				runTime: 10,
			},
			{
				anim: 'iright',
				x: 0,
				y: 0,
				runTime: 20,
			},
			{
				anim: 'wdown',
				x: 0,
				y: 40,
				runTime: 60,
			},
		],
	3 => [
			{
				startX: 550,
				startY: 1000,
				anim: 'wup',
				x: 0,
				y: -40,
				runTime: 50,
			},
		],
	4 => [
			{
				startX: 600,
				startY: -1000,
				anim: 'wdown',
				x: 0,
				y: 40,
				runTime: 50,
			},
		],
	5 => [
			{
				startX: 1500,
				startY: 500,
				anim: 'wleft',
				x: -40,
				y: 0,
				runTime: 10,
			},
			{
				x: 0,
				y: 0,
				anim: 'ileft',
				runTime: 0,
			},
			{
				x: -40,
				y: -40,
				anim: 'wleft',
				runTime: 1,
			},
			{
				x: 0,
				y: 0,
				anim: 'ileft',
				runTime: 10,
			},
			{
				x: -40,
				y: 0,
				anim: 'wleft',
				runTime: 2,
			},
			{
				x: 0,
				y: 0,
				anim: 'ileft',
				runTime: 15,
			},
			{
				x: 0,
				y: -40,
				anim: 'wup',
				runTime: 2,
			},
			{
				x: 0,
				y: 0,
				anim: 'iup',
				runTime: 10,
			},
			{
				x: -40,
				y: 0,
				anim: 'wleft',
				runTime: 10,
			},
			{
				x: 0,
				y: 0,
				anim: 'ileft',
				runTime: 15,
			},
			{
				x: 0,
				y: -40,
				anim: 'wup',
				runTime: 5,
			},
			{
				x: 0,
				y: 0,
				anim: 'iup',
				runTime: 6,
			},
			{
				x: 40,
				y: 0,
				anim: 'wright',
				runTime: 6,
			},
			{
				x: 0,
				y: 0,
				anim: 'iright',
				runTime: 10,
			},
			{
				x: 0,
				y: 40,
				anim: 'wdown',
				runTime: 30,
			},
		],
	6 => [
			{
				startX: -120,
				startY: 500,
				x: 40,
				y: 0,
				anim: 'wright',
				runTime: 20,
			},
			{
				x: 40,
				y: -40,
				anim: 'wright',
				runTime: 20,
			},
		],
	7 => [
			{
				startX: -140,
				startY: 350,
				x: 40,
				y: 0,
				anim: 'wright',
				runTime: 16,
			},
			{
				x: 0,
				y: 0,
				anim: 'iright',
				runTime: 20,
			},
			{
				x: 0,
				y: 40,
				anim: 'wdown',
				runTime: 2,
			},
			{
				x: 0,
				y: 0,
				anim: 'idown',
				runTime: 60,
			},
			{
				x: 0,
				y: 0,
				anim: 'iup',
				runTime: 0,
			},
		],
];
var thirthy:Float = 1.0 / 30.0;
var pathData;
function create() {
	trace('the frisk is here');
	FlxG.cameras.add(friskCamera, false);
	// friskCamera.zoom = 0.2;
	friskCamera.bgColor = FlxColor.TRANSPARENT;

	frisk = new FlxSprite().loadGraphic(Paths.image((r.bool(10) ? 'chara' : 'frisk') + '-sheet'), true, 21, 30);
	if (r.bool(1)) {
		frisk.loadGraphic(Paths.image('squeezo-sheet'), true, 21, 30);
	}
	
	frisk.animation.add('wdown', [0, 1, 0, 2], fps, true);
	frisk.animation.add('idown', [0], fps, true);
	frisk.animation.add('wleft', [3, 4], fps, true);
	frisk.animation.add('ileft', [3], fps, true);
	// frisk.animation.play('wdown', true);
	frisk.animation.add('wright', [5, 6], fps, true);
	frisk.animation.add('iright', [5], fps, true);
	frisk.animation.add('wup', [7, 9, 7, 8], fps, true);
	frisk.animation.add('iup', [7], fps, true);
	frisk.animation.play('wup', true);
	frisk.antialiasing = false;
	frisk.screenCenter();
	frisk.scale.set(10, 10);
	frisk.cameras = [friskCamera];
	frisk.visible = false;
	add(frisk);
	
	curPath = r.int(0, 7);
	var instLength:Float = PlayState.instance.inst.length;
	time = r.float(0, instLength);
	trace('gettin addded at: ' + time / 1000);
	var timer:FlxTimer = new FlxTimer().start(time / 1000, function() {
		nextPath();
		frisk.visible = true;
	});
}

var timePassed:Float = 0;
function update(elapsed:Float) {
	if (pathData != null) {
		timePassed += thirthy;
		frisk.x += pathData.x * thirthy;
		frisk.y += pathData.y * thirthy;
		if (timePassed > pathData.runTime) {
			nextPath(true);
		}
	}
}

function nextPath(?advance:Bool) {
	if (advance != null && advance) {
		pathPhase++;
		// trace(curPhase);
	}
	pathData = paths[curPath][pathPhase];
	if (pathData == null) { return; }
	frisk.animation.play(pathData.anim, true);
	if (!startPosition) {
		frisk.setPosition(pathData.startX, pathData.startY);
		startPosition = true;
	}
	timePassed = 0;
	// trace(paths[curPath][pathPhase]);
}