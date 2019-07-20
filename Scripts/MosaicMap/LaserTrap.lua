require "SentryTrap_Base"
function collectParams()
	addParam("SpawnPoint", "DummyList")
	addParam("Point1", "Dummy")
	addParam("Point2", "Dummy")
end

objectList = {}
spellName = "Script_LaserTrap"
scriptTime = 0.0

magics = {}

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
			magics[ i ] = castSpell( spellName, dummy.position )
		end
		
		scriptTime = 30.0
	end
end

function onObjectDestroyed( object, soldier )
	SentryTrapOnObjectDestroyed( object )
end

function execute()
	if scriptTime > 0.0 then
		scriptTime = scriptTime - 1.0
		if scriptTime <= 0.0 then
			for i = 1, #magics do
				stopMagic( magics[ i ] )
			end
		end
	end
	return false
end