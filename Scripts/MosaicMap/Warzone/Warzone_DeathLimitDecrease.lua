firstUpdate = true
function onLoadMap()
	setUpdateInterval(300)
end

function execute()
	if firstUpdate then
		firstUpdate = false
	else
		addDeathLimit(-1)
	end
end