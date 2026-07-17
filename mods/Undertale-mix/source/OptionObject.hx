import UndertaleText;

class CheckboxOption extends FlxSprite {
	var updateCallback:Void->Void;
	var stateParent:Dynamic;
	
	var text:UndertaleText;
	var checkbox:FlxSprite;
	
	public function new(text:String, desc:String, type:String, parent:Dynamic, ?optionCallback:Void->Void) {
		text = new UndertaleText(20, 20, 'left', FlxG.width, 1.8, 'FFFFFF');
		text.updateHitbox();
		
		frames = Paths.getSparrowAtlas('options/checkbox');
		animation.addByPrefix('checking', 'checkbox anim0', 24, false);
		animation.addByPrefix('unchecking', 'checkbox anim reverse0', 24, false);
		antialiasing = false;
		setPosition(text.x - 20, text.y);
		parent.add(text);
	}
}