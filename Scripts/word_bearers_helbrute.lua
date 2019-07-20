spawnCount = 1

function startup()
	local me = getOwner()
	if( me:valid() ) then
		-- spawnolunk haverokat
		local dummies = findNearbyDummy( me.position, 500, "system", true)
		local dummyCount = #dummies
		for i = 1, math.min( dummyCount, spawnCount ) do
			local dummy = dummies[ i ]
			local helper = spawnMinion( me, "Word_Bearers_Helbrute_Gate", "gate_" .. tostring(i), dummy.position, dummy.orient )
		end
		
		if( dummyCount < spawnCount ) then
			printf("Not enough system dummy for the script!")
			for i = dummyCount + 1, spawnCount do
				local index = i - dummyCount - 1
				local helper = spawnMinion( me, "Word_Bearers_Helbrute_Gate", "gate_" .. tostring(i), me.position + vector.new( 50 * ( index / 2 ), 50 * ( index % 2 ) ) , me.orient )
			end
		end
	else
		console.log("Soldier does not exist!?")
	end
end
