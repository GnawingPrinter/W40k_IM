firstRun = true
clue2ObjectId = 0
clue3ObjectId = 0

function collectParams()
	addParam("Clue2Cogitator", "Dummy")
	addParam("Clue3Cogitator", "Dummy")
end

function onLoadMap()
	local dummy = getDummyParam("Clue2Cogitator")
	if dummy.valid then
		local object = createScriptObject( "Object_Cogitator01", "Object_Cogitator01", dummy.position, dummy.orient, "Active" )
		if object.valid then
			clue2ObjectId = object.ID
		end
	end
	local dummy = getDummyParam("Clue3Cogitator")
	if dummy.valid then
		local object = createScriptObject( "Object_Cogitator01", "Object_Cogitator01", dummy.position, dummy.orient, "Active" )
		if object.valid then
			clue3ObjectId = object.ID
		end
	end
end

function onObjectInteracted( object, hero )
	if( object.ID == clue2ObjectId ) then
		object:changeState( "Inactive" )
		
		getQuest( "TheVanWynterLegacy1" ):activateClue( "clue2" )
	end
	if( object.ID == clue3ObjectId ) then
		object:changeState( "Inactive" )
		
		getQuest( "TheVanWynterLegacy1" ):activateClue( "clue3" )
	end
end

function onSoldierDied( soldier )
	if soldier:getName() == "xyz" then -- TODO valahonnan kitalalni ezt..
		getQuest( "TheVanWynterLegacy1" ):activateClue( "clue4" )
	end
end

function execute()
	if firstRun then
		firstRun = false
		
		getQuest( "TheVanWynterLegacy1" ):activateClue( "clue1" )
	end

	return false
end