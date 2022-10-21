local QBCore = exports['qb-core']:GetCoreObject()
local ActiveTrucks = 0
local ResetTimer = 15000
local TruckType = nil
local GetLootTimer = 10000


RegisterCommand("spawnmytruck", function()
	local _source = source
	if ActiveTrucks == 0  then
		Trucktype = Config.TruckType[math.random(1, #Config.TruckType)]
		TriggerClientEvent('SpawnTruck', -1,Trucktype)
		TruckCooldown()
	else
	end
end)

RegisterServerEvent('xuTruckRobbery:server:callCops', function(streetLabel, coords)
    TriggerClientEvent("xuTruckRobbery:client:robberyCall", -1, streetLabel, coords)
end)

RegisterNetEvent('xuTruckRobbery:server:getMats', function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	Citizen.Wait(GetLootTimer)
		for _ = 1, math.random(1, Config.MaxItemsReceived), 1 do
		  local randItem = Config.ItemTable[math.random(1, #Config.ItemTable)]
		  local amount = math.random(Config.MinItemReceivedQty, Config.MaxItemReceivedQty)
		  Player.Functions.AddItem(randItem, amount)
		  TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[randItem], 'add')
		  Wait(500)
		end
		local chance = math.random(1, 100)
		if chance < 5 then
		  Player.Functions.AddItem(Config.ChanceItem, 1, false)
		  TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ChanceItem], 'add')
		end

		if Config.LuckyItem then
			local luck = math.random(1, 10)
			local odd = math.random(1, 10)
			if luck == odd then
		  		local random = math.random(1, 3)
		  	Player.Functions.AddItem(Config.LuckyItem, random)
			TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.LuckyItem], 'add')
		end
	end
end)

RegisterNetEvent('xuTruckRobbery:server:getMoney',function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	Citizen.Wait(GetLootTimer)
	local amountToGet = math.random(Config.MinCashToReceive, Config.MaxCashToReceive)
	Player.Functions.AddMoney('cash', amountToGet)
end)

function TruckCooldown() 
	ActiveTrucks = 1 
	Wait(ResetTimer)
	ActiveTrucks = 0
	Trucktype = nil
end