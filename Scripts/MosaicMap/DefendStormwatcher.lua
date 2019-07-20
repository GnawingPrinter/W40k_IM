fightActive = false
fightFinished = false
allyGroup = nil
enemyGroup = nil
sideQuestId = "defendStormwatcher_" .. tostring( getID() )
intel = nil
leader = nil

EnemyGroupType = "Average_ranged_normal"
AllyGroupType = "Tarot_Stormwatcher"
teleportSkill = "Script_TeleportHide"

soldierCount = 0

function collectParams()
	addParam("ActivateTrigger", "Trigger")
	addParam("AllyGroup", "Dummy")
	addParam("EnemyGroup", "Dummy")
	addParam("Intel", "Dummy")
end

function preload()
	table.insert( groups, AllyGroupType )
	table.insert( groups, EnemyGroupType )
	table.insert( skills, teleportSkill )
end

function activateGroup( group, active )
	for i = 1, group:soldierCount() do
		local soldier = group:getSoldier( i )
		if soldier:valid() then
			soldier:setInactive( not active )
		end
	end
end

function onLoadMap()
	local allyDummy = getDummyParam( "AllyGroup" )
	local enemyDummy = getDummyParam( "EnemyGroup" )

	if not allyDummy.valid or not enemyDummy.valid then
		console.log("Invalid params")
		finish()
		return
	end

	createTrigger( "ActivateTrigger", "startTrigger" )

	allyGroup = spawnAllyGroup( AllyGroupType, allyDummy.position, allyDummy.orient )
	enemyGroup = spawnEnemyGroup( EnemyGroupType, enemyDummy.position, enemyDummy.orient )

	if allyGroup == nil or enemyGroup == nil then
		console.log("Could not spawn")
		finish()
		return
	end

	activateGroup( allyGroup, false )
	activateGroup( enemyGroup, false )
	
	leader = allyGroup:getSoldier(1)
	bindSoldier(leader)
	
	local dummy = getDummyParam("Intel")
	intel = createScriptObject("intel", "Clue", dummy.position, dummy.orient, "Inactive" )
end

function onTriggerEntered( trigger )
	trigger:enable( false )

	if fightActive or fightFinished then
		return
	end

	fightActive = true

	activateGroup( allyGroup, true )
	activateGroup( enemyGroup, true )
	addMarker( allyGroup, "target" )
	
	local questDesc = {}
	questDesc.id = sideQuestId
	questDesc.title = "sidequest.defendStormwatcher.title"
	questDesc.objective = "sidequest.defendStormwatcher.objective"
	questDesc.progress = 1.0
	addSideQuest( questDesc )
	
	playVideoMessage("defendStormwatcher","Start")

	soldierCount = enemyGroup:soldierCount()
end

function onSquadDied( squad )
	if fightFinished then
		return
	end
	
	if squad == enemyGroup then
		setSideQuestCompleted( sideQuestId )
		playVideoMessage("defendStormwatcher","Defeat")
		fightFinished = true
		removeAllMarkers()

		for i = 1, allyGroup:soldierCount() do
			local soldier = allyGroup:getSoldier( i )
			if soldier:valid() then
				soldier:setHeroFollow( true )
			end
		end
		
		playVideoMessage("defendStormwatcher","Victory")
		
		intel:changeState("Active_FastInteract")
		addMarker( intel, "target" )

		leader:teleportOut()
	end
end

function onSoldierDied( soldier, attacker )
	if soldier == leader then
		setSideQuestProgress( sideQuestId, 0.0 )
		setSideQuestCompleted( sideQuestId )
		playVideoMessage("defendStormwatcher","Defeat")
		fightFinished = true
		removeAllMarkers()
		finish()
	end
end

function onObjectInteracted( obj, interactor )
	addVoidCrusadeUnlock("Secret_Mission_GAMMA")
	playVideoMessage("defendStormwatcher","StormWatcherIntelFound")

	obj:changeState("Inactive")
	removeAllMarkers()
	finish()
end

function execute()
	if fightActive and soldierCount > 0 then
		setSideQuestProgress( sideQuestId, enemyGroup:soldierCount() / soldierCount )
	end
end