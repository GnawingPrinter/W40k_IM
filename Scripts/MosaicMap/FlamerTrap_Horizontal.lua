require "SentryTrap_Base"
function collectParams()
	addParam("FlamerTrap_Horizontal_SpawnPoint", "DummyList")
	addParam("FlamerTrap_Horizontal_Offset", "Float")
	addParam("FlamerTrap_Horizontal_Point1", "Dummy")
	addParam("FlamerTrap_Horizontal_Point2", "Dummy")
end

objectList = {}
spellName = "Script_FlameTrap_Horizontal"
scriptTime = 0.0
offset = 0.0

magicDelay = {}

function preload()
	SentryTrapPreload()
	table.insert( skills, spellName )
end


function onLoadMap()
	CreateSentryTrap( getDummyParam( "FlamerTrap_Horizontal_Point1" ), getDummyParam( "FlamerTrap_Horizontal_Point2" ) )
	objectList = getDummyList("FlamerTrap_Horizontal_SpawnPoint")
	offset = getFloatParam( "FlamerTrap_Horizontal_Offset" )
end

function onTriggerEntered( trigger )
	if SentryTrapOnTriggered( trigger ) then
		trigger:enable( false )
		
		for i = 1, #objectList do
			local dummy = objectList[ i ]
			magicDelay[i] = {}
			magicDelay[i].pos = vector3.new( dummy.position.x,dummy.position.y,offset )
			magicDelay[i].orient = dummy.orient
			magicDelay[i].time = 0
			magicDelay[i].magic = 0
		end
		
		scriptTime = 20.0
	end
end

function onObjectDestroyed( object, soldier )
	SentryTrapOnObjectDestroyed( object )
end

function execute()
	if scriptTime > 0.0 then
		scriptTime = scriptTime - 1.0
		if scriptTime <= 0.0 then
			for i = 1, #magicDelay do
				stopMagic( magicDelay[ i ].magic )
			end
		else
			for i = 1, #magicDelay do
				local data = magicDelay[ i ]
				data.time = data.time - 1
				if data.time < 0 then
					if data.magic == 0 then
						data.magic = castSpell(spellName, data.pos, data.orient)
					end
				end
			end
		end
	end
	return false
end