local vehicleKilometers = {}
local vehicleCooldown = {}
-- local engineFailureFlags = {}
-- local engineRestored = {}
local batteryDrainFlags = {}
local radiatorLeakFlags = {}
local brakeFailureFlags = {}
local suspensionDamageFlags = {}
local alternatorFailureFlags = {}
local transmissionFluidLeakFlags = {}
local clutchFailureFlags = {}
local fuelFilterCloggedFlags = {}
local petrolLossFlag = {}
local hoodLatchFailureFlags = {}
local originalTractionLossMult = nil
local originalTractionCurveMin = nil
local originalLowSpeedTractionLossMult = nil
local lastVehicle = nil
local lastVehicle2 = nil
-- local damageMultiplier = Config.damageMultiplier
local checkInterval2 = Config.CheckIntervalEngineDamage
local previousSpeed = 0
local speedLimitActive = false
local originalZ = nil
local brakeTemperature = 0
local maxBrakeTemperature = Config.MaxBrakeTemp
local isBrakeOverheated = false
local coolingRate = Config.CoolingRate
local originalBrakeForce = nil
local originalHandbrakeForce = nil


function DebugPrint(...)
    if Config.DebugMode then
        print(...)
    end
end

if Config.FrameWork == "esx" then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.FrameWork == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
end

function SendNotification(msgtitle, msg, time, type)
    if Config.UseOXNotifications then
        lib.notify({
            title = msgtitle,
            description = msg,
            showDuration = true,
            type = type,
            style = {
                backgroundColor = 'rgba(0, 0, 0, 0.75)',
                color = 'rgba(255, 255, 255, 1)',
                ['.description'] = {
                    color = '#909296',
                    backgroundColor = 'transparent'
                }
            }
        })
    else
        if Config.FrameWork == 'qb' then
            QBCore.Functions.Notify(msg, type, time)
        elseif Config.FrameWork == 'esx' then
            TriggerEvent('esx:showNotification', msg, type, time)
        end
    end
end

RegisterNetEvent("SendNotification")
AddEventHandler("SendNotification", function(msgtitle, msg, time, type)
    SendNotification(msgtitle, msg, time, type)
end)


--   oooooooooo.  ooooooooo.   oooooooooooo       .o.       oooo    oooo oooooooooo.     .oooooo.   oooooo   oooooo     oooo ooooo      ooo  .oooooo..o
--   `888'   `Y8b `888   `Y88. `888'     `8      .888.      `888   .8P'  `888'   `Y8b   d8P'  `Y8b   `888.    `888.     .8'  `888b.     `8' d8P'    `Y8
--    888     888  888   .d88'  888             .8"888.      888  d8'     888      888 888      888   `888.   .8888.   .8'    8 `88b.    8  Y88bo.
--    888oooo888'  888ooo88P'   888oooo8       .8' `888.     88888[       888      888 888      888    `888  .8'`888. .8'     8   `88b.  8   `"Y8888o.
--    888    `88b  888`88b.     888    "      .88ooo8888.    888`88b.     888      888 888      888     `888.8'  `888.8'      8     `88b.8       `"Y88b
--    888    .88P  888  `88b.   888       o  .8'     `888.   888  `88b.   888     d88' `88b    d88'      `888'    `888'       8       `888  oo     .d8P
--   o888bood8P'  o888o  o888o o888ooooood8 o88o     o8888o o888o  o888o o888bood8P'    `Y8bood8P'        `8'      `8'       o8o        `8  8""88888P'

-- Function to calculate the distance between two points
local function calculateDistance(coords1, coords2)
    return #(coords1 - coords2)
end

-- Function to load the kilometers of a vehicle from the database
local function loadKilometers(plate)
    if Config.FrameWork == "esx" then
        if Config.MileageSystem == 'other' then
            ESX.TriggerServerCallback('realistic-vehicle:fetchKilometersFromDB', function(km)
                if km then
                    DebugPrint(km)
                    vehicleKilometers[plate] = { km = km }
                else
                    vehicleKilometers[plate] = { km = 0 }
                end
            end, plate)
        elseif Config.MileageSystem == 'default' then
            ESX.TriggerServerCallback('realistic-vehicle:fetchKilometers', function(km)
                if km then
                    DebugPrint(km)
                    vehicleKilometers[plate] = { km = km }
                else
                    vehicleKilometers[plate] = { km = 0 }
                end
            end, plate)
        end
    elseif Config.FrameWork == "qb" then
        if Config.MileageSystem == 'other' then
            QBCore.Functions.TriggerCallback('realistic-vehicle:fetchKilometersFromDB', function(km)
                if km then
                    DebugPrint(km)
                    vehicleKilometers[plate] = { km = km }
                else
                    vehicleKilometers[plate] = { km = 0 }
                end
            end, plate)
        elseif Config.MileageSystem == 'default' then
            QBCore.Functions.TriggerCallback('realistic-vehicle:fetchKilometers', function(km)
                if km then
                    DebugPrint(km)
                    vehicleKilometers[plate] = { km = km }
                else
                    vehicleKilometers[plate] = { km = 0 }
                end
            end, plate)
        end
    end

    if Config.MileageSystem == 'jg-vehiclemileage' then
        local data = lib.callback.await("realistic-vehicle:get-mileage-JG", false, plate)
        -- local distance, unit = exports["jg-vehiclemileage"]:GetMileage(plate)
        if data then
            vehicleKilometers[plate] = { km = data.mileage }
        else
            vehicleKilometers[plate] = { km = 0 }
        end
    end
end

-- Function to check if the vehicle is on the excluded list
local function isVehicleExcluded(plate)
    for _, excludedPlate in ipairs(Config.ExcludedVehicles) do
        if plate == excludedPlate then
            DebugPrint(plate)
            return true
        end
    end
    return false
end

-- Function to check if the vehicle is on the excluded list by prefix anywhere on the license plate
local function isVehicleExcludedPrefix(plate)
    for _, prefix in ipairs(Config.ExcludedPrefixes) do
        if string.find(plate, prefix) then
            DebugPrint(plate, prefix)
            return true
        end
    end
    return false
end

local function showKilometersInNUI(km, position)
    SendNUIMessage({
        type = "show",
        value = km,
        position = position or "top-center"
    })
end

local function hideNUI()
    SendNUIMessage({
        type = "hide"
    })
end

local function isVehicleOwned(plate)
    local isOwned = lib.callback.await("realistic-vehicle:isVehOwned", false, plate)
    return isOwned or false
end

-- Main thread to update kilometers and handle breakdowns
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.CheckInterval)

        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if vehicle ~= 0 then
            local plate = GetVehicleNumberPlateText(vehicle)
            local currentCoords = GetEntityCoords(playerPed)

            if not isVehicleOwned(plate) then
                DebugPrint('Vehículo no es de nadie, no se actualizarán los kilómetros')
                goto continueLoop
            end

            if isVehicleExcluded(plate) or isVehicleExcludedPrefix(plate) then
                DebugPrint('Vehículo excluido')
                goto continueLoop
            end

            if vehicleKilometers[plate] == nil then
                loadKilometers(plate)
            else
                if Config.MileageSystem == 'default' then
                    local oldCoords = vehicleKilometers[plate].coords or currentCoords
                    local distance = calculateDistance(oldCoords, currentCoords) / 1000

                    distance = distance * Config.KilometerMultiplier

                    vehicleKilometers[plate].km = vehicleKilometers[plate].km + distance
                    vehicleKilometers[plate].coords = currentCoords

                    if Config.FrameWork == "esx" then
                        TriggerServerEvent('realistic-vehicle:updateKilometers', plate, vehicleKilometers[plate].km)
                    elseif Config.FrameWork == "qb" then
                        TriggerServerEvent('realistic-vehicle:updateKilometers', plate, vehicleKilometers[plate].km)
                    end
                    DebugPrint('Guardando kilometros en la DataBase')
                    DebugPrint('KM nuevos: ' .. vehicleKilometers[plate].km)
                    showKilometersInNUI(vehicleKilometers[plate].km, Config.KMDisplayPosition)
                elseif Config.MileageSystem == 'other' then
                    fetchKilometers = function()
                        local callback = function(km)
                            if km then
                                DebugPrint(km)
                                vehicleKilometers[plate] = { km = km }
                            else
                                vehicleKilometers[plate] = { km = 0 }
                            end
                            DebugPrint(vehicleKilometers[plate].km)
                        end

                        if Config.FrameWork == "esx" then
                            ESX.TriggerServerCallback('realistic-vehicle:fetchKilometersFromDB', callback, plate)
                        elseif Config.FrameWork == "qb" then
                            QBCore.Functions.TriggerCallback('realistic-vehicle:fetchKilometersFromDB', callback, plate)
                        end
                    end
                    fetchKilometers()
                elseif Config.MileageSystem == 'jg-vehiclemileage' then
                    local data = lib.callback.await("realistic-vehicle:get-mileage-JG", false, plate)
                    if data then
                        vehicleKilometers[plate] = { km = data.mileage }
                    else
                        vehicleKilometers[plate] = { km = 0 }
                    end
                    DebugPrint(vehicleKilometers[plate].km)
                end

                local km = vehicleKilometers[plate].km
                local breakdownChance = math.min((km / 1000) * Config.BaseBreakdownChance, Config.MaxBreakdownChance)
                local currentTime = GetGameTimer()
                local lastBreakdownTime = vehicleCooldown[plate] or 0

                if (currentTime - lastBreakdownTime) >= Config.BreakdownCooldown then
                    if math.random() < breakdownChance then
                        TriggerEvent('realistic-vehicle:breakdown', vehicle)
                        vehicleCooldown[plate] = currentTime
                    end
                end
            end
        else
            hideNUI()
        end
        ::continueLoop::
    end
end)

RegisterNetEvent('realistic-vehicle:breakdown')
AddEventHandler('realistic-vehicle:breakdown', function(vehicle)
    local totalWeight = 0
    for _, breakdown in ipairs(Config.BreakdownTypes) do
        totalWeight = totalWeight + breakdown.chance
    end

    local rand = math.random() * totalWeight
    local cumulativeWeight = 0

    for _, breakdown in ipairs(Config.BreakdownTypes) do
        cumulativeWeight = cumulativeWeight + breakdown.chance
        if rand <= cumulativeWeight then
            breakdown.action(vehicle)
            break
        end
    end
end)

if Config.DebugMode then
    RegisterCommand('testbreakdown', function()
        TriggerServerEvent('realistic-vehicle:testBreakdown')
        DebugPrint('Usado comando "testbreakdown"')
    end, false)

    RegisterCommand('SetVehicleEngineHealth', function(source, args)
        local playerPed = GetPlayerPed(-1)
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if vehicle ~= 0 then
            local engineHealth = tonumber(args[1])

            if engineHealth then
                SetVehicleEngineHealth(vehicle, engineHealth)
                DebugPrint('Usado comando "SetVehicleEngineHealth" con valor: ' .. engineHealth)
            else
                DebugPrint('Valor de salud del motor no válido.')
            end
        else
            DebugPrint('No estás en un vehículo.')
        end
    end, false)
end

RegisterNetEvent('realistic-vehicle:triggerTestBreakdown')
AddEventHandler('realistic-vehicle:triggerTestBreakdown', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle ~= 0 then
        local totalWeight = 0
        for _, breakdown in ipairs(Config.BreakdownTypes) do
            totalWeight = totalWeight + breakdown.chance
        end

        local rand = math.random() * totalWeight
        local cumulativeWeight = 0

        for _, breakdown in ipairs(Config.BreakdownTypes) do
            cumulativeWeight = cumulativeWeight + breakdown.chance
            if rand <= cumulativeWeight then
                breakdown.action(vehicle)
                break
            end
        end
    else
        -- ESX.ShowNotification("No estás en un vehículo.")
        TriggerEvent('SendNotification', '', "No estás en un vehículo.", 5000, "info")
    end
end)

-- Function to avoid possible incompatibilities with other scripts that modify the health of the engine
-- Unused at the moment

-- RegisterNetEvent('realistic-vehicle:engineFailureFlag')
-- AddEventHandler('realistic-vehicle:engineFailureFlag', function(vehicle, isFailing)
--     engineFailureFlags[vehicle] = isFailing
--     if not isFailing then
--         engineRestored[vehicle] = true
--     end
-- end)

-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(1000)
--         for vehicle, isFailing in pairs(engineFailureFlags) do
--             if isFailing then
--                 local currentHealth = GetVehicleEngineHealth(vehicle)
--                 if currentHealth > 0.0 then
--                     SetVehicleEngineHealth(vehicle, 0.0)
--                 end
--             elseif not engineRestored[vehicle] then
--                 local currentHealth = GetVehicleEngineHealth(vehicle)
--                 if currentHealth < 1000.0 then
--                     SetVehicleEngineHealth(vehicle, 1000.0)
--                 end
--                 engineRestored[vehicle] = true
--             end
--         end
--     end
-- end)


--     .oooooo.   ooooooooo.         .o.        .oooooo..o ooooo   ooooo      oooooooooo.         .o.       ooo        ooooo       .o.         .oooooo.    oooooooooooo
--    d8P'  `Y8b  `888   `Y88.      .888.      d8P'    `Y8 `888'   `888'      `888'   `Y8b       .888.      `88.       .888'      .888.       d8P'  `Y8b   `888'     `8
--   888           888   .d88'     .8"888.     Y88bo.       888     888        888      888     .8"888.      888b     d'888      .8"888.     888            888
--   888           888ooo88P'     .8' `888.     `"Y8888o.   888ooooo888        888      888    .8' `888.     8 Y88. .P  888     .8' `888.    888            888oooo8
--   888           888`88b.      .88ooo8888.        `"Y88b  888     888        888      888   .88ooo8888.    8  `888'   888    .88ooo8888.   888     ooooo  888    "
--   `88b    ooo   888  `88b.   .8'     `888.  oo     .d8P  888     888        888     d88'  .8'     `888.   8    Y     888   .8'     `888.  `88.    .88'   888       o
--    `Y8bood8P'  o888o  o888o o88o     o8888o 8""88888P'  o888o   o888o      o888bood8P'   o88o     o8888o o8o        o888o o88o     o8888o  `Y8bood8P'   o888ooooood8

function ApplyEngineDamage(vehicle, damageAmount)
    if DoesEntityExist(vehicle) then
        local engineHealth = GetVehicleEngineHealth(vehicle)
        local petrolTankHealth = GetVehiclePetrolTankHealth(vehicle)
        local healthBody = GetVehicleBodyHealth(vehicle)
        DebugPrint('Salud del motor antes del daño: ' .. engineHealth)
        DebugPrint('Cantidad de daño: ' .. damageAmount)

        if engineHealth ~= engineHealth then
            DebugPrint("Error: engineHealth es NaN")
            return
        end

        local newEngineHealth = engineHealth - damageAmount
        local newHealthBody = healthBody - damageAmount
        local newPetrolTankHealth = petrolTankHealth - damageAmount


        if newEngineHealth < 950 and newEngineHealth >= 800 then
            newEngineHealth = math.max(newEngineHealth, -250)
            newHealthBody = math.max(newEngineHealth, -250)
            newPetrolTankHealth = math.max(newEngineHealth, -250)
        elseif newEngineHealth < 800 and newEngineHealth >= 500 then
            newEngineHealth = math.max(newEngineHealth, -500)
            newHealthBody = math.max(newEngineHealth, -500)
            newPetrolTankHealth = math.max(newEngineHealth, -500)
        elseif newEngineHealth < 500 and newEngineHealth >= 300 then
            newEngineHealth = math.max(newEngineHealth, -2000)
            newHealthBody = math.max(newEngineHealth, -2000)
            newPetrolTankHealth = math.max(newEngineHealth, -2000)
        elseif newEngineHealth < 300 and newEngineHealth >= 150 then
            newEngineHealth = math.max(newEngineHealth, -2500)
            newHealthBody = math.max(newEngineHealth, -2500)
            newPetrolTankHealth = math.max(newEngineHealth, -2500)
        elseif newEngineHealth < 150 and newEngineHealth >= -4000 then
            newEngineHealth = -4000
            newHealthBody = -4000
            newPetrolTankHealth = -4000
        end

        if Config.ApplyDamageAll == true then
            SetDisableVehiclePetrolTankFires(vehicle, true)
            SetVehicleCanLeakPetrol(vehicle, true)
            if Config.ApplyDamagePetrol then
                SetVehiclePetrolTankHealth(vehicle, newPetrolTankHealth)
            end
            SetDisableVehicleEngineFires(vehicle, true)
            SetVehicleCanEngineOperateOnFire(vehicle, true)
            SetVehicleEngineHealth(vehicle, newEngineHealth)
            SetVehicleBodyHealth(vehicle, newHealthBody)
        elseif Config.ApplyDamageAll == false then
            SetDisableVehiclePetrolTankFires(vehicle, true)
            SetVehicleCanLeakPetrol(vehicle, true)
            SetDisableVehicleEngineFires(vehicle, true)
            SetVehicleCanEngineOperateOnFire(vehicle, true)
            SetVehicleEngineHealth(vehicle, newEngineHealth)
            SetVehicleBodyHealth(vehicle, 1000)
        end


        if newEngineHealth <= -4000 then
            SetVehicleEngineOn(vehicle, false, true)
            SetVehicleUndriveable(vehicle, true)
            SetVehicleEngineHealth(vehicle, -4000)
            DebugPrint('El motor ha fallado.')
        end

        DebugPrint('Salud del motor después del daño: ' .. newEngineHealth)
    end
end

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if DoesEntityExist(vehicle) and IsPedInAnyVehicle(playerPed, false) then
            checkInterval2 = 200
            local currentSpeed = GetEntitySpeed(vehicle) * 3.6
            local speedDifference = previousSpeed - currentSpeed

            local vehicleClass = GetVehicleClass(vehicle)
            local damageMultiplier = Config.damageMultiplier

            if Config.ClassDamageMultipliers[vehicleClass] then
                damageMultiplier = Config.ClassDamageMultipliers[vehicleClass].damageMultiplier
                DebugPrint("Multiplicador de daño para la clase " .. vehicleClass .. ": " .. damageMultiplier)
            else
                DebugPrint("Clase de vehículo no encontrada, usando multiplicador por defecto.")
            end

            if speedDifference > 50 then
                local damageAmount = speedDifference * damageMultiplier / 2
                DebugPrint('Daño al motor: ' .. damageAmount)
                ApplyEngineDamage(vehicle, damageAmount)
            end

            previousSpeed = currentSpeed
        end

        Citizen.Wait(checkInterval2)
    end
end)


--   ooooooooo.   ooooooooo.   oooooooooooo oooooo     oooo oooooooooooo ooooo      ooo ooooooooooooo      oooooo     oooo oooooooooooo ooooo   ooooo ooooo   .oooooo.   ooooo        oooooooooooo      oooooooooooo ooooo        ooooo ooooooooo.
--   `888   `Y88. `888   `Y88. `888'     `8  `888.     .8'  `888'     `8 `888b.     `8' 8'   888   `8       `888.     .8'  `888'     `8 `888'   `888' `888'  d8P'  `Y8b  `888'        `888'     `8      `888'     `8 `888'        `888' `888   `Y88.
--    888   .d88'  888   .d88'  888           `888.   .8'    888          8 `88b.    8       888             `888.   .8'    888          888     888   888  888           888          888               888          888          888   888   .d88'
--    888ooo88P'   888ooo88P'   888oooo8       `888. .8'     888oooo8     8   `88b.  8       888              `888. .8'     888oooo8     888ooooo888   888  888           888          888oooo8          888oooo8     888          888   888ooo88P'
--    888          888`88b.     888    "        `888.8'      888    "     8     `88b.8       888               `888.8'      888    "     888     888   888  888           888          888    "          888    "     888          888   888
--    888          888  `88b.   888       o      `888'       888       o  8       `888       888                `888'       888       o  888     888   888  `88b    ooo   888       o  888       o       888          888       o  888   888
--   o888o        o888o  o888o o888ooooood8       `8'       o888ooooood8 o8o        `8      o888o                `8'       o888ooooood8 o888o   o888o o888o  `Y8bood8P'  o888ooooood8 o888ooooood8      o888o        o888ooooood8 o888o o888o

if Config.preventVehicleFlip then
    Citizen.CreateThread(function()
        while true do
            local waitTime = 500

            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)

            if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == playerPed then
                local roll = GetEntityRoll(vehicle)

                if (roll > 75.0 or roll < -75.0) and GetEntitySpeed(vehicle) < 10 then
                    DisableControlAction(2, 59, true)
                    DisableControlAction(2, 60, true)
                    waitTime = 10
                    -- else
                    --     EnableControlAction(2, 59, true)
                    --     EnableControlAction(2, 60, true)
                end
            end

            Citizen.Wait(waitTime)
        end
    end)
end


--   oooooooooo.  ooooooooo.   oooooooooooo       .o.       oooo    oooo oooooooooo.     .oooooo.   oooooo   oooooo     oooo ooooo      ooo  .oooooo..o      oooooooooooo ooooo              .o.         .oooooo.     .oooooo..o
--   `888'   `Y8b `888   `Y88. `888'     `8      .888.      `888   .8P'  `888'   `Y8b   d8P'  `Y8b   `888.    `888.     .8'  `888b.     `8' d8P'    `Y8      `888'     `8 `888'             .888.       d8P'  `Y8b   d8P'    `Y8
--    888     888  888   .d88'  888             .8"888.      888  d8'     888      888 888      888   `888.   .8888.   .8'    8 `88b.    8  Y88bo.            888          888             .8"888.     888           Y88bo.
--    888oooo888'  888ooo88P'   888oooo8       .8' `888.     88888[       888      888 888      888    `888  .8'`888. .8'     8   `88b.  8   `"Y8888o.        888oooo8     888            .8' `888.    888            `"Y8888o.
--    888    `88b  888`88b.     888    "      .88ooo8888.    888`88b.     888      888 888      888     `888.8'  `888.8'      8     `88b.8       `"Y88b       888    "     888           .88ooo8888.   888     ooooo      `"Y88b
--    888    .88P  888  `88b.   888       o  .8'     `888.   888  `88b.   888     d88' `88b    d88'      `888'    `888'       8       `888  oo     .d8P       888          888       o  .8'     `888.  `88.    .88'  oo     .d8P
--   o888bood8P'  o888o  o888o o888ooooood8 o88o     o8888o o888o  o888o o888bood8P'    `Y8bood8P'        `8'      `8'       o8o        `8  8""88888P'       o888o        o888ooooood8 o88o     o8888o  `Y8bood8P'   8""88888P'

-- Functions to avoid possible incompatibilities with other scripts
RegisterNetEvent('realistic-vehicle:batteryDrainFlag')
AddEventHandler('realistic-vehicle:batteryDrainFlag', function(vehicle, isDraining)
    batteryDrainFlags[vehicle] = isDraining
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        for vehicle, isDraining in pairs(batteryDrainFlags) do
            if isDraining then
                local currentEngineState = GetIsVehicleEngineRunning(vehicle)
                if currentEngineState then
                    SetVehicleEngineOn(vehicle, false, true, true)
                end
            end
        end
    end
end)

-- RegisterNetEvent('realistic-vehicle:batteryDrainFlag')
-- AddEventHandler('realistic-vehicle:batteryDrainFlag', function(vehicle, isDraining)
--     batteryDrainFlags[vehicle] = isDraining
-- end)

RegisterNetEvent('realistic-vehicle:radiatorLeakFlag')
AddEventHandler('realistic-vehicle:radiatorLeakFlag', function(vehicle, hasLeak)
    radiatorLeakFlags[vehicle] = hasLeak
end)

RegisterNetEvent('realistic-vehicle:petrolLossFlag')
AddEventHandler('realistic-vehicle:petrolLossFlag', function(vehicle, hasPetrolLeak)
    petrolLossFlag[vehicle] = hasPetrolLeak
end)

RegisterNetEvent('realistic-vehicle:brakeFailureFlag')
AddEventHandler('realistic-vehicle:brakeFailureFlag', function(vehicle, hasFailure)
    brakeFailureFlags[vehicle] = hasFailure
end)

RegisterNetEvent('realistic-vehicle:suspensionDamageFlag')
AddEventHandler('realistic-vehicle:suspensionDamageFlag', function(vehicle, isDamaged)
    suspensionDamageFlags[vehicle] = isDamaged
end)

RegisterNetEvent('realistic-vehicle:alternatorFailureFlag')
AddEventHandler('realistic-vehicle:alternatorFailureFlag', function(vehicle, hasFailure)
    alternatorFailureFlags[vehicle] = hasFailure
end)

RegisterNetEvent('realistic-vehicle:transmissionFluidLeakFlag')
AddEventHandler('realistic-vehicle:transmissionFluidLeakFlag', function(vehicle, hasLeak)
    transmissionFluidLeakFlags[vehicle] = hasLeak
end)

RegisterNetEvent('realistic-vehicle:clutchFailureFlag')
AddEventHandler('realistic-vehicle:clutchFailureFlag', function(vehicle, hasFailure)
    clutchFailureFlags[vehicle] = hasFailure
end)

RegisterNetEvent('realistic-vehicle:fuelFilterCloggedFlag')
AddEventHandler('realistic-vehicle:fuelFilterCloggedFlag', function(vehicle, isClogged)
    fuelFilterCloggedFlags[vehicle] = isClogged
end)

RegisterNetEvent('realistic-vehicle:hoodLatchFailureFlag')
AddEventHandler('realistic-vehicle:hoodLatchFailureFlag', function(vehicle, hasFailure)
    hoodLatchFailureFlags[vehicle] = hasFailure
end)

Citizen.CreateThread(function()
    while true do
        local waitTime = 5000
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == playerPed then
            local hasActiveFlag = false

            -- for vehicle, isDraining in pairs(batteryDrainFlags) do
            --     if isDraining then
            --         hasActiveFlag = true
            --         local currentBattery = GetVehicleBatteryHealth(vehicle)
            --         if currentBattery > 0.0 then
            --             SetVehicleBatteryHealth(vehicle, currentBattery - 0.1)
            --         end
            --     end
            -- end

            for vehicle, hasLeak in pairs(radiatorLeakFlags) do
                if hasLeak then
                    hasActiveFlag = true
                    local currentTemp = GetVehicleEngineTemperature(vehicle)
                    if (currentTemp < 1000.0) then
                        SetVehicleEngineTemperature(vehicle, currentTemp + 5.0)
                    end
                end
            end

            for vehicle, hasFailure in pairs(brakeFailureFlags) do
                if hasFailure then
                    hasActiveFlag = true
                    SetVehicleBrake(vehicle, true)
                    SetVehicleHandbrake(vehicle, true)
                end
            end

            for vehicle, hasPetrolLeak in pairs(petrolLossFlag) do
                if hasPetrolLeak then
                    hasActiveFlag = true
                    local currentFuelLevel = GetVehicleFuelLevel(vehicle)
                    SetVehicleFuelLevel(vehicle, currentFuelLevel - 0.23)
                    SetVehicleEngineOn(vehicle, false, false, false)
                end
            end

            for vehicle, hasFailure in pairs(brakeFailureFlags) do
                if hasFailure then
                    hasActiveFlag = true
                    SetVehicleBrake(vehicle, true)
                    SetVehicleHandbrake(vehicle, true)
                end
            end

            for vehicle, isDamaged in pairs(suspensionDamageFlags) do
                if isDamaged then
                    hasActiveFlag = true
                    SetVehicleSuspensionHeight(vehicle, 0.05)
                end
            end

            for vehicle, hasFailure in pairs(alternatorFailureFlags) do
                if hasFailure then
                    hasActiveFlag = true
                    SetVehicleEngineOn(vehicle, false, true, false)
                    SetVehicleLights(vehicle, 1)
                end
            end

            for vehicle, hasLeak in pairs(transmissionFluidLeakFlags) do
                if hasLeak then
                    hasActiveFlag = true
                    SetVehicleEnginePowerMultiplier(vehicle, -50.0)
                end
            end

            for vehicle, hasFailure in pairs(clutchFailureFlags) do
                if hasFailure then
                    hasActiveFlag = true
                    SetVehicleClutch(vehicle, 0.2)
                end
            end

            for vehicle, isClogged in pairs(fuelFilterCloggedFlags) do
                if isClogged then
                    hasActiveFlag = true
                    SetVehicleFuelLevel(vehicle, 9.77)
                end
            end

            if hasActiveFlag then
                waitTime = 100
                DebugPrint('Has an Active Flag')
            end
        end

        for vehicle, hasFailure in pairs(hoodLatchFailureFlags) do
            if hasFailure then
                hasActiveFlag = true
                SetVehicleDoorOpen(vehicle, 4, false, false)
            end
        end

        Citizen.Wait(waitTime)
    end
end)


--     .oooooo.         .o.       ooooooooo.        ooooooooo.   ooooo   ooooo oooooo   oooo  .oooooo..o ooooo   .oooooo.    .oooooo..o
--    d8P'  `Y8b       .888.      `888   `Y88.      `888   `Y88. `888'   `888'  `888.   .8'  d8P'    `Y8 `888'  d8P'  `Y8b  d8P'    `Y8
--   888              .8"888.      888   .d88'       888   .d88'  888     888    `888. .8'   Y88bo.       888  888          Y88bo.
--   888             .8' `888.     888ooo88P'        888ooo88P'   888ooooo888     `888.8'     `"Y8888o.   888  888           `"Y8888o.
--   888            .88ooo8888.    888`88b.          888          888     888      `888'          `"Y88b  888  888               `"Y88b
--   `88b    ooo   .8'     `888.   888  `88b.        888          888     888       888      oo     .d8P  888  `88b    ooo  oo     .d8P
--    `Y8bood8P'  o88o     o8888o o888o  o888o      o888o        o888o   o888o     o888o     8""88888P'  o888o  `Y8bood8P'  8""88888P'

if Config.EnableCarPhysics then
    function isOnSandOrMountain()
        local playerPed = PlayerPedId()
        local veh = GetVehiclePedIsIn(playerPed, false)
        local groundHash = GetGroundHash(veh)

        DebugPrint(groundHash)

        local sandHashes = {
            1635937914, -1885547121, -1595148316, 510490462,
            -1907520769, -840911308, -356706482, -700658213,
        }

        local mountainHashes = {
            815500405, 509508168, 951832588, 1913209870, 1333033863,
            1288448767, 1336319281, -1286696947, -461750719,
            -1289542914, -730990693, -840216541, 2128369009, -1942898710
        }

        if contains(sandHashes, groundHash) then
            return "sand"
        elseif contains(mountainHashes, groundHash) then
            return "mountain"
        else
            return "road"
        end
    end

    function contains(table, element)
        for _, value in pairs(table) do
            if value == element then
                return true
            end
        end
        return false
    end

    function GetGroundHash(veh)
        local coords = GetEntityCoords(veh)
        local num = StartShapeTestCapsule(coords.x, coords.y, coords.z + 4, coords.x, coords.y, coords.z - 2.0, 1, 1, veh,
            7)
        local arg1, arg2, arg3, arg4, arg5 = GetShapeTestResultEx(num)
        return arg5
    end

    function isFourWheelDrive(vehicle)
        local vehicleClass = GetVehicleClass(vehicle)
        return vehicleClass == 8 or vehicleClass == 9 or vehicleClass == 11
    end

    function hasOffroadTires(vehicle)
        return GetVehicleWheelType(vehicle) == 4
    end

    function getGroundZAtCoords(coords)
        local _, groundZ = GetGroundZAndNormalFor_3dCoord(coords.x, coords.y, coords.z)
        if not groundZ then
            local rayHandle = StartShapeTestRay(coords.x, coords.y, coords.z + 100.0, coords.x, coords.y,
                coords.z - 100.0,
                10, 0, 7)
            local _, hit, _, _, hitZ = GetShapeTestResult(rayHandle)
            if hit then
                groundZ = hitZ
            end
        end
        return groundZ or coords.z
    end

    function simulateWheelSinking(vehicle, terrain)
        local pos = GetEntityCoords(vehicle)
        local groundZ = getGroundZAtCoords(pos)
        local baseSinkingAmount = 0.01
        local maxSinkingDepth = -0.2

        local speed = GetEntitySpeed(vehicle)
        local sinkingAmount = baseSinkingAmount + (speed * 0.02)

        if terrain == "sand" or terrain == "mountain" then
            if speed < 1 then
                local currentZ = pos.z

                if not originalZ then
                    originalZ = currentZ
                end

                local sinkingDepth = currentZ - groundZ

                if sinkingDepth > maxSinkingDepth then
                    local newZ = currentZ - sinkingAmount
                    if sinkingDepth - sinkingAmount > maxSinkingDepth then
                        FreezeEntityPosition(vehicle, true)
                        SetEntityCoordsNoOffset(vehicle, pos.x, pos.y, newZ, false, false, false, false)

                        for i = 0, 3 do
                            local wheelBone = GetEntityBoneIndexByName(vehicle, "wheel_" .. i)
                            if wheelBone ~= -1 then
                                local wheelPos = GetWorldPositionOfEntityBone(vehicle, wheelBone)
                                local wheelZ = wheelPos.z - sinkingAmount
                                SetVehicleWheelPosition(vehicle, i, wheelPos.x, wheelPos.y, wheelZ)
                            end
                        end

                        FreezeEntityPosition(vehicle, false)
                    end
                end
            end
        end
    end

    function restoreVehicleHeightIfNotSinking(vehicle, terrain)
        if terrain ~= "sand" and terrain ~= "mountain" and originalZ then
            local pos = GetEntityCoords(vehicle)
            SetEntityCoordsNoOffset(vehicle, pos.x, pos.y, originalZ, false, false, false, false)
            originalZ = nil
        end
    end

    function applyTerrainEffects(vehicle, terrain)
        if Config.CarSinking then
            simulateWheelSinking(vehicle, terrain)
            restoreVehicleHeightIfNotSinking(vehicle, terrain)
        end
        applyGripAndSlideEffects(vehicle, terrain)
    end

    function applyGripAndSlideEffects(vehicle, terrain)
        local driveType = isFourWheelDrive(vehicle)
        local hasOffroadTyres = hasOffroadTires(vehicle)
        local isEmergency = isEmergencyVehicle(vehicle)
        local tractionBonus = isEmergency and Config.TractionBonus or 0
        DebugPrint(isEmergency)
        DebugPrint(hasOffroadTyres)
        DebugPrint(driveType)

        if vehicle ~= lastVehicle then
            originalTractionCurveMin = nil
            originalTractionLossMult = nil
            originalLowSpeedTractionLossMult = nil
            lastVehicle = vehicle
        end

        if originalTractionCurveMin == nil or originalTractionLossMult == nil or originalLowSpeedTractionLossMult == nil then
            originalTractionCurveMin = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMin")
            originalTractionLossMult = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionLossMult")
            originalLowSpeedTractionLossMult = GetVehicleHandlingFloat(vehicle, "CHandlingData",
                "fLowSpeedTractionLossMult")
        end

        if terrain == "sand" then
            if not driveType then
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", 1.5 - tractionBonus)
            else
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", 1.0 - tractionBonus)
            end

            if not hasOffroadTyres then
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionLossMult", 2.0 - tractionBonus)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMin", 0.8 + tractionBonus)
            else
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionLossMult", 0.8 - tractionBonus)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMin", 1.2 + tractionBonus)
            end
        elseif terrain == "mountain" then
            if not driveType then
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", 1.5 - tractionBonus)
            else
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", 1.0 - tractionBonus)
            end

            if not hasOffroadTyres then
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionLossMult", 1.8 - tractionBonus)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMin", 0.7 + tractionBonus)
            else
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionLossMult", 1.0 - tractionBonus)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMin", 1.1 + tractionBonus)
            end
        else
            if hasOffroadTyres then
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionLossMult", 1.2 - tractionBonus)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMin", 0.8 + tractionBonus)
            else
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionLossMult",
                    originalTractionLossMult - tractionBonus)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMin",
                    originalTractionCurveMin + tractionBonus)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fLowSpeedTractionLossMult",
                    originalLowSpeedTractionLossMult - tractionBonus)
            end
        end
    end

    function isEmergencyVehicle(vehicle)
        local emergencyClasses = {
            [18] = true
        }

        local vehicleClass = GetVehicleClass(vehicle)
        return emergencyClasses[vehicleClass] ~= nil
    end

    function limitSpeed(vehicle, terrain)
        local maxSpeedKmH = Config.MaxSpeed
        local maxSpeedMs = maxSpeedKmH / 3.6
        local currentSpeedMs = GetEntitySpeed(vehicle)

        DebugPrint("Current Speed: " .. currentSpeedMs .. " m/s")
        DebugPrint("Max Speed: " .. maxSpeedMs .. " m/s")
        DebugPrint("Speed Limit Active: " .. tostring(speedLimitActive))

        if terrain == "sand" or terrain == "mountain" then
            if currentSpeedMs > maxSpeedMs then
                local speedDifference = currentSpeedMs - maxSpeedMs
                local reductionFactor = Config.reductionFactor

                if not speedLimitActive then
                    speedLimitActive = true

                    Citizen.CreateThread(function()
                        while true do
                            currentSpeedMs = GetEntitySpeed(vehicle)
                            local newSpeedMs = currentSpeedMs - (speedDifference * reductionFactor)

                            if currentSpeedMs > maxSpeedMs and speedLimitActive then
                                SetVehicleCheatPowerIncrease(vehicle, -100.0)
                                SetVehicleBrake(vehicle, true)
                                SetVehicleCurrentRpm(vehicle, 0.0)
                            else
                                if currentSpeedMs - newSpeedMs < 1 then
                                    SetEntityMaxSpeed(vehicle, maxSpeedMs)
                                    speedLimitActive = true
                                    break
                                end
                            end
                            Wait(0)
                        end
                    end)
                end
            end
        else
            local maxSpeedOriginal = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel")
            SetEntityMaxSpeed(vehicle, maxSpeedOriginal)
            if speedLimitActive then
                speedLimitActive = false
                SetVehicleCheatPowerIncrease(vehicle, 1.0)
                SetVehicleBrake(vehicle, false)
                SetVehicleCurrentRpm(vehicle, 1.0)
            end
        end
    end

    function isNormalCar(vehicleClass)
        local normalVehicleClasses = {
            [0] = true, -- Compacts
            [1] = true, -- Sedans
            [2] = true, -- SUVs
            [3] = true, -- Coupes
            [4] = true, -- Muscle
            [5] = true, -- Classic Sports Cars
            [6] = true, -- Sports Cars
            [7] = true  -- Supercars
        }

        return normalVehicleClasses[vehicleClass] ~= nil
    end

    local defaultConfig = { BrakeTemperaturaGain = 20, MaxBrakeTemp = 600, CoolingRate = 1.5 }

    function PlaySound(soundFile, soundVolume)
        SendNUIMessage({
            transactionType = 'playSound',
            transactionFile = soundFile,
            transactionVolume = soundVolume
        })
    end

    local function manageBrakeTemperature()
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if vehicle ~= lastVehicle2 then
            originalBrakeForce = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeForce")
            originalHandbrakeForce = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fHandBrakeForce")
            DebugPrint(originalBrakeForce, originalHandbrakeForce)

            local vehicleClass = GetVehicleClass(vehicle)
            DebugPrint(vehicleClass)
            local config = Config.ClassConfigs[vehicleClass] or defaultConfig

            brakeTemperaturaGain = config.BrakeTemperaturaGain
            maxBrakeTemperature = config.MaxBrakeTemp
            coolingRate = config.CoolingRate

            lastVehicle2 = vehicle
            brakeTemperature = 0
        end

        if brakeTemperature < 0 then
            brakeTemperature = 0
        end

        local speed = GetEntitySpeed(vehicle) * 3.6
        DebugPrint("Temperatura del freno: " .. brakeTemperature)

        local wheelNumber = GetVehicleNumberOfWheels(vehicle)
        local allWheelsInAir = true

        for i = 0, wheelNumber - 1 do
            local wheelSpeed = GetVehicleWheelSpeed(vehicle, i)
            local wheelSpeedInKM = wheelSpeed * 3.6

            if wheelSpeedInKM > 1 or wheelSpeedInKM < -1 then
                allWheelsInAir = false
                break
            end
        end

        local isInWater = false
        for i = 0, wheelNumber - 1 do
            local wheelPos = GetEntityCoords(vehicle, false)
            if GetWaterHeight(wheelPos.x, wheelPos.y, wheelPos.z - 0.5) then
                isInWater = true
                break
            end
        end
        DebugPrint('Is in water? ' .. tostring(isInWater))

        if brakeTemperature >= 0.80 * maxBrakeTemperature then
            SendNUIMessage({
                type = "showWarning",
            })

            if Config.PlayWarningSound then
                PlaySound("alert", 1.0)
            end
        else
            SendNUIMessage({
                type = "hideWarning",
            })
        end

        if not allWheelsInAir then
            if speed > 5 then
                local totalBrakePressure = 0
                local validWheels = 0

                for i = 0, wheelNumber - 1 do
                    local brakePressure = GetVehicleWheelBrakePressure(vehicle, i)

                    if brakePressure > 0.1 then
                        totalBrakePressure = totalBrakePressure + brakePressure
                        validWheels = validWheels + 1
                    end
                end


                if validWheels > 0 then
                    local averageBrakePressure = totalBrakePressure / validWheels
                    DebugPrint("Presión promedio de frenos: " .. averageBrakePressure)

                    if averageBrakePressure > 0.1 then
                        brakeTemperature = brakeTemperature + brakeTemperaturaGain
                    end
                end
    
                local brakeReductionFactor = Config.brakeReductionFactor * 2
    
                if brakeTemperature >= maxBrakeTemperature then
                    brakeReductionFactor = 0.0
                elseif brakeTemperature > 0 then
                    brakeReductionFactor = Config.brakeReductionFactor * 2 - (brakeTemperature / maxBrakeTemperature)
                end
    
                local adjustedBrakeForce = originalBrakeForce * brakeReductionFactor
                local adjustedHandbrakeForce = originalHandbrakeForce * brakeReductionFactor
    
                if brakeTemperature >= maxBrakeTemperature then
                    isBrakeOverheated = true
                    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeForce", 0.0)
                    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fHandBrakeForce", 0.0)
                    SetVehicleBrakeLights(vehicle, false)
                    brakeTemperature = brakeTemperature - (isInWater and coolingRate * 20 or coolingRate)
                else
                    if isBrakeOverheated then
                        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeForce", originalBrakeForce)
                        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fHandBrakeForce", originalHandbrakeForce)
                        brakeTemperature = brakeTemperature - (isInWater and coolingRate * 20 or coolingRate)
                        isBrakeOverheated = false
                    end

                    if brakeTemperature > 0 and brakeTemperature < maxBrakeTemperature then
                        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeForce", adjustedBrakeForce)
                        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fHandBrakeForce", adjustedHandbrakeForce)
                        isBrakeOverheated = false
                        brakeTemperature = brakeTemperature - (isInWater and coolingRate * 20 or coolingRate)
                    end
                end
            else
                if brakeTemperature > 0 and brakeTemperature < maxBrakeTemperature then
                    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeForce", originalBrakeForce)
                    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fHandBrakeForce", originalHandbrakeForce)
                    isBrakeOverheated = false
                    brakeTemperature = brakeTemperature - (isInWater and coolingRate * 20 or coolingRate)
                end
            end
        else
            if brakeTemperature > 0 then
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeForce", originalBrakeForce)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fHandBrakeForce", originalHandbrakeForce)
                brakeTemperature = brakeTemperature - (isInWater and coolingRate * 20 or coolingRate)
            end
        end
    end


    Citizen.CreateThread(function()
        while true do
            local timeout = Config.CarPhysicsTimeout
            local playerPed = PlayerPedId()
            local veh = GetVehiclePedIsIn(playerPed, false)
            if veh ~= 0 then
                timeout = 500
                local terrain = isOnSandOrMountain()

                local vehicleClass = GetVehicleClass(veh)
                local hasOffroadTyres = hasOffroadTires(veh)

                -- if isNormalCar(vehicleClass) and not hasOffroadTyres or isEmergencyVehicle and not hasOffroadTyres then
                --     limitSpeed(veh, terrain)
                -- end
                if isNormalCar(vehicleClass) or isEmergencyVehicle and not hasOffroadTyres then
                    limitSpeed(veh, terrain)
                end

                manageBrakeTemperature()
            else
                SendNUIMessage({
                    type = "hideWarning",
                })        
            end

            Citizen.Wait(timeout)
        end
    end)

    Citizen.CreateThread(function()
        while true do
            local timeout = Config.CarPhysicsTimeout
            local playerPed = PlayerPedId()
            local veh = GetVehiclePedIsIn(playerPed, false)

            if veh ~= 0 then
                timeout = 500
                local terrain = isOnSandOrMountain()
                DebugPrint(terrain)
                applyTerrainEffects(veh, terrain)

                local vehicleClass = GetVehicleClass(veh)
                local hasOffroadTyres = hasOffroadTires(veh)

                if isNormalCar(vehicleClass) and not hasOffroadTyres then
                    limitSpeed(veh, terrain)
                end

                -- if terrain == "sand" or terrain == "mountain" then
                --     local multiplier = getTerrainEffectMultiplier(vehicleClass, terrain, hasOffroadTyres)
                --     SetVehicleEngineTorqueMultiplier(veh, multiplier)
                -- else
                --     SetVehicleEngineTorqueMultiplier(veh, 1.0)
                -- end
            end

            Citizen.Wait(timeout)
        end
    end)

    function getTerrainEffectMultiplier(vehicleClass, terrain, hasOffroadTyres)
        local multiplier = 1.0

        if terrain == "sand" then
            if vehicleClass == 8 or vehicleClass == 9 then
                multiplier = hasOffroadTyres and 0.9 or 0.7
            elseif vehicleClass == 11 then
                multiplier = hasOffroadTyres and 0.8 or 0.6
            else
                multiplier = hasOffroadTyres and 0.5 or 0.3
            end
        elseif terrain == "mountain" then
            if vehicleClass == 8 or vehicleClass == 9 then
                multiplier = hasOffroadTyres and 0.9 or 0.8
            elseif vehicleClass == 11 then
                multiplier = hasOffroadTyres and 0.8 or 0.7
            else
                multiplier = hasOffroadTyres and 0.6 or 0.4
            end
        end

        return multiplier
    end
end
