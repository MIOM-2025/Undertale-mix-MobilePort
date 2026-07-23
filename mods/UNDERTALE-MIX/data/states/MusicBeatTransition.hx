function create() {
	transitionTween.cancel();
	remove(blackSpr); remove(transitionSprite);
    if(newState != null) FlxG.switchState(newState);
}