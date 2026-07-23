import Math;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;

import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.graphics.frames.FlxBitmapFont;

class TextItem extends FlxBitmapText {
	var distanceBetween = 503;
	var startPoint = 0;
	var target = 0;
	public function new(x, y, text, font) {
		super(x, y, text, font);
		
		this.alignment = FlxTextAlign.CENTER;
		this.fieldWidth = FlxG.width;
		this.color = FlxColor.WHITE;
		this.scale.set(1.8, 1.8);
		
		startPoint = this.x;
	}
}