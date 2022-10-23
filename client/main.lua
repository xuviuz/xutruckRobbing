local QBCore = exports['qb-core']:GetCoreObject()
local truckModel = "pounder"
local truckerPed = "s_m_m_trucker_01"
local truckForRob
local jacking = false
local isInTruck = false
local isPoliceAlertSent = false
local timerForLocationUpdate = 420000

local PlayerData
local PlayerJob
local HasGottenLoot = false

local unloaderSpawned = false

local truckHasMaterials = false

local LastTimeBlipWasMade

local truckLocationBlip

Citizen.CreateThread(function()
    while true do
	    if truckForRob then
		    local testIfInTruck = IsPedInVehicle(PlayerPedId(), truckForRob, false)
		    if testIfInTruck then
			    if isInTruck == false  then
				    isInTruck = true
				    if isPoliceAlertSent == false then
					    TriggerEvent("xuTruckRobbery:client:911alert")
				    end
			    end
		    else
			    if isInTruck then
				    isInTruck = false
			    end
		    end	
		    if isInTruck then
                TriggerEvent('xuTruckRobbery:client:robberyLocationBlip')
                Wait(timerForLocationUpdate)
		    else
		    end
	    end
    Citizen.Wait(1000)
    end
end)

local function spawnUnloaderPeds()
    if not Config.unloaderPeds or not next(Config.unloaderPeds) or pedsSpawned then return end
    for i = 1, #Config.unloaderPeds do
        local current = Config.unloaderPeds[i]
        current.model = type(current.model) == 'string' and GetHashKey(current.model) or current.model
        RequestModel(current.model)
        while not HasModelLoaded(current.model) do
            Wait(0)
        end
        local unloaderPed = CreatePed(0, current.model, current.coords.x, current.coords.y, current.coords.z, current.coords.w, false, false)
        FreezeEntityPosition(unloaderPed, true)
        SetEntityInvincible(unloaderPed, true)
        SetBlockingOfNonTemporaryEvents(unloaderPed, true)
        current.pedHandle = unloaderPed
        local unloaderOptions = nil
        if current.stolenTruckUnloader then
            unloaderOptions = {
                label = 'Talk with unloader',
                icon = 'far fa-arrow-alt-circle-right',
                action = function()
                    TriggerEvent('xuTruckRobbery:client:openUnloaderMenu')
                end
            }
        end
        if unloaderOptions then
            exports['qb-target']:AddTargetEntity(unloaderPed, {
                options = {unloaderOptions},
                distance = 2.0
            })
        end
    end
    unloaderSpawned = true
end

RegisterNetEvent('xuTruckRobbery:client:openUnloaderMenu',function()
    local tCoords = GetEntityCoords(truckForRob)
    local dist = #(tCoords - Config.UnloadCoords)

    local unloaderMenu = {
        {
            header = 'Unloader',
            txt = 'Decide what to do with the trucks load',
            isMenuHeader = true,
        },
    }
    if HasGottenLoot == false and dist < 10 then
        unloaderMenu[#unloaderMenu + 1] = {
            header = 'Sell the load and get cash',
            txt = '',
            params = {
                event = 'xuTruckRobbery:client:waitForLootNoti',
                args = {
                    typebool = true
                }
            }
        }
    
        if truckHasMaterials then
            unloaderMenu[#unloaderMenu + 1] = {
                header = 'Get the materials from the truck',
                txt = '',
                params = {
                    event = 'xuTruckRobbery:client:waitForLootNoti',
                    args = {
                        typebool = false
                    }
                }
            }
        
        end
    else
        unloaderMenu[#unloaderMenu + 1] = {
            header = 'What do you want?',
            txt = '',
            disabled = true,
        }    
    end

    exports['qb-menu']:openMenu(unloaderMenu)
end)

RegisterNetEvent('SpawnTruck',function(str)
    print(str)
    if str == "Mats" then
        truckHasMaterials = true
    else
        truckHasMaterials = false
    end

    if HasGottenLoot then
        HasGottenLoot = false
    end

    local VehicleSpawn = Config.TruckSpawnTable[math.random(1, #Config.TruckSpawnTable)]
    local VehicleRoute = Config.TruckEndLocationTable[math.random(1,#Config.TruckEndLocationTable)]


	PlayerData = QBCore.Functions.GetPlayerData()
	PlayerJob = PlayerData.job.name

	MissionNotification()
	
	RequestModel(GetHashKey(truckModel))

	while not HasModelLoaded(GetHashKey(truckModel)) do
		Citizen.Wait(0)
	end

	truckForRob = CreateVehicle(GetHashKey(truckModel),VehicleSpawn.x,VehicleSpawn.y,VehicleSpawn.z,VehicleSpawn.heading,true,true)
	SetEntityAsMissionEntity(truckForRob)

	RequestModel(truckerPed)
	while not HasModelLoaded(truckerPed) do
		Wait(10)
	end
	
	pilot = CreatePed(26,truckerPed,x,y,z,heading,true,false)
	SetPedIntoVehicle(pilot,truckForRob,-1)
	SetPedFleeAttributes(pilot, 0, 0)
    SetPedCombatAttributes(pilot, 46, 1)
    SetPedCombatAbility(pilot, 100)
    SetPedCombatMovement(pilot, 2)
    SetPedCombatRange(pilot, 2)
    SetPedKeepTask(pilot, true)
	GiveWeaponToPed(pilot, GetHashKey("WEAPON_SAWNOFFSHOTGUN"), 250, false, true)
    SetPedAsCop(pilot, true)

	TaskVehicleDriveToCoordLongrange(pilot,truckForRob,VehicleRoute.x,VehicleRoute.y,VehicleRoute.z, 30.0,443,20.0)

end)

RegisterNetEvent('xuTruckRobbery:client:waitForLootNoti',function(data)
    MissionNotification()
    HasGottenLoot = true
    if data.typebool then
        TriggerServerEvent('xuTruckRobbery:server:getMoney')
    else
        TriggerServerEvent('xuTruckRobbery:server:getMats')
    end
end)

function MissionNotification()
    QBCore.Functions.Notify('Sure thing, just give me a moment to sort it out', 'error', 7500)
end

RegisterNetEvent('xuTruckRobbery:client:911alert', function()
    if isPoliceAlertSent == false then
        local truckCoords = GetEntityCoords(truckForRob)

        local s1, s2 = GetStreetNameAtCoord(truckCoords.x, truckCoords.y, truckCoords.z)
        local street1 = GetStreetNameFromHashKey(s1)
        local street2 = GetStreetNameFromHashKey(s2)
        local streetLabel = street1
        if street2 ~= nil then
            streetLabel = streetLabel .. " " .. street2
        end
        TriggerServerEvent("xuTruckRobbery:server:callCops", streetLabel, truckCoords)

        PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 0)
        isPoliceAlertSent = true
    end
end)

RegisterNetEvent('xuTruckRobbery:client:robberyLocationBlip',function()
    if PlayerJob == "police" then
        local truckTrans = 150
        local truckLocationBlipCoords = GetEntityCoords(truckForRob)
        local rndX,rndY,rndZ 
        rndX = math.random(-200,200)
        rndY = math.random(-200,200)
        rndZ = math.random(-200,200)
        local modifiedBlipCoords = vector3(truckLocationBlipCoords.x + rndX, truckLocationBlipCoords.y + rndY, truckLocationBlipCoords.z + rndZ)
        truckLocationBlip = AddBlipForRadius(modifiedBlipCoords, 300.0)
        SetBlipColour(truckLocationBlip, 1)
        SetBlipAlpha(truckLocationBlip, truckTrans)
        while truckTrans ~= 0 do
            Wait(180 * 4)
            truckTrans = truckTrans - 1
            SetBlipAlpha(truckLocationBlip, truckTrans)
            if truckTrans == 0 then
                SetBlipSprite(truckLocationBlip, 2)
                RemoveBlip(truckLocationBlip)
                return
            end
        end
    end
end)

RegisterNetEvent('xuTruckRobbery:client:robberyCall', function(streetLabel, coords)
    if PlayerJob == "police" then
        local store = "Freight Truck"

        PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
        TriggerEvent('qb-policealerts:client:AddPoliceAlert', {
            timeOut = 10000,
            alertTitle = "Freight Truck Robbery Attempt",
            coords = {
                x = coords.x,
                y = coords.y,
                z = coords.z
            },
            details = {
                [1] = {
                    icon = '<i class="fas fa-university"></i>',
                    detail = store
                },
                [2] = {
                    icon = '<i class="fas fa-globe-europe"></i>',
                    detail = streetLabel
                }
            },
            callSign = QBCore.Functions.GetPlayerData().metadata["callsign"]
        })

        local transG = 250
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 487)
        SetBlipColour(blip, 4)
        SetBlipDisplay(blip, 4)
        SetBlipAlpha(blip, transG)
        SetBlipScale(blip, 1.2)
        SetBlipFlashes(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString("10-15: Freight truck robbing")
        EndTextCommandSetBlipName(blip)
        while transG ~= 0 do
            Wait(180 )
            transG = transG - 1
            SetBlipAlpha(blip, transG)
            if transG == 0 then
                SetBlipSprite(blip, 2)
                RemoveBlip(blip)
                return
            end
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    spawnUnloaderPeds()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    deletePeds()
end)
