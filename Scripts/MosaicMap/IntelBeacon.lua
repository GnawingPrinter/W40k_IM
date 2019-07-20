function collectParams()
	addParam("Intel", "Dummy", 1)
	addParam("Chest", "Dummy", 1)
	addParam("TeleportIn", "Dummy", 1)
	addParam("TeleportOut", "Dummy", 1)
	addParam("Ally", "DummyList", 1)
end

AllyGroupType = "Imperial_Guards"

function preload()
	table.insert( groups, AllyGroupType )
end

grouplist = {}

function onLoadMap()	
	local chestDummy = getDummyParam("Chest")
	local intelDummy = getDummyParam("Intel")
	local teleportInDummy = getDummyParam("TeleportIn")
	local teleportOutDummy = getDummyParam("TeleportOut")

	if not chestDummy.valid or not teleportInDummy.valid or not teleportOutDummy.valid then
		console.log("Invalid params")
		finish()
		return
	end
	
	createScriptObject( "Intel", "Object_Cogitator01", intelDummy.position, intelDummy.orient, "Active" )
	
	createChest( "Lootbox_BIG", chestDummy.position, chestDummy.orient )
	
	createTeleport( teleportInDummy.position, teleportInDummy.orient, teleportOutDummy.position + teleportOutDummy.orient * 20.0, teleportOutDummy.orient )
	createTeleport( teleportOutDummy.position, teleportOutDummy.orient, teleportInDummy.position + teleportInDummy.orient * 20.0, teleportInDummy.orient )

	dummyList = getDummyList("Ally")
	for i=1,#dummyList do
		local group = {}
		group.trigger = createCircleTrigger( "FollowTrigger" .. tostring(i), dummyList[i].position, 20 )
		group.group = spawnAllyGroup( AllyGroupType, dummyList[i].position, dummyList[i].orient )
		grouplist[#grouplist + 1] = group
	end
end


function onTriggerEntered( trigger )
	trigger:enable( false )
	
	for i = 1, #grouplist do
		if grouplist[i].trigger == trigger then
			console.log("Group found " .. tostring(i) )
			local allyGroup = grouplist[i].group
			for n = 1, allyGroup:soldierCount() do
				local soldier = allyGroup:getSoldier( n )
				if soldier:valid() then
					soldier:setHeroFollow( true )
				end
			end
		end
	end
	
end

function onObjectInteracted( object, interactor )
	object:changeState("Inactive")
	addVoidCrusadeUnlock("Secret_Mission_ALPHA")
	playVideoMessage("VC_IntelBeaconFound","VC_IntelBeaconFound")
end
