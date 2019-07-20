scriptActive = true
skulls = {}

activeSkill = "SpawnTrap_Effect"
activatingSkill = "SpawnTrap_Activate_Effect"
activeMagicID = 0

skullTrigger = nil

function SentryTrapPreload()
	table.insert( skills, activeSkill )
	table.insert( skills, activatingSkill )
end

function CreateSentryTrap( dummy1, dummy2 )
	if not dummy1.valid or not dummy2.valid then
		printf("Nincs meg a dummy1 vagy dummy2!")
		return
	end
	
	skullTrigger = createLineTrigger( "Script_" .. tostring( getID() ) .. "_ActivationArea", dummy1.position, dummy2.position, 2 )

	local finalorient = dummy2.position - dummy1.position
	finalorient = finalorient:normal()
	skulls[1] = createScriptObject( "SpawnArea1", "SpawnSkull", dummy1.position, finalorient, "Active" )

	finalorient = dummy1.position - dummy2.position
	finalorient = finalorient:normal()
	skulls[2] = createScriptObject( "SpawnArea2", "SpawnSkull", dummy2.position, finalorient, "Active" )
	
	activeMagicID = castSpell( activeSkill, skulls[1], skulls[2] )
end

function SentryTrapOnTriggered( trigger )
	if not scriptActive then
		return false
	end
	
	local soldier = getSoldier( trigger.soldierId )
	if soldier:valid() and ( soldier:hasFlag("noclip") or soldier:hasFlag("ignored_by_traps") ) then
		-- atsuhant rajta
		return false
	end
	
	castSpell( activatingSkill, skulls[1], skulls[2] )
	stopMagic( activeMagicID )
	
	gameEvent( trigger.soldierId, "laserTrapActivated", 1 )
	return true
end

function SentryTrapOnObjectDestroyed( object )
	for i = 1, #skulls do
		if object.ID == skulls[i].ID then
			scriptActive = false
			stopMagic( activeMagicID )
			
			for n = 1, #skulls do
				skulls[n]:changeState("Destroyed")
			end
			return
		end
	end
end

function deactivateSkullTrigger()
	skullTrigger:enable( false )
end
