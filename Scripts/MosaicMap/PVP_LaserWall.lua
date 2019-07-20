local triggerWidth = 80;
local triggerHeight = 1;
local team = -1;

function collectParams()
	addParam("Laser", "Dummy", 1 )
	addParam("Team", "Int", 1 )
end

function preload()
	table.insert( skills, "pvp_laser_0" )
	table.insert( skills, "pvp_laser_1" )
end

function onLoadMap()
	team = getIntParam("Team")
	local dummy = getDummyParam("Laser")
	castSpell( "pvp_laser_" .. tostring( team ), dummy.position, dummy.orient )

	local orient = dummy.orient
	orient:rotate( 1.57 )
	createLineTrigger( "laser_area", dummy.position - orient * ( triggerWidth * 0.5 ), dummy.position + orient * ( triggerWidth * 0.5 ), triggerHeight )
end

function onTriggerEntered( trigger )
	local soldier = getSoldier( trigger.soldierId )
	if team ~= soldier:getPVPTeam() then
		soldier:kill()
	end
end