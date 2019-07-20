myPanel = nil
mySoldierType = "World_Tarantula_summoned"
mySoldier = nil

function collectParams()
	addParam("Panel", "Dummy", 1 )
	addParam("Unit", "Dummy", 1 )
end

function preload()
	table.insert( soldiers, mySoldierType )
end

function onLoadMap()
	local dummy = getDummyParam("Panel")
	if dummy.valid then
		myCogitatorObject = createScriptObject( "EnemyTurrets_Panel", "Object_Cogitator01", dummy.position, dummy.orient, "Active" )
	end
	
	dummy = getDummyParam("Unit")
	if not dummy.valid then
		console.log("not enough dummies")
		finish()
		return
	end
	
	mySoldier = spawnEnemy( mySoldierType, "Turret", dummy.position, dummy.orient )
	if not mySoldier:valid() then
		console.log( "Could not spawn mySoldier" )
		finish()
		return
	end
	
	bindSoldier( mySoldier )

	mySoldier:setAI( false, -1.0 )
end

function onObjectInteracted( object, interactor )
	object:changeState("Inactive")

	mySoldier:setAI( true, -1.0 )
	mySoldier:makeAlly( interactor )
	mySoldier:setFollow( interactor )
end

function onSoldierDied( soldier )
	addLoot( "grenade_chest", soldier.position )
	myPanel:changeState("Inactive")
	mySoldier = nil
end
