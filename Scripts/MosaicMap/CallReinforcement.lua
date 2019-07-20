function collectParams()
	addParam("Cogitator", "Dummy", 1 )
	addParam("TeleportBeacon", "Dummy", 1 )
	addParam("Group", "SoldierGroup" )
end

function preload()
	table.insert( groups, getPreloadSoldierType("Group") )
end

myTeleportBeacon = nil
myCogitatorObject = nil
mySoldier = nil

function onLoadMap()
	local dummy = getDummyParam("Cogitator")
	if dummy.valid then
		myCogitatorObject = createScriptObject( "Cogitator", "Object_Cogitator01", dummy.position, dummy.orient, "Active_for_AI" )
	end
	dummy = getDummyParam("TeleportBeacon")
	if dummy.valid then
		myTeleportBeacon = createScriptObject( "Teleport Beacon", "Teleport Beacon", dummy.position, dummy.orient, "Default" )
	end
end

function onObjectInteracted( object, interactor )
	object:changeState("Activated_By_AI")
	
	mySoldier = interactor
	mySoldier:setAI( false, -1.0 )
	bindSoldier( mySoldier )
end

function onObjectStateChanged( object )
	if object.state == "Activated_By_AI" then
		myTeleportBeacon:playEffect("Summon")
		spawnMinionGroup( mySoldier, getSoldierType("Group"), myTeleportBeacon.position, myTeleportBeacon.orient )
		mySoldier:setAI( true, -1.0 )
		unbindSoldier( mySoldier )
	end
end

function onSoldierDied( soldier )
	if myCogitatorObject.state == "Active_for_AI" then
		myCogitatorObject:changeState("Active_for_AI")
	end
end

function onSoldierEvent( soldier, event )
	if event == "OnCriticalHit" then
		-- ujrainditjuk a valtast. Elvileg csak akkor jon be ide, hogy ha mar elkezdte
		if myCogitatorObject.state == "Active_for_AI" then
			myCogitatorObject:changeState("Activated_By_AI")
		end
	end
end