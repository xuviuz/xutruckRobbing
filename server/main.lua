local QBCore = exports['qb-core']:GetCoreObject()
local ActiveTrucks = 0
local TruckType = nil
local PinArr = {}
local TruckCalendar = {}
local TrucksSpawnedSoFar = 1

Citizen.CreateThread(function()
	while true do
		local dateNow = os.time()
		local timeVal = os.date("%H",dateNow)..":"..os.date("%M",dateNow)

		if(timeVal == TruckCalendar[TrucksSpawnedSoFar].time) then
			TriggerEvent('xuTruckRobbery:server:spawnTruck')
		end

		Citizen.Wait(1000)
	end
end)

RegisterNetEvent('xuTruckRobbery:server:spawnTruck',function()
	local _source = source
	if ActiveTrucks == 0  then
		Trucktype = Config.TruckType[math.random(1, #Config.TruckType)]
		SetPins()
		TriggerClientEvent('xuTruckRobbery:client:spawnTruck', -1,Trucktype,TruckCalendar[TrucksSpawnedSoFar].startCoord,TruckCalendar[TrucksSpawnedSoFar].stopCoord)
		TrucksSpawnedSoFar = TrucksSpawnedSoFar+1
		TruckCooldown()
	end
end)


--This command is for testing out the script so you don't have the wait for the timer
RegisterCommand("spawnmytruck", function()
	local _source = source
	if ActiveTrucks == 0  then
		Trucktype = Config.TruckType[math.random(1, #Config.TruckType)]
		SetPins()
		TriggerClientEvent('xuTruckRobbery:client:spawnTruck', -1,Trucktype,TruckCalendar[TrucksSpawnedSoFar].startCoord,TruckCalendar[TrucksSpawnedSoFar].stopCoord)
		TruckCooldown()
	end
end)

RegisterServerEvent('xuTruckRobbery:server:callCops', function(streetLabel, coords)
    TriggerClientEvent("xuTruckRobbery:client:robberyCall", -1, streetLabel, coords)
end)

RegisterNetEvent('xuTruckRobbery:server:getMats', function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	Citizen.Wait(Config.GetLootTimer)
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
	Citizen.Wait(Config.GetLootTimer)
	local amountToGet = math.random(Config.MinCashToReceive, Config.MaxCashToReceive)
	Player.Functions.AddMoney('cash', amountToGet)
	TriggerClientEvent('xuTruckRobbery:client:despawnTruck',-1)
	TriggerClientEvent('xuTruckRobbery:client:despawnTrucker',-1)
end)

RegisterNetEvent('xuTruckRobbery:server:getPin',function(amountDone)
	local pinToSend = PinArr[amountDone + 1]
	TriggerClientEvent('xuTruckRobbery:client:openKeyPad',-1, pinToSend)
end)

RegisterNetEvent('xuTruckRobbery:server:getPinArr', function()
	TriggerClientEvent('xuTruckRobbery:client:openPinCard',-1,PinArr)
end)

RegisterNetEvent('xuTruckRobbery:server:getRoute',function()
	TriggerClientEvent('xuTruckRobbery:client:openRoute',-1,TruckCalendar)
end)

function SetPins()
	if #PinArr > 0 then
		PinArr = {}
	end
	for i=1, Config.amountOfPins do
		PinArr[i] = math.random(100001,999999)
	end
end


function TruckCooldown() 
	ActiveTrucks = 1 
	Wait(Config.ResetTimer)
	ActiveTrucks = 0
	Trucktype = nil
end

function ScheduleFutureTrucks()
	for i=1, 7 do
		stopRnd = math.random(1,#Config.TruckEndLocationTable)
		startRnd = math.random(1,#Config.TruckSpawnTable)
		local timeVal = 0
		local dateNow = os.time()
		if i == 1 then
			timeVal = os.date("%H",dateNow+1800)..":"..os.date("%M",dateNow+1800)
		elseif i == 2 then
			timeVal = os.date("%H",dateNow+8280)..":"..os.date("%M",dateNow+8280)
		elseif i == 3 then
			timeVal = os.date("%H",dateNow+16560)..":"..os.date("%M",dateNow+16560)
		elseif i == 4 then
			timeVal = os.date("%H",dateNow+24840)..":"..os.date("%M",dateNow+24840)
		elseif i == 5 then
			timeVal = os.date("%H",dateNow+33120)..":"..os.date("%M",dateNow+33120)
		elseif i == 6 then
			timeVal = os.date("%H",dateNow+41400)..":"..os.date("%M",dateNow+41400)
		elseif i == 7 then
			timeVal = os.date("%H",dateNow+49680)..":"..os.date("%M",dateNow+49680)
		end

		TruckCalendar[i] = {
			start = Config.TruckSpawnTable[startRnd].color,
			startCoord = Config.TruckSpawnTable[startRnd].coords,
			stop = Config.TruckEndLocationTable[stopRnd].color,
			stopBorder = Config.TruckEndLocationTable[stopRnd].border,
			stopCoord = Config.TruckEndLocationTable[stopRnd].coords,
			time = timeVal,
		}
	end
end

AddEventHandler('onResourceStart', function(resourceName)
	if(GetCurrentResourceName() ~= resourceName) then
		return
	end
	ScheduleFutureTrucks()
end)