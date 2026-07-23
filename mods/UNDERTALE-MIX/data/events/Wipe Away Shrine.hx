function onEvent(event) {
	var name = event.event.name;
	if (name == 'Wipe Away Shrine') {
		executeEvent({name: 'HScript Call', params: ['shrineWipeAway', '']});
	}
}