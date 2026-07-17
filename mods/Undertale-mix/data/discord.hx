import funkin.backend.utils.DiscordUtil;

function onDiscordPresenceUpdate(e) {
	var data = e.presence;

	if(data.button1Label == null)
		data.button1Label = "Undertale Mix Discord";
	if(data.button1Url == null)
		data.button1Url = "https://discord.gg/58jDpH9QTb";
}