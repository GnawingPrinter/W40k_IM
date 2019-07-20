require "SentryTrap_Base"

dummyExplosiveList = {}
dummyExplosiveSlowList = {}

objectExplosiveList = {}
objectExplosiveSlowList = {}

explosionSkill = "Container_explosive"
explosionSlowSkill = "Container_slow"

activationArea = nil

function collectParams()
	addParam("ExplosiveTrap_ActivationArea", "Trigger")
	addParam("ExplosiveTrap_ExplosiveContainerSpawn", "DummyList")
	addParam("ExplosiveTrap_ExplosiveContainerSlowSpawn", "DummyList")
	addParam("ExplosiveTrap_Point1", "Dummy")
	addParam("ExplosiveTrap_Point2", "Dummy")
end

function preload()
	SentryTrapPreload()
	table.insert( skills, explosionSkill )
	table.insert( skills, explosionSlowSkill )
end

function onLoadMap()
	CreateSentryTrap( getDummyParam( "ExplosiveTrap_Point1" ), getDummyParam( "ExplosiveTrap_Point2" ) )
	activationArea = createTrigger( "ExplosiveTrap_ActivationArea", "Script_ExplosiveTrap_" .. tostring( getID() ) .. "_ActivationArea")
	
	dummyExplosiveList = getDummyList("ExplosiveTrap_ExplosiveContainerSpawn")
	dummyExplosiveSlowList = getDummyList("ExplosiveTrap_ExplosiveContainerSlowSpawn")
	
	for i = 1, #dummyExplosiveList do
		local dummy = dummyExplosiveList[ i ]
		local name = "Container_explosive_" .. tostring( i )
		local object = createScriptObject( name, "Container_explosive", dummy.position, dummy.orient, "Vulnerable" )
		if object.valid then
			objectExplosiveList[ i ] = object
		end
	end
	
	for i = 1, #dummyExplosiveSlowList do
		local dummy = dummyExplosiveSlowList[ i ]
		local name = "Container_explosive_slow_" .. tostring( i )
		local object = createScriptObject( name, "Container_slow", dummy.position, dummy.orient, "Vulnerable" )
		if object.valid then
			objectExplosiveSlowList[ i ] = object
		end
	end
end

function onTriggerEntered( trigger )
	if SentryTrapOnTriggered( trigger ) then
		trigger:enable( false )
		activationArea:enable( false )
		triggerAllExplosions()
	end
	if trigger == activationArea then
		trigger:enable( false )
		deactivateSkullTrigger()
		triggerAllExplosions()
	end
end

function onObjectDestroyed( object, soldier )
	SentryTrapOnObjectDestroyed( object )
	
	for i = 1, #objectExplosiveList do
		if object == objectExplosiveList[ i ]  then
			object:changeState( "Destroyed" )
			castSpell( explosionSkill, object.position )
			return
		end
	end
	
	for i = 1, #objectExplosiveSlowList do
		if object == objectExplosiveSlowList[ i ] then
			object:changeState( "Destroyed" )
			castSpell( explosionSlowSkill, object.position )
			return
		end
	end
end

function triggerAllExplosions()
	for i = 1, #objectExplosiveList do
		if objectExplosiveList[ i ].state == "Vulnerable" then
			objectExplosiveList[ i ]:changeState( "Destroyed" )
			castSpell( explosionSkill, objectExplosiveList[ i ].position )
		end
	end
	
	for i = 1, #objectExplosiveSlowList do
		if objectExplosiveSlowList[ i ].state == "Vulnerable" then
			objectExplosiveSlowList[ i ]:changeState( "Destroyed" )
			castSpell( explosionSlowSkill, objectExplosiveSlowList[ i ].position )
		end
	end
end
