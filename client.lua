ESX = exports['es_extended']:getSharedObject()

local vehicleKilometers = {}
local vehicleCooldown = {}
local engineFailureFlags = {}
local engineRestored = {}
local batteryDrainFlags = {}
local radiatorLeakFlags = {}
local brakeFailureFlags = {}
local suspensionDamageFlags = {}
local alternatorFailureFlags = {}
local transmissionFluidLeakFlags = {}
local clutchFailureFlags = {}
local fuelFilterCloggedFlags = {}
local vehicleBatteryHealth = {}
local vehicleTransmissionHealth = {}


function DebugPrint(...)
    if Config.DebugMode then
        print(...)
    end
end

-- Function to calculate the distance between two points
local function calculateDistance(coords1, coords2)
    return #(coords1 - coords2)
end

-- Function to load the kilometers of a vehicle from the database
local function loadKilometers(plate)
    if Config.UseExternalMileageSystem then
        -- Trigger a server-side event to get the mileage from the database
        ESX.TriggerServerCallback('realistic-vehicle:fetchKilometersFromDB', function(km)
            if km then
                DebugPrint(km)
                vehicleKilometers[plate] = { km = km }
            else
                vehicleKilometers[plate] = { km = 0 }
            end
        end, plate)
    else
        ESX.TriggerServerCallback('realistic-vehicle:fetchKilometers', function(km)
            if km then
                DebugPrint(km)
                vehicleKilometers[plate] = { km = km }
            else
                vehicleKilometers[plate] = { km = 0 }
            end
        end, plate)
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

-- Main thread to update kilometers and handle breakdowns
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.CheckInterval)

        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if vehicle ~= 0 then
            local plate = GetVehicleNumberPlateText(vehicle)
            local currentCoords = GetEntityCoords(playerPed)

            if isVehicleExcluded(plate) or isVehicleExcludedPrefix(plate) then
                DebugPrint('Vehiculo excluido')
                goto continueLoop
            end

            if vehicleKilometers[plate] == nil then
                loadKilometers(plate)
            else
                if Config.UseExternalMileageSystem then
                    ESX.TriggerServerCallback('realistic-vehicle:fetchKilometersFromDB', function(km)
                        if km then
                            DebugPrint(km)
                            vehicleKilometers[plate] = { km = km }
                            vehicleKilometers[plate].km = km
                        else
                            vehicleKilometers[plate] = { km = 0 }
                        end
                    end, plate)
                    DebugPrint(vehicleKilometers[plate].km)
                else
                    local oldCoords = vehicleKilometers[plate].coords or currentCoords
                    local distance = calculateDistance(oldCoords, currentCoords) / 1000

                    vehicleKilometers[plate].km = vehicleKilometers[plate].km + distance
                    vehicleKilometers[plate].coords = currentCoords
                end

                local km = vehicleKilometers[plate].km
                local breakdownChance = math.min((km / 1000) * Config.BaseBreakdownChance, Config.MaxBreakdownChance)
                local currentTime = GetGameTimer()
                local lastBreakdownTime = vehicleCooldown[plate] or 0

                if currentTime - lastBreakdownTime >= Config.BreakdownCooldown then
                    if math.random() < breakdownChance then
                        TriggerEvent('realistic-vehicle:breakdown', vehicle)
                        vehicleCooldown[plate] = currentTime
                    end
                end

                if not Config.UseExternalMileageSystem then
                    TriggerServerEvent('realistic-vehicle:updateKilometers', plate, vehicleKilometers[plate].km)
                    DebugPrint('Guardando kilometros en la DataBase')
                end
            end
        end
        ::continueLoop::
    end
end)

RegisterNetEvent('realistic-vehicle:breakdown')
AddEventHandler('realistic-vehicle:breakdown', function(vehicle)
    local rand = math.random()
    local cumulativeChance = 0

    for _, breakdown in ipairs(Config.BreakdownTypes) do
        cumulativeChance = cumulativeChance + breakdown.chance
        if rand <= cumulativeChance then
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
end

RegisterNetEvent('realistic-vehicle:triggerTestBreakdown')
AddEventHandler('realistic-vehicle:triggerTestBreakdown', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle ~= 0 then
        local rand = math.random()
        local cumulativeChance = 0

        for _, breakdown in ipairs(Config.BreakdownTypes) do
            cumulativeChance = cumulativeChance + breakdown.chance
            if rand <= cumulativeChance then
                breakdown.action(vehicle)
                break
            end
        end
    else
        ESX.ShowNotification("No estás en un vehículo.")
    end
end)

-- Function to avoid possible incompatibilities with other scripts that modify the health of the engine
RegisterNetEvent('realistic-vehicle:engineFailureFlag')
AddEventHandler('realistic-vehicle:engineFailureFlag', function(vehicle, isFailing)
    engineFailureFlags[vehicle] = isFailing
    if not isFailing then
        engineRestored[vehicle] = true
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        for vehicle, isFailing in pairs(engineFailureFlags) do
            if isFailing then
                local currentHealth = GetVehicleEngineHealth(vehicle)
                if currentHealth > 0.0 then
                    SetVehicleEngineHealth(vehicle, 0.0)
                end
            elseif not engineRestored[vehicle] then
                local currentHealth = GetVehicleEngineHealth(vehicle)
                if currentHealth < 1000.0 then
                    SetVehicleEngineHealth(vehicle, 1000.0)
                end
                engineRestored[vehicle] = true
            end
        end
    end
end)

local damageMultiplier = Config.damageMultiplier
local checkInterval2 = Config.CheckIntervalEngineDamage
local previousSpeed = 0

function ApplyEngineDamage(vehicle, damageAmount)
    if DoesEntityExist(vehicle) then
        local engineHealth = GetVehicleEngineHealth(vehicle)
        DebugPrint('Salud del motor antes del daño: ' .. engineHealth)
        DebugPrint('Cantidad de daño: ' .. damageAmount)
        
        if engineHealth ~= engineHealth then
            DebugPrint("Error: engineHealth es NaN")
            return 
        end

        local newEngineHealth = engineHealth - damageAmount

        if newEngineHealth < 950 and newEngineHealth >= 800 then
            newEngineHealth = math.max(newEngineHealth, -250)
        elseif newEngineHealth < 800 and newEngineHealth >= 500 then
            newEngineHealth = math.max(newEngineHealth, -500)
        elseif newEngineHealth < 500 and newEngineHealth >= 0 then
            newEngineHealth = math.max(newEngineHealth, -2000)
        elseif newEngineHealth < -4000 then
            newEngineHealth = -4000
        end

        SetVehicleEngineHealth(vehicle, newEngineHealth)
        
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

-- Citizen.CreateThread(function()
--     local Coords = vector3(313.8258, -242.9530, 54.0678)
--     local isTextVisible = false

--     while true do
--         Citizen.Wait(1000)
--         local playerCoords = GetEntityCoords(PlayerPedId())
--         local distance = #(playerCoords - Coords)

--         if distance < 3.0 then 
--             if not isTextVisible then
--                 lib.showTextUI('Pulsa E para abrir')
--                 isTextVisible = true
--             end

--             if IsControlPressed(0, 38) then
--                 TriggerServerEvent('realistic-vehicle:registerStash')
--                 lib.hideTextUI()
--                 isTextVisible = false  
--             end
--         elseif isTextVisible then
--             lib.hideTextUI()
--             isTextVisible = false  
--         end
--     end
-- end)


-- RegisterNetEvent('realistic-vehicle:openStash', function(stashLabel, stashId)
--     exports.ox_inventory:openInventory(stashLabel, stashId)
-- end)

if Config.preventVehicleFlip then
    Citizen.CreateThread(function()
        while true do
            local waitTime = 500
            
            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            
            if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == playerPed then
                local roll = GetEntityRoll(vehicle)
                if (roll > 75.0 or roll < -75.0) and GetEntitySpeed(vehicle) < 2 then
                    DisableControlAction(2, 59, true)
                    DisableControlAction(2, 60, true)
                    waitTime = 10
                end
            end
            Citizen.Wait(waitTime)
        end
    end)
end

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

Citizen.CreateThread(function()
    while true do
        local waitTime = 5000
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == playerPed then
            waitTime = 100

            -- for vehicle, isDraining in pairs(batteryDrainFlags) do
            --     if isDraining then
            --         local currentBattery = GetVehicleBatteryHealth(vehicle)
            --         if currentBattery > 0.0 then
            --             SetVehicleBatteryHealth(vehicle, currentBattery - 0.1)
            --         end
            --     end
            -- end

            for vehicle, hasLeak in pairs(radiatorLeakFlags) do
                if hasLeak then
                    local currentTemp = GetVehicleEngineTemperature(vehicle)
                    if currentTemp < 1000.0 then
                        SetVehicleEngineTemperature(vehicle, currentTemp + 5.0)
                    end
                end
            end

            for vehicle, hasFailure in pairs(brakeFailureFlags) do
                if hasFailure then
                    SetVehicleBrake(vehicle, true)
                    SetVehicleHandbrake(vehicle, true)
                end
            end

            for vehicle, isDamaged in pairs(suspensionDamageFlags) do
                if isDamaged then
                    SetVehicleSuspensionHeight(vehicle, 0.05)
                end
            end

            for vehicle, hasFailure in pairs(alternatorFailureFlags) do
                if hasFailure then
                    SetVehicleEngineOn(vehicle, false, true, false)
                    SetVehicleLights(vehicle, 1)            
                end
            end

            for vehicle, hasLeak in pairs(transmissionFluidLeakFlags) do
                if hasLeak then
                    SetVehicleEnginePowerMultiplier(vehicle, -50.0)
                end
            end

            for vehicle, hasFailure in pairs(clutchFailureFlags) do
                if hasFailure then
                    SetVehicleClutch(vehicle, 0.2)
                end
            end

            for vehicle, isClogged in pairs(fuelFilterCloggedFlags) do
                DebugPrint(isClogged)
                if isClogged then
                    SetVehicleFuelLevel(vehicle, 9.77)
                    DebugPrint('Obstruido')
                end
            end
        end
        Citizen.Wait(waitTime)
    end
end)