lastPos = nil

function collectParams()
	addParam("SpawnPoint", "Dummy", 1)
	addParam("Group", "SoldierGroup", 1)
end

function preload()
	table.insert( soldiers, spawnSoldierType )
end

function onLoadMap()
	local target = getDummyParam( "SpawnPoint" )
	spawnEnemyGroup( getSoldierType("Group"), target.position, target.orient )	
end

function onSquadDied( squad )
	createDataslate("dataslate", lastPos, "pickupable.encrypteddataslate")
end

function onSoldierDied(soldier)
	lastPos = soldier.position
end

function onLootPickedUp(name,soldier)
	addVoidCrusadeUnlock("EncryptedDataslate")
	playVideoMessage("EncryptedDataslate","Found")
	finish()
end