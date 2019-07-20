function collectParams()
	addParam("SpawnPoint", "Dummy")
	addParam("TargetPoint", "Dummy")
	addParam("Group", "SoldierGroup" )
	addParam("ActivationArea", "Trigger")
end

function preload()
	table.insert( groups, getPreloadSoldierType("Group") )
end

mySquad = nil
function onLoadMap()
	createTrigger( "ActivationArea", "Script_" .. tostring( getID() ) .. "_ActivationArea")
	local target = getDummyParam( "SpawnPoint" )
	if( target.valid ) then
		mySquad = spawnEnemyGroup( getSoldierType("Group"), target.position, target.orient )
	end
end

function onTriggerEntered( trigger )
	trigger:enable( false )
	if mySquad == nil then
		return
	end

	local target = getDummyParam( "TargetPoint" )
	if target.valid then
		mySquad:move( target.position )
		finish()
	end
end

function onSquadDied( squad )
	mySquad = nil
	finish()
end
