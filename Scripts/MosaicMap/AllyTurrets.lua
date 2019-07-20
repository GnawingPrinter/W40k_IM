myPanel = nil
soldierType = "World_Tarantula_summoned"

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
		myCogitatorObject = createScriptObject( "AllyTurrets_Panel", "Object_Cogitator01", dummy.position, dummy.orient, "Active_interactTime" )
	end
end

function onObjectInteracted( object, interactor )
	object:changeState("Inactive")
end

function onObjectStateChanged( object )
	if object.state == "Inactive" then
		local dummyList = getDummyList("Turrets")
		for i=1,#dummyList do
			spawnAlly( soldierType, "Turret", dummyList[ i ].position, dummyList[ i ].orient )
		end
	end
end
