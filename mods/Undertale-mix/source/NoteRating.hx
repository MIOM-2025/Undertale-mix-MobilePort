import flixel.math.FlxPoint;

class NoteRating extends FlxSprite {
	// var data = [
		// 'rating' => ['sick', 'good', 'bad', 'shit'],
		// 'number' => ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
	// ];
	var lastRating:String = '';
	var initX:Int = 0;
	var initY:Int = 0;
	public function new(x:Int, y:Int, rating:String, ?type:String = 'ratings', ?skin:String = 'ut', ?atlas:String = 'sparrow', ?ratingScale:Int = 1) {
		super(x, y);
		var path:String = 'ratingdisplay/' + skin + '/' + type;
		switch(atlas) {
			case 'aseprite':
				frames = Paths.getAsepriteAtlas(path);
			default:
				frames = Paths.getSparrowAtlas(path);
		}
		lastRating = rating;
		scale.set(ratingScale, ratingScale);
		updateHitbox();
		animation.addByPrefix(rating, rating, 0, false);
		animation.play(rating, true);
	}
	
	function reset(rating:String, x:Int, y:Int) {
		CoolUtil.resetSprite(this, x, y);
		if (lastRating != rating) {
			// trace('hey it changed from ' + lastRating + ' to ' + rating);
			animation.addByPrefix(rating, rating, 0, false);
			lastRating = rating;
		}
		animation.play(rating, true);
	}
}