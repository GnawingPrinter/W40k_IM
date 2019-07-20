SoldierType = "Villain"
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
	
	spawnEnemy( SoldierType, "", villainDummy.position, villainDummy.orient )
	createChest( "Lootbox_BIG", chestDummy.position, chestDummy.orient )
	
	createTeleport( teleportInDummy.position, teleportInDummy.orient, teleportOutDummy.position + teleportOutDummy.orient * 20.0, teleportOutDummy.orient )
	createTeleport( teleportOutDummy.position, teleportOutDummy.orient, teleportInDummy.position + teleportInDummy.orient * 20.0, teleportInDummy.orient )
	createCircleTrigger( "banterTrigger", teleportInDummy.position, 20 )
end


function onTriggerEntered( trigger )
	trigger:enable( false )
	playBanterGroup( "BNT_HiddenArea", trigger.soldierId )
end