scriptActive = false
scriptFinished = false
allyGroup = nil
enemyGroup = nil
sideQuestId = "allyProtect_" .. tostring( getID() )

EnemyGroupType = "Average_ranged_normal"
AllyGroupType = "Imperial_Guards"
startFightRange = 30

soldierCount = 0

function collectParams()
	addParam("AllyGroup", "Dummy")
	addParam("EnemyGroup", "Dummy")
end

function preload()
	table.insert( groups, AllyGroupType )
	table.insert( groups, EnemyGroupType )
end

function activateGroup( group, active )
	for i = 1, group:soldierCount() do
		local soldier = group:getSoldier( i )
		if soldier:valid() then
			soldier:setInactive( not active )
		end
	end
end

function setFinished( success )
	setSideQuestProgress( sideQuestId, 0.0 )
	setSideQuestCompleted( sideQuestId )
	if success then
		playVideoMessage("AllyProtect","Victory")
	else
		playVideoMessage("AllyProtect","Defeat")
	end

	scriptFinished = true
	removeAllMarkers()
	finish()
end

function onLoadMap()
	local allyDummy = getDummyParam( "AllyGroup" )
	local enemyDummy = getDummyParam( "EnemyGroup" )

	if not allyDummy.valid or not enemyDummy.valid then
		console.log("Invalid params")
		finish()
		return
	end

	createCircleTrigger( tostring( getID() ) .. "_trigger_ally", allyDummy.position, startFightRange )
	createCircleTrigger( tostring( getID() ) .. "_trigger_enemy", enemyDummy.position, startFightRange )

	allyGroup = spawnAllyGroup( AllyGroupType, allyDummy.position, allyDummy.orient )
	enemyGroup = spawnEnemyGroup( EnemyGroupType, enemyDummy.position, enemyDummy.orient )

	if allyGroup == nil or enemyGroup == nil then
		console.log("Could not spawn")
		finish()
		return
	end

	activateGroup( allyGroup, false )
	activateGroup( enemyGroup, false )
end

function onTriggerEntered( trigger )
	trigger:enable( false )

	if scriptActive or scriptFinished then
		return
	end

	scriptActive = true

	activateGroup( allyGroup, true )
	activateGroup( enemyGroup, true )
	addMarker( allyGroup, "target" )
	
	local questDesc = {}
	questDesc.id = sideQuestId
	questDesc.title = "sidequest.allyprotect.title"
	questDesc.objective = "sidequest.allyprotect.objective"
	questDesc.progress = 1.0
	addSideQuest( questDesc )
	
	playVideoMessage("AllyProtect","Start")

	soldierCount = enemyGroup:soldierCount()
end

function onSquadDied( squad )
	if squad == enemyGroup then
		setFinished( true )

		local hero = findNearbyHero( vector.new(0,0), 0.0 )
		for i = 1, allyGroup:soldierCount() do
			local soldier = allyGroup:getSoldier( i )
			if soldier:valid() then
				addLoot("small_loot_per_person", soldier.position )
				if hero:valid() then
					soldier:setFollow( hero )
				end
			end
		end
	elseif squad == allyGroup then
		setFinished( false )
	end
end

function execute()
	if scriptActive and soldierCount > 0 then
		setSideQuestProgress( sideQuestId, enemyGroup:soldierCount() / soldierCount )
	end
end