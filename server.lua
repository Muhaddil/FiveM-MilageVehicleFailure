ESX = exports['es_extended']:getSharedObject()

ESX.RegisterServerCallback('custom:fetchKilometers', function(source, cb, plate)
    MySQL.Async.fetchScalar('SELECT kilometers FROM vehicle_kilometers WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(kilometers)
        cb(kilometers)
    end)
end)

RegisterServerEvent('custom:updateKilometers')
AddEventHandler('custom:updateKilometers', function(plate, kilometers)
    MySQL.Async.execute('INSERT INTO vehicle_kilometers (plate, kilometers) VALUES (@plate, @kilometers) ON DUPLICATE KEY UPDATE kilometers = @kilometers', {
        ['@plate'] = plate,
        ['@kilometers'] = kilometers
    })
end)

if Config.DebugMode then
    RegisterServerEvent('custom:testBreakdown')
    AddEventHandler('custom:testBreakdown', function()
        local xPlayer = ESX.GetPlayerFromId(source)
        
        if xPlayer and xPlayer.getGroup() == 'admin' then
            TriggerClientEvent('custom:triggerTestBreakdown', source)
        else
            print(('custom: %s intentó usar /testbreakdown sin permisos'):format(GetPlayerIdentifiers(source)[1]))
        end
    end)
end