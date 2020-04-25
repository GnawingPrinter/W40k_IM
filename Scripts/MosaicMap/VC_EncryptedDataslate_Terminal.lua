function collectParams()
	addParam("SpawnPoint", "Dummy", 1)
	addParam("Unlock", "String", 1)
end

function preload()
	table.insert( soldiers, spawnSoldierType )
end

function onLoadMap()
	local dummy = getDummyParam( "SpawnPoint" )
	createScriptObject( "VC_Terminal", "Object_Desk", dummy.position, dummy.orient, "Active" )
end

function onObjectInteracted( object, interactor )
	object:changeState("Inactive")
	
	if hasVoidCrusadeUnlock("EncryptedDataslate") then
		playVideoMessage("EncryptedDataslate","HaveSlate")
		addVoidCrusadeUnlock( getStringParam("Unlock") )
	else
		playVideoMessage("EncryptedDataslate","NoSlate")
	end
	
	finish()
end