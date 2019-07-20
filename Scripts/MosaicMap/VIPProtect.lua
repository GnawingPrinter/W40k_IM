scriptActive = false
scriptFinished = false
allyGroup = nil
enemyGroup = nil
VIPSoldier = nil

VIPType = "Rebel_Guardsman"
EnemyGroupType = "Average_ranged_normal"
AllyGroupType = "Strong_ranged_commander"
startFightRange = 30

function collectParams()
	addParam("VIPLocation", "Dummy")
	addParam("AllyGroup", "Dummy")
	addParam("EnemyGroup", "Dummy")
end

function preload()
	table.insert( groups, EnemyGroupType )
	table.insert( groups, AllyGroupType )
	table.insert( soldiers, VIPType )
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
	-- TODO melleksquest GUI-t torolni
	scriptFinished = true
	removeAllMarkers()
	finish()
end

function onLoadMap()
	local allyDummy = getDummyParam( "AllyGroup" )
	local enemyDummy = getDummyParam( "EnemyGroup" )
	local VIPDummy = getDummyParam( "VIPLocation" )

	if not allyDummy.valid or not enemyDummy.valid or not VIPDummy.valid then
		console.log("Invalid params")
		finish()
		return
	end

	createCircleTrigger( tostring( getID() ) .. "_trigger_ally", allyDummy.position, startFightRange )
	createCircleTrigger( tostring( getID() ) .. "_trigger_enemy", enemyDummy.position, startFightRange )

	allyGroup = spawnAllyGroup( AllyGroupType, allyDummy.position, allyDummy.orient )
	enemyGroup = spawnEnemyGroup( EnemyGroupType, enemyDummy.position, enemyDummy.orient )
	VIPSoldier = spawnAlly( VIPType, "VIP", VIPDummy.position, VIPDummy.orient )

	if allyGroup == nil or enemyGroup == nil or VIPSoldier == nil then
		console.log("Could not spawn")
		finish()
		return
	end

	VIPSoldier:addToSquad( allyGroup.ID )
	bindSoldier( VIPSoldier )
	VIPSoldier:setInactive( true )

	activateGroup( allyGroup, false )
	activateGroup( enemyGroup, false )
end

function onTriggerEntered( trigger )
	trigger:enable( false )

	if scriptActive or scriptFinished then
		return
	end

	scriptActive = true
	VIPSoldier:setInactive( false )

	activateGroup( allyGroup, true )
	activateGroup( enemyGroup, true )
	addMarker( VIPSoldier, "target" )
end

function onSoldierDied( soldier )
	if soldier == VIPSoldier then
		setFinished( false )
	end
end

function onSquadDied( squad )
	if squad == enemyGroup then
		setFinished( true )

		VIPSoldier:update()
		addLoot("very_good_loot_with_much_fate_points", VIPSoldier.position )
	end
end
