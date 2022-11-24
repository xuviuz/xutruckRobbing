Add this to your qb-target\init.lua under config.BoxZones

["TruckRoute"] = {
		name = "TruckRoute",
		coords = vector3(-69.14, 6252.99, 31.09),
		length = 0.5,
		width = 0.5,
		heading = 33.00,
		debugPoly = false,
		minZ = 31.04,
		maxZ = 31.20,
		options = {
			{
			type = 'client',
            event = 'xuTruckRobbery:client:getRouteAndOpenMap',
            icon = 'fas fa-user',
            label = 'Look at route list',
			},
		},
		distance = 3.5
	},