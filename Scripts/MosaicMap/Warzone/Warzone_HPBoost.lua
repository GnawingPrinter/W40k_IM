level = 0
magicId = 0
skillName = "Warzone_handicap_HPBoost"

function preload()
	table.insert( skills, skillName )
end


function onLoadMap()
	setUpdateInterval(60)
	
	magicId = castSpellToWorld(skillName,level)
end

function execute()
	level = level + 1
	stopMagic(magicId)
	magicId = castSpellToWorld(skillName,level)
end