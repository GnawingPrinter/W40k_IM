
isSquad = false
activationArea = nil
enemiesKilled = 0
enemyCount = 0

function collectParams()
	addParam("EldarTyranidAmbush_SpawnList", "DummyList")
	addParam("EldarTyranidAmbush_ActivationArea", "Trigger")
end

function decideSoldierType()
	isSquad = false
	local monsterSetting = getMonsterSetting()
	if monsterSetting == "Eldar" or monsterSetting == "Eldar_Indoors" then
		soldierType = "Warp_Spider"
	elseif monsterSetting == "Tyranid" or monsterSetting == "Tyranid_basic" then
		soldierType = "Ravener"
	else
		isSquad = true
		soldierType = "micro_melee_normal"
	end
	
	return soldierType, isSquad
end

function preload()
	soldierType,isSquad = decideSoldierType()
	if isSquad then
		table.insert( groups, soldierType )
	else
		table.insert( soldiers, soldierType )
	end
end

function onLoadMap()
	activationArea = createTrigger( "EldarTyranidAmbush_ActivationArea", "Script_EldarTyranidAmbush_" .. tostring( getID() ) .. "_ActivationArea")
end

function onTriggerEntered( trigger )
	if trigger == activationArea then
		trigger:enable( false )
		
		-- Battle zene --
		setMusic( 0.4 )
		
		local activator = nil
		activator = getSoldier( trigger.soldierId )
		
		soldierType,isSquad = decideSoldierType()

		local dummyList = getDummyList( "EldarTyranidAmbush_SpawnList" )
		if isSquad then
			for i = 1, #dummyList do
				local squad = spawnEnemyGroup( soldierType, dummyList[ i ].position, dummyList[ i ].orient )
				if squad:valid() then
					for i = 1, squad:soldierCount() do
						local soldier = squad:getSoldier( i )
						if soldier:valid() then
							bindSoldier(soldier)
							enemyCount = enemyCount + 1
							if activator:valid() then
								soldier:attack( activator )
							end
						end
					end
				end
			end
		else
			for i = 1, #dummyList do
				local soldier = spawnSoldier( soldierType, "", dummyList[ i ].position, dummyList[ i ].orient, 1 )
				if soldier:valid() then
					bindSoldier( soldier )
					enemyCount = enemyCount + 1
					if activator:valid() then
						soldier:attack( activator )
					end
				end
			end
		end

	end
end

function onSoldierDied( soldier, attacker )
	enemiesKilled = enemiesKilled + 1

	-- Ha minden ellenfelet megoltunk, akkor allitsuk vissza a zenet -
	if enemiesKilled == enemyCount then
		setMusic( 0.2 )
		finish()
	end
end
