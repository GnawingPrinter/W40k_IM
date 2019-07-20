require "SentryTrap_Base"

function collectParams()
	addParam("SpawnPoint", "DummyList")
	addParam("Point1", "Dummy")
	addParam("Point2", "Dummy")
	local types = { "Trap_Bolter", "Trap_Flamer", "Trap_Rocket" }
	addCustomParam("SpawnType", types )
end

function preload()
	SentryTrapPreload()
	table.insert(soldiers,getPreloadString("SpawnType"))
end

objectList = {}
spawnSoldierType = ""

function onLoadMap()
	CreateSentryTrap( getDummyParam( "Point1" ), getDummyParam( "Point2" ) )
	objectList = getDummyList("SpawnPoint")
	spawnSoldierType = getStringParam("SpawnType")
end

function onTriggerEntered( trigger )
	if SentryTrapOnTriggered( trigger ) then
		trigger:enable( false )
		
		for i = 1, #objectList do
			local dummy = objectList[ i ]
			spawnEnemy( spawnSoldierType, "SentryTrap", dummy.position, dummy.orient )
		end
	end
end

function onObjectDestroyed( object, soldier )
	SentryTrapOnObjectDestroyed( object )
end
