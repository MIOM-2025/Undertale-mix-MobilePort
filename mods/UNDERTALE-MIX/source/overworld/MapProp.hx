class MapProp extends FlxSprite {
	var playerObject:Dynamic;
	var overPlayer:Bool = true;
	var propName:String;
	var parentState:Dynamic;
	override function new(x:Int, y:Int, prop:String, player:Dynamic, parent:Dynamic) {
		super(x, y);
		loadGraphic(Paths.image('assets/props/' + prop));
		updateHitbox();
		playerObject = player;
		propName = prop;
		parentState = parent;
		// trace(player);
	}
	
	var wasOver:Bool = false;
	override function update(elapsed:Float) {
		overPlayer = playerObject.getGraphicMidpoint().y > getGraphicMidpoint().y;
		if (wasOver != overPlayer) {
			wasOver = overPlayer;
			onLayerChange();
		}
	}
	
	function onLayerChange() {
		if (overPlayer) {
			parentState.remove(this);
			parentState.insert(parentState.members.indexOf(playerObject) - 1, this);
		} else {
			parentState.remove(this);
			parentState.insert(parentState.members.indexOf(playerObject) + 1, this);
		}
		// trace('hi im ' + propName + ' and im i over the player? ' + (overPlayer ? 'yes' : 'no'));
	}
}