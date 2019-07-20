
function collectParams()
	addParam("Intel", "Dummy", 1 )
end

function onLoadMap()
	local dummy = getDummyParam("Intel")
	if dummy.valid then
		createDataslate("intel", dummy.position)
	else
		console.log("No dummy found!")
		finish()
	end
end

function onLootPickedUp(name,soldier)
	addLoot( "Random_Rare2_Blueprint", soldier.position )
	finish()
end