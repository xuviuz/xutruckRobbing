local QBCore = exports['qb-core']:GetCoreObject()
local truckModel = "pounder"
local truckerPed = "s_m_m_trucker_01"
local truckForRob
local jacked = false
local isInTruck = false
local isPoliceAlertSent = false
local timerForLocationActive = false
local PlayerData
local PlayerJob
local HasGottenLoot = false
local unloaderSpawned = false
local truckHasMaterials = false
local truckLocationBlip
local amountOfPins = 4
local amountOfPinsDone = 0
local allPinsOpened = false
local playerCanDoPin = false
local playerCanFindCard = false
local cardZoneMade = false
local playerDidCorrectPin = false
local playerDidWrongPin = false
local gameTimeForPinTimer = 0
local truckEndPoint 
local trucker

--Threads

Citizen.CreateThread(function()
    while true do
	    if truckForRob then
            local tCoords = GetEntityCoords(truckForRob)
		    local testIfInTruck = IsPedInVehicle(PlayerPedId(), truckForRob, false)
		    if testIfInTruck then
                playerCanDoPin = false
			    if isInTruck == false  then
				    isInTruck = true
				    if isPoliceAlertSent == false then
					    TriggerEvent("xuTruckRobbery:client:911alert")
                        playerCanFindCard = true
				    end
			    end
		    else
			    if isInTruck then
				    isInTruck = false
			    end
                if trucker then
                    if IsPedDeadOrDying(trucker, false) then
                        trucker = nil
                    else
                        if IsPedInVehicle(trucker,truckForRob,false) then
                            if #(tCoords - truckEndPoint) < 20 then
                                TriggerEvent('xuTruckRobbery:client:despawnTruck')
                                TriggerEvent('xuTruckRobbery:client:despawnTrucker')
                            end
                        end
                    end

                end
                if allPinsOpened == false then
                    if CheckDistForUnloader() then
                        local closestVehicle = getNearestVeh()
                        if closestVehicle ~= 0 then
                            if closestVehicle == truckForRob then
                                local plyCoords = GetEntityCoords(PlayerPedId(), false)
                                local distForPinUnlock = #(plyCoords - tCoords)
                                if distForPinUnlock < 12.5 then
                                    playerCanDoPin = true
                                else
                                    playerCanDoPin = false
                                end
                            else
                                playerCanDoPin = false
                            end
                        else
                            playerCanDoPin = false
                        end
                    else
                        playerCanDoPin = false
                    end
                else
                    if playerCanDoPin then
                        playerCanDoPin = false
                    end
                end
                
		    end	
		    if isInTruck then
                if timerForLocationActive == false then
                    TriggerEvent('xuTruckRobbery:client:robberyLocationBlip')
                end
		    end
            if playerDidCorrectPin then
                while GetGameTimer() - gameTimeForPinTimer < Config.CorrectPinWaitTimer do
                    playerDidCorrectPin = true
                    Citizen.Wait(10)
                end
                local txtForNoti = "Correct, " .. amountOfPinsDone .. " out of " .. amountOfPins .." done"
                MissionNotification(txtForNoti,'primary')
                playerDidCorrectPin = false
            end
            if playerDidWrongPin then
                while GetGameTimer() - gameTimeForPinTimer < Config.WrongPinWaitTimer do
                    playerDidWrongPin = true
                    Citizen.Wait(10)
                end
                playerDidWrongPin = false
            end
	    end
    Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        if playerCanDoPin and playerDidCorrectPin == false and playerDidWrongPin == false then
            exports['qb-core']:DrawText('[E] - Input lock pincode','left')
            if IsControlJustPressed(0,38) then
                exports['qb-core']:KeyPressed(38)
                TriggerEvent('xuTruckRobbery:client:getPinAndOpenKeyPad')
            end
        else
            exports['qb-core']:HideText()
            Citizen.Wait(1500)
        end 
        
        if playerCanFindCard then
            if cardZoneMade == false then
                local idForPinCodeLoc = getOneOfTheFurthestPinCodes()
                SetNewWaypoint(Config.pinCodeCardLocation[idForPinCodeLoc].coords.x, Config.pinCodeCardLocation[idForPinCodeLoc].coords.y)
                MissionNotification('The drivers notes shows that the trucks pincodes are here','primary')
                MissionNotification('Get someone to go get them while you get to an unloader!','primary')
                exports.ox_target:addBoxZone({
                    coords = Config.pinCodeCardLocation[idForPinCodeLoc].coords,
                    size = Config.pinCodeCardLocation[idForPinCodeLoc].size,
                    rotation = Config.pinCodeCardLocation[idForPinCodeLoc].heading,
                    debug = true,
                    options = {
                        name = 'pincardloc',
                        event = 'xuTruckRobbery:client:getPinArrAndOpenCard',
                        icon = 'fas fa-user',
                        label = 'Look at pin card',
                    }
                })
                cardZoneMade = true
            end
        else
            if cardZoneMade then
                exports.ox_target:removeZone("PinCardZone")
                exports.ox_target:removeZone("TruckRouteZone")
            end
        end
    end
end)

--Functions

function createScheduleBox()
    exports.ox_target:addBoxZone({
        coords = vec3(-69.14, 6252.99, 31.29),
        size = vec3(0.6,0.6,0.6),
        rotation = 33,
        debug = true,
        options = {
            name = 'box',
            event = 'xuTruckRobbery:client:getRouteAndOpenMap',
            icon = 'fas fa-user',
            label = 'Look at route list',
        }
    })
end

function CheckDistForUnloader()
    local tCoords = GetEntityCoords(truckForRob)
    local distBool = false    
    for i = 1, #Config.UnloadCoords do
        if #(Config.UnloadCoords[i].coords - tCoords) < 10.0 then
            distBool = true
        end
    end

    return distBool
end

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
                name = 'unloaderPeds',
                event = 'xuTruckRobbery:client:openUnloaderMenu',
                icon = 'far fa-arrow-alt-circle-right',
                label = 'Talk with unloader',
                canInteract = function(_,distance)
                    return distance < 2
                end
            }
        end
        if unloaderOptions then
            exports.ox_target:addLocalEntity(unloaderPed, unloaderOptions)
        end
    end
    unloaderSpawned = true
end

local function deleteUnloaderPeds()
    if not Config.unloaderPeds or not next(Config.unloaderPeds) or not pedsSpawned then return end
    for i = 1, #Config.unloaderPeds do
        local current = Config.unloaderPeds[i]
        if current.pedHandle then
            DeletePed(current.pedHandle)
        end
    end
end


function getNearestVeh()
    local pos = GetEntityCoords(PlayerPedId())
    local entityWorld = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 20.0, 0.0)

    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, PlayerPedId(), 0)
    local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)
    return vehicleHandle
end



function getOneOfTheFurthestPinCodes()
    local tCoords = GetEntityCoords(truckForRob)
    local pinCodeArr = {}
    local idArr = {}

    for i=1, #Config.pinCodeCardLocation do
        pinCodeArr[i] = {}
        pinCodeArr[i].distance = #(tCoords - Config.pinCodeCardLocation[i].coords)
        pinCodeArr[i].id = i
    end
    table.sort(pinCodeArr,function (k1,k2) return k1.distance < k2.distance end)
    for i = 1, #pinCodeArr do
        if i <= 3 then 
            idArr[i] = pinCodeArr[#pinCodeArr+1-i].id
        end
    end

    rndPinId = math.random(1,3)

    return idArr[rndPinId]
end

function ResetValues()
    jacked = false
    isInTruck = false
    isPoliceAlertSent = false
    timerForLocationActive = false
    HasGottenLoot = false
    truckHasMaterials = false
    amountOfPinsDone = 0
    allPinsOpened = false
    playerCanDoPin = false
    playerCanFindCard = false
    cardZoneMade = false
end

--Netevents 

RegisterNetEvent('xuTruckRobbery:client:openUnloaderMenu',function()

    local unloaderMenu = {}

    if HasGottenLoot == false and CheckDistForUnloader() and allPinsOpened then
        unloaderMenu[#unloaderMenu + 1] = {
            title = 'Sell the load and get cash',
            event = 'xuTruckRobbery:client:waitForLootNoti',
            args = {
                typebool = true
            }
        }
    
        if truckHasMaterials then
            unloaderMenu[#unloaderMenu + 1] = {
                title = 'Get the materials from the truck',
                event = 'xuTruckRobbery:client:waitForLootNoti',
                args = {
                    typebool = false
                }
            }
        
        end
    else
        if CheckDistForUnloader() and allPinsOpened == false then
            unloaderMenu[#unloaderMenu + 1] = {
                title = 'Unlock the locks doofus',
                disabled = true,
            }    
        else
            unloaderMenu[#unloaderMenu + 1] = {
                title = 'What do you want?',
                disabled = true,
            }    
        end
    end

    lib.registerContext({
        id = 'unloader_menu',
        title = 'Unloader',
        onExit = function()
            
        end,
        options = unloaderMenu,
    })
    lib.showContext('unloader_menu')
end)

RegisterNetEvent('xuTruckRobbery:client:spawnTruck',function(str,VehicleSpawn,VehicleRoute)
    ResetValues()
    if str == "Mats" then
        truckHasMaterials = true
    else
        truckHasMaterials = false
    end

	PlayerData = QBCore.Functions.GetPlayerData()
	PlayerJob = PlayerData.job.name
	
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
    truckEndPoint = VehicleRoute
    trucker = pilot

end)

RegisterNetEvent('xuTruckRobbery:client:despawnTruck',function(data)
    DeleteVehicle(truckForRob)
    truckForRob = nil
end)

RegisterNetEvent('xuTruckRobbery:client:despawnTrucker',function(data)
    DeletePed(trucker)
    trucker = nil
end)

RegisterNetEvent('xuTruckRobbery:client:waitForLootNoti',function(data)
    MissionNotification('Sure thing, just give me a moment to sort it out','primary')
    HasGottenLoot = true
    if data.typebool then
        TriggerServerEvent('xuTruckRobbery:server:getMoney')
    else
        TriggerServerEvent('xuTruckRobbery:server:getMats')
    end
end)

function MissionNotification(txt,notiType)
    QBCore.Functions.Notify(txt, notiType, 7500)
end

RegisterNetEvent('xuTruckRobbery:client:911alert', function()
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
end)

RegisterNetEvent('xuTruckRobbery:client:robberyLocationBlip',function() 
        if PlayerJob == "police" then
            timerForLocationActive = true
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
                Wait(Config.timerForLocationUpdate)
                truckTrans = truckTrans - 1
                SetBlipAlpha(truckLocationBlip, truckTrans)
                if truckTrans == 0 then
                    SetBlipSprite(truckLocationBlip, 2)
                    RemoveBlip(truckLocationBlip)
                    timerForLocationActive = false
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
            Wait(720)
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


RegisterNetEvent('xuTruckRobbery:client:handleDonePin', function()

    playerDidCorrectPin = true
    gameTimeForPinTimer = GetGameTimer()
    amountOfPinsDone = amountOfPinsDone + 1
    if amountOfPinsDone == Config.amountOfPins then
        allPinsOpened = true
    end
    local rndNr = math.random(1,100)
    if rndNr < 25 then
        TriggerEvent('xuTruckRobbery:client:911alert')
    end
    local txtForNotiWaitingForServer = "Keypad connecting with database, please wait..."
    MissionNotification(txtForNotiWaitingForServer,'primary')
end)
RegisterNetEvent('xuTruckRobbery:client:handleWrongPin', function()
    playerDidWrongPin = true
    gameTimeForPinTimer = GetGameTimer()
    TriggerEvent("xuTruckRobbery:client:911alert")
    local txtForFailedPinNoti = "WRONG PASSWORD, SYSTEM LOCKED FOR ".. (Config.WrongPinWaitTimer/1000) .. " SECONDS"
    MissionNotification(txtForFailedPinNoti,'error')
end)

RegisterNetEvent('xuTruckRobbery:client:openKeyPad', function(rndPin)
    local padBackColor
    if amountOfPinsDone == 0 then
        padBackColor = "#cf1719"
    elseif amountOfPinsDone == 1 then
        padBackColor = "#3fa535"
    elseif amountOfPinsDone == 2 then
        padBackColor = "#feed01"
    else
        padBackColor = "#009fe3"
    end
    SendNUIMessage({
        pin = rndPin,
        display = true,
        codeOrPad = 1,
        PadBackgroundColor = padBackColor,
    })
    SetNuiFocus(true,true)
end)

RegisterNUICallback('xuTruckRobbery:client:handlePassPost',function(data)
    SendNUIMessage({
        display = false,
        codeOrPad = 1,
    })
    SetNuiFocus(false,false)

    if data then
        TriggerEvent('xuTruckRobbery:client:handleDonePin')
    else
        TriggerEvent('xuTruckRobbery:client:handleWrongPin')
    end
end)

RegisterNetEvent('xuTruckRobbery:client:openPinCard',function(PinArr)
    SendNUIMessage({
        pinArr = PinArr,
        display = true,
        codeOrPad = 2,
    })
    SetNuiFocus(true,true)
end)

RegisterNetEvent('xuTruckRobbery:client:openRoute',function(TruckCalendar)
    SendNUIMessage({
        display = true,
        codeOrPad = 3,
        routeArr = TruckCalendar,
    })
    SetNuiFocus(true,true)
end)

RegisterNUICallback('xuTruckRobbery:client:closeKeyPad',function()
    SendNUIMessage({
        display = false,
        codeOrPad = 4,
    })
    SetNuiFocus(false,false)
end)

RegisterNetEvent('xuTruckRobbery:client:getPinAndOpenKeyPad', function()
    TriggerServerEvent('xuTruckRobbery:server:getPin',amountOfPinsDone)
end)

RegisterNetEvent('xuTruckRobbery:client:getPinArrAndOpenCard',function()
    TriggerServerEvent('xuTruckRobbery:server:getPinArr')
end)

RegisterNetEvent('xuTruckRobbery:client:getRouteAndOpenMap', function()
    TriggerServerEvent('xuTruckRobbery:server:getRoute')
end)


RegisterCommand('openpincode',function()
    TriggerEvent('xuTruckRobbery:client:getPinAndOpenKeyPad')
end)

RegisterCommand('openpincard',function()
    TriggerEvent('xuTruckRobbery:client:getPinArrAndOpenCard')
end)

RegisterCommand('openroute',function()
    TriggerEvent('xuTruckRobbery:client:getRouteAndOpenMap')
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    createScheduleBox()

    deleteUnloaderPeds()
    spawnUnloaderPeds()
end)