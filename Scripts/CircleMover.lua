tickCount = 0
circleRad = 70.0
segmentCount = 8
PI = 3.14159

center = nil

function startup()
	me = getOwner()
	center = me.position
	tickCount = 0
	setUpdateInterval(0.5)
end

function execute()
	local me = getOwner()
	if( not me:valid() ) then
		-- meghalt, eltunt, mindegy
		printf("died, exiting")
		return true
	end

	tickCount = tickCount + 1
	while tickCount > segmentCount do
		tickCount = tickCount - segmentCount
	end

	local dest = vector.new( circleRad, 0 )
	dest:rotate( ( tickCount / segmentCount ) * ( PI * 2 ) )
	local target = center + dest
	me:move(target, vector.new(0,0))
	
	return false
end