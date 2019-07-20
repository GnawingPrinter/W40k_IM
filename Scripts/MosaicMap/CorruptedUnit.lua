
spawnSoldierType = "Script_CorruptedUnit"
mySoldier = nil
function collectParams()
	addParam("Unit", "Dummy", 1 )
end

function preload()
	table.insert( soldiers, spawnSoldierType )
end

function onLoadMap()
	local dummy = getDummyParam("Unit")
	if dummy.valid then
		mySoldier = spawnEnemy( spawnSoldierType, "corruptedunit", dummy.position, dummy.orient )
		if not mySoldier:valid() then
			console.log( "Soldier does not exist" )
			finish()
			return
		end
		
		mySoldier:setAI( false, -1 )
	else
		console.log("No dummy found!")
		finish()
	end
end

function execute()
	local enemies = findNearbyEnemies( mySoldier.position, 15.0 )
	
	-- mivel o maga is enemy, ezert 1-nek kell lennie :D
	if #enemies == 1 then
		mySoldier:setInactive( true )
		addLoot( "Elite_monster", mySoldier.position )
		return true
	end
	
	return false
end