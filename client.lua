ESX = exports['es_extended']:getSharedObject()

local vehicleKilometers = {}
local vehicleCooldown = {}

-- Function to calculate the distance between two points
local function calculateDistance(coords1, coords2)
    return #(coords1 - coords2)
end

-- Function to load the kilometers of a vehicle from the database
local function loadKilometers(plate)
    ESX.TriggerServerCallback('custom:fetchKilometers', function(km)
        if km then
            vehicleKilometers[plate] = { km = km }
        else
            vehicleKilometers[plate] = { km = 0 }
        end
    end, plate)
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

            if vehicleKilometers[plate] == nil then
                loadKilometers(plate)
            else
                local oldCoords = vehicleKilometers[plate].coords or currentCoords
                local distance = calculateDistance(oldCoords, currentCoords) / 1000

                vehicleKilometers[plate].km = vehicleKilometers[plate].km + distance
                vehicleKilometers[plate].coords = currentCoords

                local km = vehicleKilometers[plate].km
                local breakdownChance = math.min((km / 1000) * Config.BaseBreakdownChance, Config.MaxBreakdownChance)
                local currentTime = GetGameTimer()
                local lastBreakdownTime = vehicleCooldown[plate] or 0

                if currentTime - lastBreakdownTime >= Config.BreakdownCooldown then
                    if math.random() < breakdownChance then
                        TriggerEvent('custom:breakdown', vehicle)
                        vehicleCooldown[plate] = currentTime
                    end
                end
                TriggerServerEvent('custom:updateKilometers', plate, vehicleKilometers[plate].km)
            end
        end
    end
end)

RegisterNetEvent('custom:breakdown')
AddEventHandler('custom:breakdown', function(vehicle)
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
        TriggerServerEvent('custom:testBreakdown')
    end, false)
end

RegisterNetEvent('custom:triggerTestBreakdown')
AddEventHandler('custom:triggerTestBreakdown', function()
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
