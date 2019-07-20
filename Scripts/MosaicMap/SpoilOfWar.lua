SummonEffect = "script_spoils_of_war_summon"
SummonPrepareEffect = "script_spoils_of_war_summon_pentagram"
ChestEffect = "script_spoils_of_war_summon_place"
SoldierType = "Unholy_Guardian"

delayFun = nil

function collectParams()
	addParam("Chest", "Dummy")
end

function setParameterDefaultValue( name )
	if name == "chance" then
		setDefaultInt( 5 )
		return
	end
end

function preload()
	table.insert( skills, SummonEffect )
	table.insert( skills, SummonPrepareEffect )
	table.insert( skills, ChestEffect )
	table.insert( soldiers, SoldierType )
end

function onLoadMap()
	local chestDummy = getDummyParam( "Chest" )

	if not chestDummy.valid then
		console.log("Invalid params")
		finish()
		return
	end

	chestObj = createScriptObject( "SpoilsOfWar", "SpoilsOfWar", chestDummy.position, chestDummy.orient, "Idle" )
	castSpell( ChestEffect, chestObj, chestDummy.position, chestDummy.orient )
	trigger = createCircleTrigger( "SpoilsTrigger", chestDummy.position, 10.0 )
	trigger:setMaxHeight( 100.0 )
end

function onTriggerEntered( trigger )
	trigger:enable( false )
	
	if chestObj.state ~= "Idle" then
		return
	end
	
	chestObj:changeState("Alarm")
	
	targetPos = chestObj.position + chestObj.orient * 50.0
	
	soldier = spawnEnemy( SoldierType, "SpoilsProtector", targetPos, chestObj.orient )
	bindSoldier( soldier )
	
	addMarker( soldier, "target" )
	addMarker( chestObj, "target" )
	
	castSpell( SummonPrepareEffect, soldier, soldier.position, soldier.orient )
	
	delayFun = {}
	delayFun.soldier = soldier
	delayFun.time = 2
	
	soldier:setInvisible( true, -1 )
	soldier:setAI( false, -1 )
	
	playBanterGroup( "BNT_Spoil_Spawn", trigger.soldierId )
end

function onSoldierDied( soldier )
	chestObj:update()
	if chestObj.state == "Idle" and chestObj.inTransition then
		chestObj:changeState( "Active" )
		
		playBanterGroup( "BNT_Spoil_Success" )
	end
end

function onObjectInteracted( object, interactor )
	object:changeState("Open")
end

function onObjectStateChanged( object )
	if object.state == "Open" then
		addLoot( "Chest_3", object.position + object.orient * 50.0 )
		gameEvent( 0, "spoil_of_war", 1 )
		removeMarker( object )
		finish()
	elseif object.state == "Alarm" then
		object:changeState("Destroyed")
		removeMarker( object )
		playBanterGroup( "BNT_Spoil_Fail" )
		finish()
	elseif object.state == "Destroyed" then
		finish()
	end
end

function soldierAppear( soldier )
	soldier:setInvisible( false, -1 )
	soldier:setAI( true, -1 )
	soldier:setFlag( "hold", true, 2.0 )
	soldier:setFade( 0.0, 1.0, 1.0 )
		
	castSpell( SummonEffect, soldier, soldier )
end

function execute()
	if delayFun ~= nil then
		delayFun.time = delayFun.time - 1
		if delayFun.time == 0 then
			soldierAppear( delayFun.soldier )
			delayFun = nil
		end
	end
end