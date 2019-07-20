scriptActive = false
scriptFinished = false
allyGroup = nil
warpGate = nil
VIPSoldier = nil

VIPType = "Rebel_Psyker"
AllyGroupType = "Imperial_Guards"
EnemyType = "Close_WarpGate_Gate"
startFightRange = 20
skillName = "Script_CloseWarpGate_Cast"
failedSkill = "Script_CloseWarpGate_Failed"
sideQuestId = "CloseWarpGate" .. tostring( getID() )

remainingTime = 0.0
scriptTime = 120.0
markerID = 0

function collectParams()
	addParam("VIPLocation", "Dummy")
	addParam("AllyGroup", "Dummy")
	addParam("WarpGate", "Dummy")
end

function preload()
	table.insert( soldiers, VIPType )
	table.insert( soldiers, EnemyType )
	table.insert( groups, AllyGroupType )
	table.insert( skills, skillName)
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
	
	removeMarker( markerID )

	scriptFinished = true
	removeAllMarkers()
	finish()
end

function onLoadMap()
	local allyDummy = getDummyParam( "AllyGroup" )
	local enemyDummy = getDummyParam( "WarpGate" )
	local VIPDummy = getDummyParam( "VIPLocation" )

	if not allyDummy.valid or not enemyDummy.valid or not VIPDummy.valid then
		console.log("Invalid params")
		finish()
		return
	end

	createCircleTrigger( tostring( getID() ) .. "_trigger_ally", allyDummy.position, startFightRange )
	createCircleTrigger( tostring( getID() ) .. "_trigger_enemy", enemyDummy.position, startFightRange )

	allyGroup = spawnAllyGroup( AllyGroupType, allyDummy.position, allyDummy.orient )
	warpGate = spawnEnemy( EnemyType, "WarpGate", enemyDummy.position, enemyDummy.orient )
	VIPSoldier = spawnAlly( VIPType, "Psyker", VIPDummy.position, VIPDummy.orient )

	if allyGroup == nil or warpGate == nil or VIPSoldier == nil then
		console.log("Could not spawn")
		finish()
		return
	end
	
	allyGroup:setTDGuard( allyDummy.position, allyDummy.orient )

	VIPSoldier:addToSquad( allyGroup.ID )
	bindSoldier( VIPSoldier )
	VIPSoldier:setInactive( true )

	bindSoldier( warpGate )
	warpGate:setInactive( true )
	warpGate:setUntargettable( true )

	activateGroup( allyGroup, false )
end

function onTriggerEntered( trigger )
	trigger:enable( false )

	if scriptActive or scriptFinished then
		return
	end
	
	VIPSoldier:update()

	scriptActive = true
	VIPSoldier:setInactive( false )
	warpGate:setInactive( false )

	activateGroup( allyGroup, true )
	addMarker( VIPSoldier, "target" )
	
	warpGate:attack( VIPSoldier )

	VIPSoldier:setAI( false, -1.0 )
	VIPSoldier:cast( skillName, warpGate )
	
	local dest = warpGate.position
	local ori = dest - VIPSoldier.position
	ori = ori:normal()
	VIPSoldier:move( VIPSoldier.position, ori )

	remainingTime = scriptTime

	local questDesc = {}
	questDesc.id = sideQuestId
	questDesc.title = "sidequest.CloseWarpGate.title"
	questDesc.objective = "sidequest.CloseWarpGate.objective"
	questDesc.progress = 1.0
	addSideQuest( questDesc )
	
	markerID = addMarker( VIPSoldier, "progress" )
	setMarkerProgress( markerID, scriptTime )
end

function onSoldierDied( soldier )
	if soldier == VIPSoldier then
		warpGate:cast( failedSkill, warpGate )
		setFinished( false )
	end
end

function execute()
	if scriptActive and not scriptFinished then
		remainingTime = remainingTime - 1.0
		setSideQuestProgress( sideQuestId, remainingTime / scriptTime )
		if remainingTime <= 0.0 then
			setFinished( true )
			VIPSoldier:stopCasting( skillName )
			VIPSoldier:setAI( true, -1.0 )
			warpGate:kill()
		end
	end
end