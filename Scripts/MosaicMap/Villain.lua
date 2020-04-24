SoldierType = "Villain"
function collectParams()
	addParam("Position", "DummyList", 3)
end

function preload()
	table.insert( soldiers, SoldierType )
end

bountySoldier = nil

function onLoadMap()	
	local rndNum = math.random( 100 );
	local spawnCount = 0
	local chanceMulti = getVillainBonusChance()
	if getBoolParam("ForceMaxChance") then
		spawnCount = 2
	else
		if rndNum < 20 * chanceMulti then
			spawnCount = 2
		elseif rndNum < 50 * chanceMulti then
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
	local dummySkip = 0
	
	--bounty target spawnolas
	if spawnCount >= 1 then
		local bountychance = getBountyTargetChance()
		local rndNum2 = math.random( 100 );
		if rndNum2 < bountychance then
			local soldier = getBountyTargetSoldier()
			console.log("bounty soldier: " .. soldier)
			if soldier ~= "" then
				local dummy = dummyList[ 1 ]
				bountySoldier = spawnEnemy( soldier, "", dummy.position, dummy.orient )
				bindSoldier( bountySoldier )
				
				createCircleTrigger( "bounty_trigger", dummy.position, 20 )

				
				dummySkip = 1
			end
		end
	end
	
	for iSol = 1 + dummySkip, spawnCount do
		local dummy = dummyList[ iSol ]
		spawnEnemy( SoldierType, "", dummy.position, dummy.orient )
	end
end

function onTriggerEntered( trigger )
	trigger:enable( false )
	playBanterGroup("BNT_BountyTarget")
end

function onSoldierDied( soldier )
	if soldier == bountySoldier then
		feedback("bountytargetkilled")
	end
	finish()
end
