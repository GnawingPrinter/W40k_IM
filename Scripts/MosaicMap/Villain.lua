SoldierType = "Villain"
function collectParams()
	addParam("Position", "DummyList", 3)
end

function preload()
	table.insert( soldiers, SoldierType )
end

function onLoadMap()	
	local rndNum = math.random( 100 );
	local spawnCount = 0
	if getBoolParam("ForceMaxChance") then
		spawnCount = 2
	else
		if rndNum < 20 then
			spawnCount = 2
		elseif rndNum < 50 then
			spawnCount = 1
		end
	end
	
	spawnCount = spawnCount + getWarzoneEffect("BonusVillains")

	local dummyList = getDummyListRandomized("Position")
	if #dummyList < 3 then
		console.log("Invalid params")
		finish()
		return
	end

	spawnCount = math.min( #dummyList, spawnCount )
	
	for iSol = 1, spawnCount do
		local dummy = dummyList[ iSol ]
		spawnEnemy( SoldierType, "", dummy.position, dummy.orient )
	end
	finish()
end
