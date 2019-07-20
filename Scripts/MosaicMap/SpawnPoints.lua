function collectParams()
	addParam("SpawnPoint", "DummyList")
	addParam("Group", "SoldierGroup" )
	addParam("ActivationArea", "Trigger")
end

spawnEffectSkill = "Summon_chaos__effect"

function preload()
	table.insert( groups, getPreloadSoldierType("Group") )
	table.insert( skills, spawnEffectSkill )
end

objectList = {}
soldiersToSpawn = {}
curTime = 0.0

function onLoadMap()
	createTrigger( "ActivationArea", "Script_" .. tostring( getID() ) .. "_ActivationArea")
	local dummies = getDummyList("SpawnPoint")
	for i = 1, #dummies do
		local name = "SpawnArea" .. tostring( i )
		local object = createScriptObject( name, "Spawn", dummies[ i ].position, dummies[ i ].orient, "Inactive" )
		objectList[i]=object
	end
end

function onTriggerEntered( trigger )
	trigger:enable( false )

	for i = 1, #objectList do
		local object = objectList[ i ]
		if object.valid then
			object:changeState("Active")
		end
	end
end

function onObjectStateChanged( object )
	if object.state == "Active" then
		startSoldierSpawn(object)
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