function collectParams()
	addParam("terminal", "Dummy")
	addParam("attacker", "Dummy")
	addParam("door", "Dummy")
	addParam("trigger", "Trigger" )
end

spawnEffectSkill = "Summon_chaos__effect"
spawnGroup = "Average_melee_normal"

function preload()
	table.insert( groups, spawnGroup );
	table.insert( skills, spawnEffectSkill )
end

soldiersToSpawn = {}
curTime = 0.0
summonDelay = 0.0

summonPos = nil
door = nil
terminal = nil

function onLoadMap()
	local dummy = getDummyParam("terminal")
	terminal = createScriptObject( "Terminal", "Object_Cogitator01", dummy.position, dummy.orient, "Inactive" )
	door = createDoor( "door", "door", "Security_Door", "Open" )

	createTrigger( "trigger", "activate_trigger" )
	summonPos = getDummyParam("attacker")
end

function onTriggerEntered( trigger )
	trigger:enable( false )
	door:changeState("Closed_NoInteract")
	terminal:changeState("Active_interactTime")
end

function onObjectInteracted( obj, interactor )
	terminal:changeState("Inactive")
	door:changeState("Open")

	local squad = spawnEnemyGroup( spawnGroup, summonPos.position, summonPos.orient )
	squad:move(interactor.position)

	finish()
end
