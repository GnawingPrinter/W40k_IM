skillName = "pvp_nurgle_gas"

function collectParams()
	addParam("Gas", "DummyList")
end

function preload()
	table.insert( skills, skillName )
end

function onLoadMap()
	local dummies = getDummyList("Gas")
	for i = 1, #dummies do
		castSpell( skillName, dummies[ i ].position )
	end
end