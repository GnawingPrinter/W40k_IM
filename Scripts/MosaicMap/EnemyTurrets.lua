myPanel = nil
soldierType = "World_Tarantula_summoned"
soldiers = {}

function collectParams()
	addParam("Panel", "Dummy", 1 )
	addParam("Turrets", "DummyList", 1 )
end

function preload()
	table.insert( soldiers, soldierType )
end

function onLoadMap()
	local dummy = getDummyParam("Panel")
	if dummy.valid then
		myCogitatorObject = createScriptObject( "EnemyTurrets_Panel", "Object_Cogitator01", dummy.position, dummy.orient, "Active" )
	end
	
	dummyList = getDummyList("Turrets")
	for i=1,#dummyList do
		soldiers[ i ] = spawnSoldier( soldierType, "Turret", dummyList[ i ].position, dummyList[ i ].orient, 3 )
		soldiers[ i ]:setAI( false, -1.0 )
		soldiers[ i ]:setInactive( true )
	end
end

function onObjectInteracted( object, interactor )
	object:changeState("Inactive")
end

function onObjectStateChanged( object )
	for i=1,#soldiers do
		soldiers[ i ]:setAI( true, -1.0 )
		soldiers[ i ]:setInactive( false )
	end
end
