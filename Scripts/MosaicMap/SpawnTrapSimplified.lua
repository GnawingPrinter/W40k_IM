activationArea = nil

function collectParams()
	addParam( "SpawnTrapSimplified_Group", "SoldierGroup", 1 )
	addParam( "SpawnTrapSimplified_Positions", "DummyList", 1 )
	addParam( "SpawnTrapSimplified_ActivationArea", "Trigger", 1 )
end

function preload()
	table.insert( groups, getPreloadSoldierType( "SpawnTrapSimplified_Group" ) )
end

function onLoadMap()
	activationArea = createTrigger( "SpawnTrapSimplified_ActivationArea", "Script_SpawnTrapSimplified_" .. tostring( getID() ) .. "_ActivationArea" )
end

function onTriggerEntered( trigger )
	if trigger == activationArea then
		trigger:enable( false )
		
		local activator = nil
		activator = getSoldier( trigger.soldierId )
		
		local dummyList = getDummyList( "SpawnTrapSimplified_Positions" )
		for i = 1, #dummyList do
			local squad = spawnEnemyGroup( getSoldierType( "SpawnTrapSimplified_Group" ), dummyList[ i ].position, dummyList[ i ].orient )
			if squad:valid() then
				bindSquad( squad )
				if activator:valid() then
					for i = 1, squad:soldierCount() do
						local soldier = squad:getSoldier( i )
						if soldier:valid() then
							soldier:attack( activator )
						end
					end
				end
			end
		end
	end
end
