function collectParams()
	addParam("Trigger", "Trigger")
	addParam("Name", "String")
	--addParam("OnlyOnce", "Bool")
end

function onLoadMap()
	createTrigger( "Trigger", getStringParam("Name"))
end

function onTriggerEntered( trigger )
	trigger:enable( false )
end