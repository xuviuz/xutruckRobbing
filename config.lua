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
	}

Config.TruckSpawnTable = {
    [1] = vector4(-303.02,-2720.2,6.00,-303.02),
    [2] = vector4(-1120.39, -2189.03, 13.26, -129.77),
}

Config.TruckEndLocationTable = {
    [1] = vector3(891.73,-2456.79,28.58)
}

Config.unloaderPeds = {
    {
        model = 's_m_m_trucker_01',
        coords = vector4(-567.21, -1686.66, 18.25, 226.95),
        stolenTruckUnloader = true,
    },
}

Config.TruckType = {
    [1] = "Money",
    [2] = "Mats",
}