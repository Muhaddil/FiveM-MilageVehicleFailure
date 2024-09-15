ESX = exports['es_extended']:getSharedObject()

ESX.RegisterServerCallback('realistic-vehicle:fetchKilometers', function(source, cb, plate)
    MySQL.Async.fetchScalar('SELECT kilometers FROM vehicle_kilometers WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(kilometers)
        cb(kilometers)
    end)
end)

RegisterServerEvent('realistic-vehicle:updateKilometers')
AddEventHandler('realistic-vehicle:updateKilometers', function(plate, kilometers)
    MySQL.Async.execute(
        'INSERT INTO vehicle_kilometers (plate, kilometers) VALUES (@plate, @kilometers) ON DUPLICATE KEY UPDATE kilometers = @kilometers',
        {
            ['@plate'] = plate,
            ['@kilometers'] = kilometers
        })
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

RegisterNetEvent('vehicle:damageStatus')
AddEventHandler('vehicle:damageStatus', function()
    TriggerClientEvent('chat:addMessage', source, {
        args = { 'Sistema de Daño', 'El motor ha recibido ' .. engineDamage .. ' puntos de daño.' }
    })
end)

-- RegisterNetEvent('realistic-vehicle:registerStash', function()
--     local incautaciones = exports.ox_inventory:CreateTemporaryStash({
--         label = "Incautaciones",
--         slots = 50,
--         maxWeight = 5000000,
--         groups = { ['police'] = 0 },
--     })

--     TriggerClientEvent('realistic-vehicle:openStash', source, 'Evidencias', incautaciones)
-- end)
