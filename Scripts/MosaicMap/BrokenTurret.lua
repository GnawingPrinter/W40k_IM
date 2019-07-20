idle = true
ritualSkillName = "Script_BrokenTurret_Cast"
ritualFinishSpell = "Script_BrokenTurret_Finish"
PI = 3.14159
debug = false
aggroRange = 300
finishTime = 30.0

spawnSoldierType = "Rebel_Weapon_Specialist"
spawnTurretType = "Big_Turret"
mySquad = {
	group = nil,
	state = "idle",
	turret = nil }

castingTime = 0.0
markerID = 0

function collectParams()
	addParam("Group", "Dummy", 1 )
end

function preload()
	table.insert( soldiers, spawnSoldierType )
	table.insert( soldiers, spawnTurretType )
	table.insert( skills, ritualSkillName )
	table.insert( skills, ritualFinishSpell )
end

function checkPrequisites( missionData )
	if isMonsterCategory( missionData.monsterSettings, "rebel" ) == false and isMonsterCategory( missionData.monsterSettings, "cultist" ) == false then
		return false
	end
	
	return true
end

function onLoadMap()
	local dummy = getDummyParam("Group")
	if dummy.valid then
		local group = {}
		
		for iHelper = 1, 3 do
			local dest = vector.new( 40, 0 )
			dest:rotate( ( iHelper - 1 ) * ( ( PI * 2 ) / 3 ) )
			local finalDest = dest + dummy.position
			local ori = dummy.position - finalDest;
			ori = ori:normal()
			
			local helper = spawnEnemy( spawnSoldierType, "repairguy_" .. tostring(i), finalDest, dummy.orient )
			if( helper:valid() ) then
				group[iHelper] = helper
			else
				console.log("Soldier does not exist")
				finish()
				return
			end
		end
		
		mySquad.group = group
		mySquad.position = dummy.position
		
		local turret = spawnEnemy( spawnTurretType, "turret", dummy.position, dummy.orient )
		if not turret:valid() then
			console.log( "Turret does not exist" )
			finish()
			return
		end
		
		turret:setAI( false, -1 )
		turret:setInactive( true )
		
		mySquad.turret = turret
	else
		console.log("No dummy found!")
		finish()
	end
end

function releaseGroup()
	-- leallitjuk a mozgasukat, es castolasukat
	mySquad.state="inactive"
	local group = mySquad.group
	for iSol = 1, #group do
		local sol = group[iSol]
		if( sol:valid() ) then
			sol:stop()
			sol:stopCasting(ritualSkillName)
			sol:setAI( true, -1.0 )
		end
	end

	removeMarker( markerID )
end

function execute()
	if mySquad == nil then
		return true
	end
	
	if( idle ) then
		local group = mySquad.group
		local aliveCount = 0
		for iSol = 1, #group do
			local sol = group[iSol]

			if( sol:valid() ) then
				aliveCount = aliveCount + 1
			end
		end
		
		if( aliveCount == 0 ) then
			releaseGroup()
			mySquad.turret:kill()				
			
			printf("soldier died releasing group")
			return true
		end
			
		local target = findNearbyHero( mySquad.position, aggroRange )
		if( target:valid() ) then
			idle = false
			
			if( #group >= 3 ) then
				-- meg elo group, menjen a dummyjahoz, es kezdjenek castolni!
				local dummyPos = mySquad.position
				mySquad.state = "moving"
				
				if debug then
					addDebugCircle( "dummypos: " .. tostring( i ), 20, dummyPos )
				end
				
				for iSol = 1, #group do
					local sol = group[iSol]
					if( sol:valid() ) then
						sol:setAI( false, -1.0 )
						
						local dest = vector.new( 40, 0 )
						dest:rotate( ( iSol - 1 ) * ( ( PI * 2 ) / 3 ) )
						local finalDest = dest + dummyPos
						local ori = dummyPos - finalDest;
						ori = ori:normal()

						if debug then
							addDebugCircle( "dummy" .. tostring( i ) .. "pos" .. tostring( iSol ), 2, finalDest )
							printf( "pos: " .. tostring( finalDest.x ) .. " " .. tostring( finalDest.y ) )
							printf( "dummy: " .. tostring( dummyPos.x ) .. " " .. tostring( dummyPos.y ) )
						end
						
						sol:move( finalDest, ori )
					end
				end
			end
		else
			return false
		end
	else		
		local allFinished = true
		local state = mySquad.state
		if( state ~= "inactive" ) then
			allFinished = false
			local group = mySquad.group

			local allReached = true
			local aliveCount = 0
			for iSol = 1, #group do
				local sol = group[iSol]

				if( sol:valid() ) then
					aliveCount = aliveCount + 1
					if( sol:isMoving() ) then
						allReached = false
					end
				end
			end
			
			if( aliveCount == 0 ) then
				releaseGroup()
				allReached = false
				mySquad.turret:kill()
				
				printf("soldier died releasing group")
				return true
			end
			
			if( allReached ) then
				if( state == "moving" ) then
					for iSol = 1, #group do
						local sol = group[iSol]
						if( sol:valid() ) then
							sol:cast( ritualSkillName, sol )
						end
					end
					mySquad.state="casting"
					castingTime = 0.0
					
					markerID = addMarker( mySquad.position, "progress")
				
					printf("casting skill")
				elseif state == "casting" then
					setMarkerProgressRatio( markerID, castingTime / finishTime )
					
					castingTime = castingTime + aliveCount
					if castingTime >= finishTime then
						castSpell( ritualFinishSpell, mySquad.position )
						releaseGroup()
						allFinished = true
						
						mySquad.turret:setAI( true, 2.0 )
						mySquad.turret:setInactive( false )
					end
				end
			end
		end
		
		if( allFinished ) then
			return true
		end
	end
	
	return false
end