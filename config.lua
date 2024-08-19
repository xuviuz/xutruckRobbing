Config = {}

Config.MaxItemsReceived = 25
Config.MinItemReceivedQty = 25
Config.MaxItemReceivedQty = 55
Config.ChanceItem = "WEAPON_SNSPISTOL"

Config.MinCashToReceive = 50000
Config.MaxCashToReceive = 120000

Config.ItemTable = {
		[1] = "metalscrap",
		[2] = "plastic",
		[3] = "copper",
		[4] = "iron",
		[5] = "aluminum",
		[6] = "steel",
		[7] = "glass",
        [8] = "rubber",
        [9] = "wool",
	}

Config.ResetTimer = 15000
Config.GetLootTimer = 30000
Config.CorrectPinWaitTimer = 10000
Config.WrongPinWaitTimer = 25000

Config.TruckSpawnTable = {
    [1] = {
        coords = vector4(-303.02,-2720.2,6.00,-303.02),
        color = "#3fa535"
    },
    [2] = {
        coords = vector4(-1090.26, -2216.7, 13.27, 229.1),
        color = "#e97c11"
    },
    [3] = {
        coords =  vector4(-13.03, 6264.63, 31.24, 31.87),
        color = "#feed01"
    },
    [4] = {
        coords = vector4(-560.62, 5374.61, 70.21, 343.88),
        color = "#a535a1"
    },
    [5] = {
        coords =  vector4(2680.43, 2835.88, 40.15, 3.4),
        color = "#cf1719"
    },
    [6] = {
        coords = vector4(1539.12, -2084.62, 77.08, 1.76),
        color = "#fe7eb1"
    },
    [7] = {
        coords = vector4(-1897.23, 2011.24, 141.42, 252.1),
        color = "#009fe3"
    }
}

Config.TruckEndLocationTable = {
    [1] = {
        coords = vector3(-1027.32, -513.13, 36.21),
        color = "#cf1719",
        border = "#3fa535"
    },
    [2] = {
        coords = vector3(412.56, 6490.78, 28.31),
        color = "#009fe3",
        border = "#cf1719"
    },
    [3] = {
        coords = vector3(3626.13, 3767.73, 28.52),
        color = "#a535a1",
        border = "#e97c11"
    },
    [4] = {
        coords = vector3(1127.38, -2392.25, 31.58),
        color = "#11e0e8",
        border = "#fe7eb1"
    },
    [5] = {
        coords = vector3(-2353.33, 267.23, 165.42),
        color = "#feed01",
        border ="#3fa535"
    },
    [6] = {
        coords = vector3(1098.46, 2116.18, 53.55),
        color = "#3fa535",
        border = "#feed01"
    },
    [7] = {
        coords = vector3(194.75, 2747.91, 43.43),
        color = "#e97c11",
        border = "#a535a1"
    }
}

Config.unloaderPeds = {
    {
        model = 's_m_m_trucker_01',
        coords = vector4(-567.21, -1686.66, 18.25, 226.95),
        stolenTruckUnloader = true,
    },
    {
        model = 's_m_m_trucker_01',
        coords = vector4(596.73, -1880.17, 24.04, 77.55),
        stolenTruckUnloader = true,
    },
    {
        model = 's_m_m_trucker_01',
        coords = vector4(428.09, 6477.15, 27.79, 149.71),
        stolenTruckUnloader = true,
    },
    {
        model = 's_m_m_trucker_01',
        coords = vector4(1975.78, 5164.55, 46.64, 2.56),
        stolenTruckUnloader = true,
    },
    {
        model = 's_m_m_trucker_01',
        coords = vector4(188.87, 2758.3, 44.66, 279.97),
        stolenTruckUnloader = true,
    }
        
}

Config.TruckType = {
    [1] = "Money",
    [2] = "Mats",
}

Config.UnloadCoords = {
    {
        coords = vector3(599.92, -1867.9, 24.73),
    },
    {
        coords = vector3(-558.27, -1691.08, 19.28)
    },
    {
        coords = vector3(436.83, 6462.32, 28.75)
    },
    {
        coords = vector3(1979.97, 5173.47, 47.64)
    },
    {
        coords = vector3(193.18, 2762.29, 45.43)
    }
} 

Config.timerForLocationUpdate = 1680
Config.amountOfPins = 4

Config.ScheduleLocation = vector3(-67.57, 6254.15, 31.09)

Config.pinCodeCardLocation = {
    [1] = {
        coords = vector3(1083.55, -2015.15, 41.2),
        size = vec3(0.7,0.9,3),
        heading = 325.37,
    },
    [2] = {
        coords = vector3(604.17, -3089.25, 6.07),
        size = vec3(1.4,1,4),
        heading = 0,
    },
    [3] = {
        coords = vector3(-435.06, 6154.01, 31.48),
        size = vec3(1.4,1,4),
        heading = 136,
    },
    [4] = {
        coords = vector3(-566.69, 5252.89, 70.49),
        size = vec3(1.6,1,4),
        heading = 345,
    },
    [5] = {
        coords = vector3(1337.84, 4358.93, 44.37),
        size = vec3(1.4,1,4),
        heading = 45,
    },
    [6] = {
        coords = vector3(1394.74, 3614.67, 34.98),
        size = vec3(1.8,1,4),
        heading = 110,
    },
    [7] = {
        coords = vector3(3807.49, 4479.37, 6.37),
        size = vec3(1.2,1,4),
        heading = 295,
    },
    [8] = {
        coords = vector3(3612.57, 3634.04, 44.78),
        size = vec3(0.8,1,4),
        heading = 350,
    },
    [9] = {
        coords = vector3(1242.69, 1870.06, 78.98),
        size = vec3(1.2,1,2.8),
        heading = 310,
    },
    [10] = {
        coords = vector3(669.72, 100.25, 80.75),
        size = vec3(1.4,1,2.5),
        heading = 90,
    },
}