escapeTime = 30
spawnSoldierType = "WanderingServoskull"
remainingTime = -1
servoskull = nil

function collectParams()
	addParam("SpawnPoint", "DummyList", 3)
end

function preload()
	table.insert( soldiers, spawnSoldierType )
end

function onLoadMap()
	if isWanderingServoskullOn() then
		local dummyList = getDummyListRandomized("SpawnPoint")
		local dummy = dummyList[1]
		local soldier = spawnEnemy( spawnSoldierType, "", dummy.position, dummy.orient )
		bindSoldier( soldier )
		servoskull = soldier
		
		setUpdateInterval(1.0)
	else
		finish()
	end
end

function onSoldierAggroed( soldier )
	if remainingTime == -1 then
		remainingTime = escapeTime
		playVideoMessage("WanderingServoskull", "Aggro")
	end
end

function onSoldierDied( soldier )
	playVideoMessage("WanderingServoskull", "Killed")
	onWanderingServoskull()
	finish()
end

function execute()
	if remainingTime >= 0 then
		remainingTime = remainingTime - 1
		if remainingTime == 0 then
			servoskull:stop()
			servoskull:teleportOut()
			playVideoMessage("WanderingServoskull", "Escaped")
			finish()
		end
	end
end