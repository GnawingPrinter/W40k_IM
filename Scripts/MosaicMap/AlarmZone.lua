function collectParams()
	addParam("AlarmPole", "Dummy")
	addParam("Group", "SoldierGroup" )
end

spawnEffectSkill = "Summon_chaos__effect"

function preload()
	table.insert( groups, getPreloadSoldierType("Group") );
	table.insert( skills, spawnEffectSkill )
end

myObjectID = nil
soldiersToSpawn = {}
curTime = 0.0
summonDelay = 0.0

function getMyObject()
	return scriptObject.new( myObjectID )
end

function onLoadMap()
	local dummy = getDummyParam("AlarmPole")
	if dummy.valid then
		local object = createScriptObject( "Alarm Pole", "Alarm_Pole", dummy.position, dummy.orient, "Inactive" )
		if object.valid then
			createCircleTrigger( "Script_" .. tostring( getID() ) .. "_Alarm Trigger", dummy.position, 20 )
			
			myObjectID = object.ID
		end
	end
end

function alarm()
	local myObject = getMyObject()
	if myObject ~= nil then
		if myObject.state == "Inactive" and not myObject.inTransition then
			myObject:changeState("Active")
			
			playBanterGroup("BNT_AlarmBeacon_On")
		end
	end
end

function onTriggerEntered( trigger )
	trigger:enable( false )
	alarm()
end

function onObjectStateChanged( object )
	if object.state == "Active" then
		summonDelay = 2
		playBanterGroup("BNT_AlarmBeacon_Fail")
	end
end

function onObjectDestroyed( object, killer )
	if object.inTransition then
		playBanterGroup("BNT_AlarmBeacon_Success")
	end
	summonDelay = 0
	object:changeState("Destroyed")
end

function onObjectDamageTaken( object, attacker )
	alarm()
end

function startSoldierSpawn()
	local myObject = getMyObject()

	setUpdateInterval( 0.1 )
	local delay = 0.3
	local squad = spawnEnemyGroup( getSoldierType("Group"), myObject.position + myObject.orient * 30, myObject.orient )
	for i = 1, squad:soldierCount() do
		local soldier = squad:getSoldier( i )
		if soldier:valid() then
			delay = delay + ( math.random() * 0.1 ) + 0.4
			
			soldier:setInvisible( true, -1.0 )
			soldier:setAI( false, -1.0 )
			
			soldiersToSpawn[i] = {}
			soldiersToSpawn[i].soldier = soldier
			soldiersToSpawn[i].delay = delay
			soldiersToSpawn[i].spawned = false
		end
	end
end

function execute()
	local myObject = getMyObject()

	if summonDelay > 0 then
		summonDelay = summonDelay - 1
		if summonDelay <= 0 then
			startSoldierSpawn()
		end
	else
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
						
						myObject:playEffect("Summon")
					else
						finished = false
					end
				end
			end
			
			if finished == true then
				soldiersToSpawn = {}
				if myObject.state == "Active" then
					myObject:changeState("Locked")
				end
			end
		end
	end
end