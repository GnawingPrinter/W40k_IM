skillType = nil
-- Shrine by skill type
shrineTypes = { Shrine_Damage= "Shrine_Damage", Shrine_Defense="Shrine_Defense", Shrine_Speed="Shrine_Speed"}

function collectParams()
	addParam("Shrine", "Dummy")
	
	local possibleSkills = { "Shrine_Damage", "Shrine_Defense", "Shrine_Speed" }
	addCustomParam("skill", possibleSkills )
end

function preload()
	table.insert( skills, getPreloadString( "skill" ) )
end

function onLoadMap()
	local dummy = getDummyParam( "Shrine" )
	skillType = getStringParam("skill")
	if not dummy.valid or skillType == "" then
		console.log("Invalid params")
		finish()
		return
	end
	
	
	local obj = createScriptObject( "Shrine", shrineTypes[skillType], dummy.position, dummy.orient, "Active" )
	addCustomMarker( obj, "ui/map/poi/" .. shrineTypes[skillType] .. ".tga", "" )
end

function onObjectInteracted(object, interactor)
	object:changeState("Activated")
	castSpell( skillType, object.position )
	gameEvent( interactor.ID, "shrine_activated", 1 )
	removeMarker( object )
end
