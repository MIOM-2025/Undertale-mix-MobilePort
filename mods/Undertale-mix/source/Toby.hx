class Toby extends FlxSprite {
	var face:FlxSprite;
	var legs:FlxSprite;

	override function new(x:Int, y:Int, type:Int, parent:Dynamic, flip:Bool) {
		super(x, y);
		
		loadGraphic(Paths.image('dog/dogbody'), true, 22, 14);
		animation.add('i', [0, 1], 0);
		
		face = new FlxSprite().loadGraphic(Paths.image('dog/dogface'), true, 6, 6);
		face.animation.add('i', [0, 1], 0);
		face.animation.add('i-alt', [2, 3], 0);
		face.flipX = flip;
		
		legs = new FlxSprite().loadGraphic(Paths.image('dog/doglegs'), true, 18, 5);
		legs.animation.add('i', [0, 1], 0);
		legs.animation.add('still', [2], 0);
		parent.add(legs);
		legs.flipX = flip;
		
		animation.play('i', true);
		flipX = flip;
		legs.animation.play('i', true);
		face.animation.play('i', true);
		
		parent.add(this);
		parent.add(face);
	}
	
	var lastCamera:Dynamic;
	var lastVisible:Bool = false;
	override function update(elapsed:Float) {
		super.update(elapsed);
		if (lastCamera != this.camera) {
			lastCamera = this.camera;
			for (part in [legs, face]) {
				part.cameras = [this.camera];
			}
		}
		
		face.setPosition(x + (flipX ? 14 : 2), y + 4);
		legs.setPosition(x + (flipX ? 3 : 1), y + 14);
	}
	
	var hasStepped:Bool = false;
	var stayingStill:Bool = false;
	var stepFrame:Int = 0;
	function step() {
		if (!stayingStill) {
			hasStepped = !hasStepped;
			stepFrame = (hasStepped ? 1 : 0);
			animation.curAnim.curFrame = stepFrame;
			legs.animation.curAnim.curFrame = stepFrame;
			legs.animation.play('i', true, false, stepFrame);
		} else {
			legs.animation.play('still');
		}
	}
	
	function expression(s:String) {
		face.animation.play('i' + s, true);
	}
	
	function updateVariant(v:String) {
		loadGraphic(Paths.image('dog/dogbody' + (v != '' ? '-' + v : '')), true, (v == 'hat' ? 24 : 22), (v == 'hat' ? 28 : 14));
		if (v == 'hat') {
			offset.set((flipX ? 0 : 2), 7);
		}
		animation.add('i', [0, 1], 0);
		animation.play('i', true);
	}
	
	function hide(v:Bool) {
		for (part in [this, legs, face]) {
			part.visible = v;
		}
	}
}