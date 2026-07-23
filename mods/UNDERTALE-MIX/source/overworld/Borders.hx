class Borders extends FlxSprite {
	var borderCamera:FlxCamera = new FlxCamera();
	var borderR:FlxSprite;
	override function new(parentState:Dynamic) {
		super();
		FlxG.cameras.add(borderCamera, false);
		borderCamera.bgColor = FlxColor.TRANSPARENT;
		borderCamera.zoom = 1;
		
		this.makeGraphic(160, FlxG.height, FlxColor.BLACK);
		// screenCenter();
		cameras = [borderCamera];
		
		borderR = new FlxSprite(1120).makeGraphic(160, FlxG.height, FlxColor.BLACK);
		borderR.cameras = [borderCamera];
		parentState.add(borderR);
	}
}