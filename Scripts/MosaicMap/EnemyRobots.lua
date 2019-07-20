myPanel = nil
soldierType = "Rebel_Guardsman"
soldiers = {}

function collectParams()
	addParam("Panel", "Dummy", 1 )
	addParam("Robots", "DummyList", 1 )
end

function preload()
	table.insert( soldiers, soldierType )
end

function onLoadMap()
	local dummy = getDummyParam("Panel")
	if dummy.valid then
		myCogitatorObject = createScriptObject( "EnemyRobots_Panel", "Object_Cogitator01", dummy.position, dummy.orient, "Active" )
	end
	
	dummyList = getDummyList("Robots")
	for i=1,#dummyList do
		soldiers[ i ] = spawnSoldier( soldierType, "Robot", dummyList[ i ].position, dummyList[ i ].orient, 3 )
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
