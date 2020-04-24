
function collectParams()
	addParam("Intel", "Dummy", 1 )
end

function onLoadMap()
	local dummy = getDummyParam("Intel")
	if dummy.valid then
		createDataslate("intel", dummy.position, "Pickupable.intel" )
	else
		console.log("No dummy found!")
		finish()
	end
end

function onLootPickedUp(name,soldier)
	addLoot( "VC_IntelGrab_Blueprint", soldier.position )
	finish()
end