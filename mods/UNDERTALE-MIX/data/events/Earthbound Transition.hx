function onEvent(event) {
	var name = event.event.name;
	if (name == 'Earthbound Transition') {
		executeEvent({name: 'HScript Call', params: ['earthboundTransition', '']});
	}
}