require "SentryTrap_Base"
function collectParams()
	addParam("SpawnPoint", "DummyList")
	addParam("Group", "SoldierGroup" )
	addParam("Point1", "Dummy")
	addParam("Point2", "Dummy")
end

spawnEffectSkill = "Summon_chaos__effect"

function preload()
	SentryTrapPreload()
	table.insert( groups, getPreloadSoldierType("Group"))
	table.insert( skills, spawnEffectSkill )
end

objectList = {}

soldiersToSpawn = {}
curTime = 0.0

function onLoadMap()
	CreateSentryTrap( getDummyParam( "Point1" ), getDummyParam( "Point2" ) )
	
	local dummies = getDummyList("SpawnPoint")
	for i = 1, #dummies do
		local name = "SpawnArea" .. tostring( i )
		local object = createScriptObject( name, "TeleportBeaconAttackable", dummies[ i ].position, dummies[ i ].orient, "Inactive" )
		if object.valid then
			objectList[i]=object.ID
		end
	end
end

function startSoldierSpawn( myObject )
	setUpdateInterval( 0.1 )
	local delay = 0.3
	local squad = spawnEnemyGroup( getSoldierType("Group"), myObject.position + myObject.orient * 30, myObject.orient )
	for i = 1, squad:soldierCount() do
		local soldier = squad:getSoldier( i )
		if soldier:valid() then
			delay = delay + ( math.random() * 0.1 ) + 0.4
			
			soldier:setInvisible( true, -1.0 )
			soldier:setAI( false, -1.0 )
			
			local spawnObj = {}
			spawnObj.soldier = soldier
			spawnObj.delay = delay
			spawnObj.spawned = false
			spawnObj.object = myObject
			
			soldiersToSpawn[ #soldiersToSpawn + 1 ] = spawnObj
		end
	end
end

function onTriggerEntered( trigger )
	if not SentryTrapOnTriggered( trigger ) then
		return
	end

	trigger:enable( false )

	for i = 1, #objectList do
		local object = scriptObject.new( objectList[ i ] )
		if object.valid and object.state == "Inactive" then
			object:changeState("Active")
		end
	end
end

function onObjectDestroyed( object, soldier )
	for i = 1, #objectList do
		if object.ID == objectList[i] then
			object:changeState("Destroyed")
			return
		end
	end

	SentryTrapOnObjectDestroyed( object )
end

function onObjectStateChanged( object )
	if not scriptActive then
		return
	end
	
	if object.state == "Destroyed" then
		for i = 1, #objectList do
			local spawnObj = scriptObject.new( objectList[ i ] )
			if spawnObj.state ~= "Destroyed" then
				return
			end
		end
		
		scriptActive = false
		stopMagic( activeMagicID )

		for i = 1, #skulls do
			skulls[i]:changeState("Destroyed")
		end
	end

	for i = 1, #objectList do
		if object.ID == objectList[i] then
			if object.state == "Active" then
				startSoldierSpawn(object)
			end
			
			return
		end
	end
end

function execute()
	if #soldiersToSpawn > 0 then
		curTime = curTime + 0.1
		local finished = true
		for i = 1, #soldiersToSpawn do
			local spawnData = soldiersToSpawn[ i ]
			if spawnData.spawned == false then
				if spawnData.delay <= curTime then
					spawnData.spawned = true
					spawnData.soldier:setInvisible( false, -1.0 )
					spawnData.soldier:fade( false, 0.0 )
					spawnData.soldier:fade( true, 2.0 )
					-- meg 2 sec-ig ne mukodjon az AI
					spawnData.soldier:setAI( false, 2.0 )
					castSpell( spawnEffectSkill, spawnData.soldier )
					
					spawnData.object:playEffect("Summon")
				else
					finished = false
				end
			end
		end		

		if finished then
			soldierToSpawn = {}
		end
	end
end