questActivated = false
shrines = {}
skillName = "Script_Multishrine_Completed"
sideQuestId = "multishrine" .. tostring( getID() )
completedTaskCount = 0

checkFinished = 0
lastInteractedObj = nil

function collectParams()
	addParam("Shrine", "DummyList",3)
end

function preload()
	table.insert( skills, skillName )
end

function onLoadMap()
	local dummies = getDummyList( "Shrine" )
	if #dummies == 0 then
		console.log("Invalid params")
		finish()
		return
	end

	for i = 1, #dummies do
		shrines[ i ] = createScriptObject( "Shrine_" .. tostring( i ), "MultiShrine", dummies[ i ].position, dummies[ i ].orient, "Active" )
	end
end

function onObjectInteracted(object, interactor)
	if not questActivated then
		local questDesc = {}
		questDesc.id = sideQuestId
		questDesc.title = "sidequest.multishrine.title"
		questDesc.states = {0,0,0}
		questDesc.objective = "sidequest.multishrine.objective"
		
		questDesc.states[ completedTaskCount + 1 ]=1	-- hulye luas 1-tol indexeles..
		completedTaskCount = completedTaskCount + 1
		
		for i = 1, #shrines do
			if object ~= shrines[ i ] then
				addMarker( shrines[ i ], "target" )
			end
		end

		addSideQuest( questDesc )
		questActivated = true
	else
		setSideQuestState( sideQuestId, completedTaskCount, 1 )
		completedTaskCount = completedTaskCount + 1
		removeMarker( object )
	end

	object:changeState("Activated")

	checkFinished = 3
	lastInteractedObj = object
end

function execute()
	if checkFinished > 0 then
		checkFinished = checkFinished - 1
		
		if checkFinished == 0 then
			if completedTaskCount == 3 then
				castSpell( skillName, lastInteractedObj.position )
				removeAllMarkers()
				setSideQuestCompleted( sideQuestId )
				playVideoMessage("Multishrine","Start")
				
				for i = 1, #shrines do
					shrines[i]:changeState("Inactive")
				end
				
				return true
			end
		end
	end
	
	return false
end
