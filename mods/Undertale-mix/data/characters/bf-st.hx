import flixel.math.FlxRandom;
import StringTools;

var r:FlxRandom = new FlxRandom();
var anims = [
	'idle' => ['starcatcher', 'corruption'],
	'singLEFT' => ['b3', 'bsides'],
	'singDOWN' => ['ce', 'dsides'],
	'singUP' => ['csides', 'arrowfunk'],
	'singRIGHT' => ['djx', 'hellbeats'],
];
// var binary = new CustomShader('glitch02');
// function postCreate() {
	// this.shader = binary;
// }

var animSuffix:Array<String> = [];
var randomIndex:Int = 0;
var normal:Bool = false;
var anim:String = '';
function onPlaySingAnim(e) {
	// if (this != null) {
		// animSuffix = anims.get(e.animName);
		// randomIndex = r.int(0, 1);
		// animSuffix = animSuffix[randomIndex];
		// normal = r.bool(50);
		e.cancel();
		// anim = e.animName + (normal ? '-' + animSuffix : '');
		// animation.play(e.animName + (r.bool(50) ? '-' + animSuffix[r.int(0, 1)] : ''), true);
		// playAnim(e.animName + (normal ? '-' + animSuffix : ''), true);
		// this.shader = binary;
		// binary.glitchIntensity = r.float(-1, 1);
		// PlayState.instance.executeEvent({name: 'Change Icons', params: [(normal ? animSuffix : 'bf'), '', '', '']});
		// PlayState.instance.executeEvent({name: 'Glitched Sing Animation', params: [3, anim], time: Conductor.songPosition});
	// }
}

// function onPlayAnim(e) {
	// if (StringTools.startsWith(e.animName, 'idle')) {
		// animSuffix = anims.get('idle');
		// trace(animSuffix);
		// e.cancel();q
		// playAnim('idle-' + animSuffix[r.int(0, 2)], true);
	// }
// }
// var icon:String = '';
// function onDance(e) {
	// PlayState.instance.executeEvent({name: 'Change Icons', params: ['bf', '', '', '']});
	// if (this != null) {
		// animSuffix = anims.get('idle');
		// randomIndex = r.int(0, 1);
		// animSuffix = animSuffix[randomIndex];
		// normal = r.bool(50);
		// anim = e.animName + (normal ? '-' + animSuffix : '');
		// icon = (normal ? animSuffix : 'bf');
		// e.cancel();
		// playAnim('idle' + (normal ? '-' + animSuffix : ''), true);
		// this.shader = binary;
		// binary.glitchIntensity = r.float(-1, 1);
		// trace(icon);
		// PlayState.instance.executeEvent({name: 'Change Icons', params: [icon, '', 	'', '']});
		// PlayState.instance.executeEvent({name: 'Glitched Sing Animation', params: [3, anim], time: Conductor.songPosition});
	// }
// }

// function onBeatHit(e) {
	// trace('heaha');
// }

// var lastSuffix:String = 'suffi';
// function onPlayAnim(e) {
	// trace('hi');
	// var playedAnim:String = e.animName;
	// e.cancel();
	// switch(playedAnim) {
		// case 'idle':
			// animSuffix = anims.get('idle');
			// animSuffix = animSuffix[FlxG.random.int(0, animSuffix.length - 1)];
			// anim = 'idle' + (FlxG.random.bool(50) ? '-' + animSuffix : '');
			// trace(anim);
			// PlayState.instance.executeEvent({name: 'Glitched Sing Animation', params: [3, anim], time: Conductor.songPosition});
		// case 'singLEFT':
		// case 'singDOWN':
		// case 'singUP':
		// case 'singRIGHT':
	// }
	
	// if (lastSuffix != animSuffix) {
		// PlayState.instance.executeEvent({name: 'Change Icons', params: [animSuffix, '', 	'', '']});
		// lastSuffix = animSuffix;
	// }
// }