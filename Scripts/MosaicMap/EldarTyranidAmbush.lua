
soldierType = ""
isSquad = false
activationArea = nil

function collectParams()
	addParam("EldarTyranidAmbush_SpawnList", "DummyList")
	addParam("EldarTyranidAmbush_ActivationArea", "Trigger")
end

function preload()
	if isSquad then
		table.insert( squads, soldierType )
	else
		table.insert( soldiers, soldierType )
	end
end

function onLoadMap()
	activationArea = createTrigger( "EldarTyranidAmbush_ActivationArea", "Script_EldarTyranidAmbush_" .. tostring( getID() ) .. "_ActivationArea")
	
	local monsterSetting = getMonsterSetting()
	if monsterSetting == "Eldar" or monsterSetting == "Eldar_Indoors" then
		soldierType = "Warp_Spider"
	elseif monsterSetting == "Tyranid" or monsterSetting == "Tyranid_basic" then
		soldierType = "Ravener"
	else
		isSquad = true
		soldierType = "micro_melee_normal"
	end
end

function onTriggerEntered( trigger )
	if trigger == activationArea then
		trigger:enable( false )
		
		local activator = nil
		activator = getSoldier( trigger.soldierId )
		
		local dummyList = getDummyList( "EldarTyranidAmbush_SpawnList" )
		if isSquad then
			for i = 1, #dummyList do
				local squad = spawnEnemyGroup( soldierType, dummyList[ i ].position, dummyList[ i ].orient )
				if squad:valid() then
					bindSquad( squad )
					for i = 1, squad:soldierCount() do
						local soldier = squad:getSoldier( i )
						if soldier:valid() then
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
					if activator:valid() then
						soldier:attack( activator )
					end
				end
			end
		end

	end
end
