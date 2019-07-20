require "SentryTrap_Base"
objectList = {}
spawnSoldierType = "Tarantula_Enemy"

function collectParams()
	addParam("SpawnPoint", "DummyList")
	addParam("Point1", "Dummy")
	addParam("Point2", "Dummy")
end

function preload()
	SentryTrapPreload()
	table.insert( soldiers, spawnSoldierType )
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
			spawnEnemy( spawnSoldierType, "SentryTrap", dummy.position, dummy.orient )
		end
	end
end

function onObjectDestroyed( object, soldier )
	SentryTrapOnObjectDestroyed( object )
end
