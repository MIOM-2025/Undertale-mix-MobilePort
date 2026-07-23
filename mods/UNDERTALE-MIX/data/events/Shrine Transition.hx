function onEvent(event) {
	var name = event.event.name;
	if (name == 'Shrine Transition') {
		executeEvent({name: 'HScript Call', params: ['shrineTransition', '']});
	}
}