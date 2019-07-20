function collectParams()
	addParam("Intel", "Dummy", 1)
	addParam("Banter", "Trigger", 1)
end

continousEffectSkill = "voidcrusade_intel_effect"

function preload()
	table.insert( skills, continousEffectSkill )
end

function onLoadMap()	
	local intelDummy = getDummyParam("Intel")
	if not intelDummy.valid then
		console.log("Invalid params")
		finish()
		return
	end
	
	cogitator = createScriptObject( "Intel", "Object_Cogitator01", intelDummy.position, intelDummy.orient, "Active" )
	activeMagicID = castSpell( continousEffectSkill, cogitator, cogitator )
	createTrigger( "Banter", "void_crusade_intel" )
end

function onObjectInteracted( object, interactor )
	object:changeState("Inactive")
	addIntel(1)
	stopMagic( activeMagicID )
	
	playVideoMessage("VoidCrusadeIntelFound","VoidCrusadeIntelFound")
	finish()
end

function onTriggerEntered( trigger )
	trigger:enable( false )
	playVideoMessage("VoidCrusadeIntelNearby","VoidCrusadeIntelNearby")
end