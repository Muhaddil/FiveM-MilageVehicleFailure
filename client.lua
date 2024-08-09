ESX = exports['es_extended']:getSharedObject()

local vehicleKilometers = {}
local vehicleCooldown = {}
local engineFailureFlags = {}
local engineRestored = {}

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

local damageMultiplier = 7.0
local checkInterval2 = 200
local previousSpeed = 0

function ApplyEngineDamage(vehicle, damageAmount)
    if DoesEntityExist(vehicle) then
        local engineHealth = GetVehicleEngineHealth(vehicle)
        DebugPrint('Salud del motor antes del daño: ' .. engineHealth)
        
        local newEngineHealth = engineHealth - damageAmount
        
        if newEngineHealth < 0 then
            newEngineHealth = 0.0
        end

        SetVehicleEngineHealth(vehicle, newEngineHealth)
        
        if newEngineHealth == 0 then
            SetVehicleEngineOn(vehicle, false, true)
            SetVehicleUndriveable(vehicle, true)
            SetVehicleEngineHealth(vehicle, 0.0)
            DebugPrint('El motor ha fallado.')
        end

        DebugPrint('Salud del motor después del daño: ' .. newEngineHealth)
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(checkInterval2)
        
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        
        if DoesEntityExist(vehicle) and IsPedInAnyVehicle(playerPed, false) then
            local currentSpeed = GetEntitySpeed(vehicle) * 3.6
            local speedDifference = previousSpeed - currentSpeed
            
            if speedDifference > 50 then
                local damageAmount = speedDifference * damageMultiplier / 2
                DebugPrint('Daño al motor: ' .. damageAmount)
                ApplyEngineDamage(vehicle, damageAmount)
            end
            
            previousSpeed = currentSpeed
        end
    end
end)
