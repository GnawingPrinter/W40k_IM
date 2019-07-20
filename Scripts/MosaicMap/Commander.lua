YesCommanders = { "Average_melee_commander", "Average_ranged_commander", "Strong_melee_commander", "Strong_ranged_commander" }
NoCommanders = { "Average_melee_normal_and_medium", "Average_ranged_normal_and_medium", "Strong_melee_normal_and_medium", "Strong_ranged_normal_and_medium" }

function collectParams()
	addParam("Position", "DummyList", 2)
end

function preload()
	for i = 1, #YesCommanders do
		table.insert( groups, YesCommanders[ i ] )
	end
	for i = 1, #NoCommanders do
		table.insert( groups, NoCommanders[ i ] )
	end
end

function onLoadMap()	
	local rndNum = math.random( 100 );
	local spawnCount = 1
	if getBoolParam("ForceMaxChance") then
		spawnCount = 3
	else
		if rndNum < 10 then
			spawnCount = 3
		elseif rndNum < 40 then
			spawnCount = 2
		end
	end
	
	local dummyList = getDummyListRandomized("Position")
	if #dummyList < 2 then
		console.log("Invalid params")
		finish()
		return
	end
	
	for iSol = 1, #dummyList do
		local dummy = dummyList[ iSol ]
		
		if iSol <= spawnCount then
			local randomIdx = math.random( #YesCommanders )
			spawnEnemyGroup( YesCommanders[randomIdx], dummy.position, dummy.orient )
		else
			local randomIdx = math.random( #NoCommanders )
			spawnEnemyGroup( NoCommanders[randomIdx], dummy.position, dummy.orient )
		end
	end
	finish()
end
