//Took me fucking forever to make this separate class.
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.graphics.frames.FlxBitmapFont;

class UndertaleText extends FlxBitmapText {
	var originX:Int = 0;
	var originY:Int = 0;
	public function new(x:Int, y:Int, text:String, alignment:String, width:Int, scale:Float, ?color:String, ?font:String) {
		super(x, y, text);
		originX = x; originY = y;
		
		this.autoSize = false;
		this.alignment = getAlignment(alignment);
		this.color = FlxColor.fromString('#' + (color != null ? color : 'FFFFFF'));
		this.fieldWidth = width;
		this.scale.set(scale, scale);
		this.font = getFont((font != null ? font : 'undertale'));
		// trace(this.font);
	}
	
	function getAlignment(alignment:String) {
		switch(alignment) {
			case 'left':
				return FlxTextAlign.LEFT;
			case 'center':
				return FlxTextAlign.CENTER;
			case 'right':
				return FlxTextAlign.RIGHT;
			default:
				return FlxTextAlign.LEFT;
		}
	}
	//1365 767
	public function getFont(font:String) {
		switch(font) {
			case 'crypt':
				return FlxBitmapFont.fromAngelCode(Assets.getBitmapData(Paths.font('cryptoftomorrow.png')), Paths.font('cryptoftomorrow.fnt'));
			case 'dotumche':
				return FlxBitmapFont.fromAngelCode(Assets.getBitmapData(Paths.font('dotumche.png')), Paths.font('dotumche.fnt'));
			case 'wonder':
					return FlxBitmapFont.fromAngelCode(Assets.getBitmapData(Paths.font('8bitwonder.png')), Paths.font('8bitwonder.fnt'));
			case 'undertale-pixel':
				return FlxBitmapFont.fromAngelCode(Assets.getBitmapData(Paths.font('ut-text-pixel.png')), Paths.font('ut-text-pixel.fnt'));
			case 'undertale-outline':
				letterSpacing = -1;
				return FlxBitmapFont.fromAngelCode(Assets.getBitmapData(Paths.font('ut-text-pixel-outline.png')), Paths.font('ut-text-pixel-outline.fnt'));
			case 'earthbound':
				return FlxBitmapFont.fromAngelCode(Assets.getBitmapData(Paths.font('earthbound-basic.png')), Paths.font('earthbound-basic.fnt'));
			default:
				if (font != 'undertale') { trace('"' + font + '"' + ' is not a valid font! Valid fonts are: "crypt", "dotumche", "wonder", "undertale-pixel", "undertale-pixel-outline" and "undertale" (default font).'); }
				return FlxBitmapFont.fromAngelCode(Assets.getBitmapData(Paths.font('ut-text.png')), Paths.font('ut-text.fnt'));
		}
	}
	
	function formFont(image:String, letters:String) {
		// trace(
		return FlxBitmapFont.fromXNA(Assets.getBitmapData(Paths.image('fonts/' + image), true, false), letters);
	}
}