function onEvent(event) {
	if (event.event.name == 'Camera Visibility Toggle') {
		camGame.visible = !camGame.visible;
	}
}