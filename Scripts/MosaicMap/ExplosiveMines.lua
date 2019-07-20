mineSkills = { "Mine_explosive", "Mine_stun", "Mine_poison" }

function collectParams()
	addParam("Mine", "DummyList")
	local types = { "Random" };
	for i = 1, #mineSkills do
		table.insert( types, mineSkills[ i ] )
	end
	addCustomParam("SpawnType", types )
end

function preload()
	for i = 1, #mineSkills do
		table.insert( skills, mineSkills[ i ] )
	end
end


function onLoadMap()
	local mineSkill = getStringParam("SpawnType")

	local dummies = getDummyList("Mine")
	for i = 1, #dummies do
		local spell = mineSkill
		if spell == "Random" or spell == "" then
			spell = mineSkills[math.random(1,#mineSkills)]
		end
		castSpell( spell, dummies[ i ].position )
	end
end