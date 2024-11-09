if Config.FrameWork == "esx" then
    ESX = exports['es_extended']:getSharedObject()
    ESX.VehiclesTable = "owned_vehicles"
elseif Config.FrameWork == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
    QBCore.VehiclesTable = "player_vehicles"
end

if Config.FrameWork == "esx" then
    ESX.RegisterServerCallback('realistic-vehicle:fetchKilometers', function(source, cb, plate)
        MySQL.Async.fetchScalar('SELECT kilometers FROM vehicle_kilometers WHERE plate = @plate', {
            ['@plate'] = plate
        }, function(kilometers)
            cb(kilometers)
        end)
    end)

    ESX.RegisterServerCallback('realistic-vehicle:fetchKilometersFromDB', function(source, cb, plate)
        MySQL.Async.fetchScalar('SELECT adv_stats FROM owned_vehicles WHERE plate = @plate', {
            ['@plate'] = plate
        }, function(adv_stats)
            if adv_stats then
                local stats = json.decode(adv_stats)
                if stats and stats.mileage then
                    cb(stats.mileage)
                else
                    cb(0)
                end
            else
                cb(0)
            end
        end)
    end)
elseif Config.FrameWork == "qb" then
    QBCore.Functions.CreateCallback('realistic-vehicle:fetchKilometers', function(source, cb, plate)
        MySQL.Async.fetchScalar('SELECT kilometers FROM vehicle_kilometers WHERE plate = @plate', {
            ['@plate'] = plate
        }, function(kilometers)
            cb(kilometers)
        end)
    end)

    QBCore.Functions.CreateCallback('realistic-vehicle:fetchKilometersFromDB', function(source, cb, plate)
        MySQL.Async.fetchScalar('SELECT adv_stats FROM owned_vehicles WHERE plate = @plate', {
            ['@plate'] = plate
        }, function(adv_stats)
            if adv_stats then
                local stats = json.decode(adv_stats)
                if stats and stats.mileage then
                    cb(stats.mileage)
                else
                    cb(0)
                end
            else
                cb(0)
            end
        end)
    end)
end

RegisterServerEvent('realistic-vehicle:updateKilometers')
AddEventHandler('realistic-vehicle:updateKilometers', function(plate, kilometers)
    MySQL.Async.execute(
        'INSERT INTO vehicle_kilometers (plate, kilometers) VALUES (@plate, @kilometers) ON DUPLICATE KEY UPDATE kilometers = @kilometers',
        {
            ['@plate'] = plate,
            ['@kilometers'] = kilometers
        })
end)

lib.callback.register("realistic-vehicle:get-mileage-JG", function(_, plate)
    local distance, unit = exports["jg-vehiclemileage"]:GetMileage(plate)
    return { mileage = distance, unit = unit }
end)

lib.callback.register("realistic-vehicle:isVehOwned", function(_, plate)
    local isOwned = false

    if Config.FrameWork == "esx" then
        local result = MySQL.Sync.fetchAll("SELECT * FROM " .. ESX.VehiclesTable .. " WHERE plate = @plate", {
            ['@plate'] = plate
        })
        
        isOwned = #result > 0

    elseif Config.FrameWork == "qb" then
        local result = MySQL.Sync.fetchAll("SELECT * FROM " .. QBCore.VehiclesTable .. " WHERE plate = @plate", {
            ['@plate'] = plate
        })

        isOwned = #result > 0
    end

    return isOwned
end)

if Config.DebugMode then
    RegisterServerEvent('realistic-vehicle:testBreakdown')
    AddEventHandler('realistic-vehicle:testBreakdown', function()
        local xPlayer = ESX.GetPlayerFromId(source)

        if xPlayer and xPlayer.getGroup() == 'admin' then
            TriggerClientEvent('realistic-vehicle:triggerTestBreakdown', source)
        else
            print(('%s intentó usar /testbreakdown sin permisos'):format(GetPlayerIdentifiers(source)[1]))
        end
    end)
end

RegisterNetEvent('vehicle:damageStatus')
AddEventHandler('vehicle:damageStatus', function()
    TriggerClientEvent('chat:addMessage', source, {
        args = { 'Sistema de Daño', 'El motor ha recibido ' .. engineDamage .. ' puntos de daño.' }
    })
end)