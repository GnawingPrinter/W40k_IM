scriptActive = false
scriptFinished = false
bombardmentActive = true
bombardmentTimer = 0.0
bombardmentTrigger = nil

bombardmentRange = 60
bombardmentSkill = "Assault_bombardment"

function collectParams()
	addParam("Radio", "Dummy")
end

function preload()
	table.insert( skills, bombardmentSkill )
end

function setFinished( success )
	playVideoMessage("Assault","Victory")
	scriptFinished = true
	removeAllMarkers()
	finish()
end

function onLoadMap()
	local radioDummy = getDummyParam( "Radio" )

	if not radioDummy.valid then
		console.log("Invalid params")
		finish()
		return
	end

	bombardmentTrigger = createCircleTrigger( tostring( getID() ) .. "_bombardment", radioDummy.position, bombardmentRange )
	createScriptObject( "Radio", "Vox_caster", radioDummy.position, radioDummy.orient, "Locked" ):setFaction( 1 )
end

function onObjectDestroyed(object, attacker)
	bombardmentActive = false
	object:changeState("Destroyed")
end

function execute()
	if bombardmentActive then
		bombardmentTimer = bombardmentTimer - 1.0
		if bombardmentTimer <= 0.0 then
			bombardmentTimer = 5.0

			bombardmentTrigger:update()
			if bombardmentTrigger.soldierId ~= 0 then
				local soldier = soldier.new( bombardmentTrigger.soldierId )
				if soldier:valid() then
					castSpell( bombardmentSkill, soldier )
				end
			end
		end
	end
	
	return false
end