SoldierType = "Villain"
HiddenFoeType = "HiddenFoesGrp"
enemyGroup = nil

function collectParams()
	addParam("Villain", "Dummy", 1)
	addParam("Chest", "Dummy", 1)
	addParam("TeleportIn", "Dummy", 1)
	addParam("TeleportOut", "Dummy", 1)
end

function preload()
	table.insert( soldiers, SoldierType )
end

function setParameterDefaultValue( name )
	if name == "chance" then
		setDefaultInt( 10 )
		return
	end
end

function checkPrequisites( missionData )
	if missionData.missionType == "purge" then
		return false
	end

	return true
end

function onLoadMap()	
	local villainDummy = getDummyParam("Villain")
	local chestDummy = getDummyParam("Chest")
	local teleportInDummy = getDummyParam("TeleportIn")
	local teleportOutDummy = getDummyParam("TeleportOut")

	if not villainDummy.valid or not chestDummy.valid or not teleportInDummy.valid or not teleportOutDummy.valid then
		console.log("Invalid params")
		finish()
		return
	end
	
	if isEventActive("hidden_foes") == true and getEventCounter("hidden_room") < 60 then
		enemyGroup = spawnEnemyGroup( HiddenFoeType, villainDummy.position, villainDummy.orient)
		createChest( "Lootbox_HiddenFoe", chestDummy.position, chestDummy.orient )
		createCircleTrigger( "banterTrigger", teleportOutDummy.position, 20 )
	else
		spawnEnemy( SoldierType, "", villainDummy.position, villainDummy.orient )
		createChest( "Lootbox_BIG", chestDummy.position, chestDummy.orient )
	end
	hiddenArea()
	createTeleport( teleportInDummy.position, teleportInDummy.orient, teleportOutDummy.position + teleportOutDummy.orient * 20.0, teleportOutDummy.orient, true )
	createTeleport( teleportOutDummy.position, teleportOutDummy.orient, teleportInDummy.position + teleportInDummy.orient * 20.0, teleportInDummy.orient, false )	
end


function onTriggerEntered( trigger )
	trigger:enable( false )
	playBanter( "BNT_HiddenFoe", trigger.soldierId )
end

function onSquadDied( squad )
	if squad == enemyGroup then
		hiddenAreaCompleted()
		feedback("hiddenfoeskilled")
	end
end