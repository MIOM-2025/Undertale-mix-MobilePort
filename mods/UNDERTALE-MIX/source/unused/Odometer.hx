class Odometer extends FlxSprite {
	public function new(x:Int, y:Int) {
		super(x, y);
		
		this.loadGraphic(Paths.image('numbers'), true, 9, 16);
		var frames = [];
		for (i in 0...40) {
			frames.push(i);
		}
		this.animation.add('scroll', frames, 0);
		this.animation.play('scroll', true);
	}
}