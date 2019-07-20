stage = 1

hiveSoldierType = "Nurgle_Daemonhost_Hive"
sorcererSoldierType = "Nurgle_Daemonhost_Sorcerer"
bossSoldierType = "Nurgle_Daemonhost"

stage1Skill = "Nurgle_deamonhost_stage1"

function collectParams()
	addParam("Position", "Dummy")
	addParam("Hive", "DummyList")
	addParam("Nurgle_Daemonhost_Sorcerer", "DummyList")
end

function preload()
	table.insert( soldiers, hiveSoldierType )
	table.insert( soldiers, bossSoldierType )
	table.insert( soldiers, sorcererSoldierType )
	table.insert( skills, stage1Skill )
end

function onLoadMap()
	local Dummy = getDummyParam( "Position" )

	if not Dummy.valid then
		console.log("Invalid params")
		finish()
		return
	end
	
	local soldier = spawnEnemy( bossSoldierType,"",Dummy.position, Dummy.orient );
	if soldier:valid() then
		soldier:ensureSquad()
		bindSoldier( soldier )
		
		soldier:setFlag( hold, true, -1.0 )
		
		local DummyList = getDummyList( "Hive" )
		for i=1,#DummyList do
			local dummy = DummyList[ i ]
			spawnMinion( soldier, hiveSoldierType, "spawner_" .. tostring(i), dummy.position, dummy.orient )
		end
	end
end

function onSoldierDamageTaken(soldier)
	if stage == 1 and soldier:getHPPercent() < 0.3 then
		stage = 2
		
		local dummies = getDummyList( "Nurgle_Daemonhost_Sorcerer" )
		for i = 1, #dummies do
			local dummy = dummies[ i ]
			spawnMinion( soldier, sorcererSoldierType, "", dummy.position, dummy.orient )
		end
		
		soldier:setEnableSpell( "Nurgle_daemonhost_Warp_missiles", false )
		soldier:setEnableSpell( "Nurgle_daemonhost_Seeds_of_nurgle", false )

		soldier:setFlag( hold, false, -1.0 )
	end
end
