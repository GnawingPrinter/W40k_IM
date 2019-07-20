idle = true
ritualSkillName = "Script_DemonSummon_Cast"
ritualFinishSpell = "Script_DemonSummon_Finish"
ritualLocationSpell = "Script_DemonSummon_Pentagram"
castFinishTime = 10.0
PI = 3.14159
debug = false

spawnSoldierType = "Rogue_Psyker_summoner"
mySquad = {
	group = nil,
	state = "idle" }
castingTime = 0.0

locationMagicID = 0
markerID = 0

function collectParams()
	addParam("Group", "Dummy", 1 )
end

function preload()
	table.insert(soldiers, spawnSoldierType )
	table.insert(skills, ritualSkillName )
	table.insert(skills, ritualFinishSpell )
	table.insert(skills, ritualLocationSpell )
end

function checkPrequisites( missionData )
--	if isMonsterCategory( missionData.monsterSettings, "demonic" ) == false then
--		return false
--	end
	
	return true
end

function onLoadMap()
	local dummy = getDummyParam("Group")
	if dummy.valid then
		local group = {}
		for iHelper = 1, 3 do
			local helper = spawnEnemy( spawnSoldierType, "summoner_" .. tostring(i), dummy.position, dummy.orient )
			if( helper:valid() ) then
				group[iHelper] = helper
				helper:setFlag("cantattack", true,-1.0);
			else
				console.log("Soldier does not exist")
				finish()
				return
			end
		end
		
		mySquad.group = group
		mySquad.position = dummy.position
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
			sol:setFlag("cantattack", false,-1.0);
		end
	end
	
	if locationMagicID ~= 0 then
		stopMagic( locationMagicID )
		locationMagicID = 0
	end
	
	removeMarker( markerID )
end

function execute()
	if mySquad == nil then
		return true
	end
	
	if( idle ) then
		local group = mySquad.group
		for iSol = 1, #group do
			local sol = group[iSol]

			if( not sol:valid() ) then
				-- meghalt valamelyik, mar nem valid
				releaseGroup()
				printf("soldier died releasing group")
				return true
			end
		end
		
		local target = findNearbyHero( mySquad.position, 200 )
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
					sol:setAI( false, -1.0 )
					
					local dest = vector.new( 35, 0 )
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
		else
			return false
		end
	else		
		local allFinished = true
		local state = mySquad.state
		if( state ~= "inactive" ) then
			allFinished = false
			local group = mySquad.group

			if( #group < 3 ) then
				-- nincsenek elegen, ez mar nem valid
				releaseGroup()
				printf("missing soldier")
			else
				local allReached = true
				for iSol = 1, #group do
					local sol = group[iSol]

					if( not sol:valid() ) then
						-- meghalt valamelyik, mar nem valid
						releaseGroup()
						allReached = false
						
						printf("soldier died releasing group")
						break
					end
					
					if( sol:isMoving() ) then
						allReached = false
					end
				end
				
				if( allReached ) then
					if( state == "moving" ) then
						for iSol = 1, #group do
							local sol = group[iSol]
							sol:cast( ritualSkillName, sol )
						end
						
						locationMagicID = castSpell( ritualLocationSpell, mySquad.position )
						mySquad.state = "casting"
						castingTime = 0.0
						
						markerID = addMarker( mySquad.position, "progress" )
						setMarkerProgress( markerID, castFinishTime )
						
						printf("casting skill")
					elseif state == "casting" then
						castingTime = castingTime + 1.0
						if castingTime >= castFinishTime then
							castSpell( ritualFinishSpell, mySquad.position )
							releaseGroup()
							allFinished = true
							
							-- Ki kell nyirni a summonereket
							local group = mySquad.group
							for iSol = 1, #group do
								local sol = group[iSol]
								if( sol:valid() ) then
									sol:instagib()
								end
							end
						end
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