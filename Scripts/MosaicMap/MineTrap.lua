require "SentryTrap_Base"
function collectParams()
	addParam("SpawnPoint", "DummyList")
	addParam("Point1", "Dummy")
	addParam("Point2", "Dummy")
end

objectList = {}
spellName = "Script_MineTrap"

function preload()
	SentryTrapPreload()
	table.insert( skills, spellName )
end


function onLoadMap()
	CreateSentryTrap( getDummyParam( "Point1" ), getDummyParam( "Point2" ) )
	objectList = getDummyList("SpawnPoint")
end

function onTriggerEntered( trigger )
	if SentryTrapOnTriggered( trigger ) then
		trigger:enable( false )
		
		for i = 1, #objectList do
			local dummy = objectList[ i ]
			castSpell( spellName, dummy.position )
		end
	end
end

function onObjectDestroyed( object, soldier )
	SentryTrapOnObjectDestroyed( object )
end
