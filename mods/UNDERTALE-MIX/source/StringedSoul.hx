import funkin.backend.MusicBeatGroup;
import flixel.math.FlxRandom;

class StringedSoul extends MusicBeatGroup {
	var r:FlxRandom = new FlxRandom();
	
	public function new(x:Int, y:Int, groupScale:Float) {
		super(x, y);
		var string:FlxSprite = new FlxSprite(x, y).makeGraphic(1, 200, FlxColor.BLUE);
		string.scale.set(groupScale, groupScale);
		string.updateHitbox();
		
		var soul:FlxSprite = new FlxSprite(string.x - 7, (string.y + string.height) - 4).loadGraphic(Paths.image('stages/antivoid/souls/soul'));
		soul.scale.set(groupScale, groupScale);
		soul.updateHitbox();
		soul.color = r.color();
		soul.setPosition(string.x - (soul.width / 2), (string.y + string.height) - (4 * groupScale));
		
		var soulString:FlxSprite = new FlxSprite(soul.x, soul.y).loadGraphic(Paths.image('stages/antivoid/souls/soulstring' + r.int(1, 8)));
		soulString.scale.set(groupScale, groupScale);
		soulString.updateHitbox();
		
		for (part in [string, soul, soulString]) {
			// part.antialiasing = false;
			this.add(part);
		}
		
		this.antialiasing = false;
	}
}