scriptActive = false
scriptFinished = false
allyGroup = nil
enemyGroup = nil
triggerEnemy = nil
triggerQuest = nil
bombardmentActive = true
assaultStarted = false
bombardmentTimer = 0.0
bombardmentTrigger = nil
targetPoint = nil
soldierCount = 0
sideQuestId = "assault" .. tostring(getID())

EnemyGroupType = "Average_ranged_commander"
AllyGroupType = "Imperial_Guards"
startRange = 10
startFightRange = 30
bombardmentRange = 30
bombardmentSkill = "Assault_bombardment"

function collectParams()
	addParam("Radio", "Dummy")
	addParam("AllyGroup", "Dummy")
	addParam("EnemyGroup", "Dummy")
end

function preload()
	table.insert( groups, EnemyGroupType )
	table.insert( groups, AllyGroupType )
	table.insert( skills, bombardmentSkill )
end

function activateGroup( group, active )
	for i = 1, group:soldierCount() do
		local soldier = group:getSoldier( i )
		if soldier:valid() then
			soldier:setInactive( not active )
		end
	end
end

function setFinished( success )
	setSideQuestProgress( sideQuestId, 0.0 )
	setSideQuestCompleted( sideQuestId )
	playVideoMessage("Assault","Victory")
	scriptFinished = true
	removeAllMarkers()
	finish()
end

function onLoadMap()
	local allyDummy = getDummyParam( "AllyGroup" )
	local enemyDummy = getDummyParam( "EnemyGroup" )
	local radioDummy = getDummyParam( "Radio" )

	if not allyDummy.valid or not enemyDummy.valid or not radioDummy.valid then
		console.log("Invalid params")
		finish()
		return
	end

	targetPoint = enemyDummy.position

	triggerQuest = createCircleTrigger( tostring( getID() ) .. "_trigger_ally", allyDummy.position, startRange )
	triggerEnemy = createCircleTrigger( tostring( getID() ) .. "_trigger_enemy", enemyDummy.position, startFightRange )

	allyGroup = spawnAllyGroup( AllyGroupType, allyDummy.position, allyDummy.orient )
	enemyGroup = spawnEnemyGroup( EnemyGroupType, enemyDummy.position, enemyDummy.orient )

	bombardmentTrigger = createCircleTrigger( tostring( getID() ) .. "_bombardment", enemyDummy.position, bombardmentRange )

	createScriptObject( "Radio", "Vox_caster", radioDummy.position, radioDummy.orient, "Locked" ):setFaction( 1 )

	if allyGroup == nil or enemyGroup == nil then
		console.log("Could not spawn")
		finish()
		return
	end

	activateGroup( allyGroup, false )
end

function receiveQuest()
	local questDesc = {}
	questDesc.id = sideQuestId
	questDesc.title = "sidequest.assault.title"
	questDesc.objective = "sidequest.assault.objective"
	addSideQuest( questDesc )
	playVideoMessage("Assault","Start")

	activateGroup( allyGroup, true )
	triggerQuest:enable(false)
	scriptActive = true
end

function startAssault()
	soldierCount = enemyGroup:soldierCount()
	allyGroup:move( targetPoint )

	triggerEnemy:enable(false)
	assaultStarted = true
end

function forceStart()
	if scriptFinished then
		return
	end

	if not scriptActive then
		-- quest kapo fazis
		receiveQuest()
	end
	
	if not assaultStarted then
		-- elindul a roham
		startAssault()
	end
end

function onTriggerEntered( trigger )
	if trigger.name == bombardmentTrigger.name then
		return
	end

	trigger:enable( false )
	
	if scriptFinished then
		return
	end

	if trigger.name == triggerQuest.name then
		receiveQuest()
	else
		-- roham aktivalos trigger
		
		-- ha meg nincs questje, akkor megkapja jol
		if not scriptActive then
			receiveQuest()
		end
		
		-- elinditjuk a tamadast
		startAssault()
	end
end

function onSquadDied( squad )
	if squad == enemyGroup then
		enemyGroup = nil
	end
end

function onObjectDestroyed(object, attacker)
	bombardmentActive = false
	object:changeState("Destroyed")
	setFinished( true )
end

function onObjectDamageTaken(object,attacker)
	forceStart()
end

function onSoldierDamageTaken(soldier)
	if soldier:getSquadID() == enemyGroup.ID then
		forceStart()
	end
end

function execute()
	if assaultStarted and bombardmentActive then
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