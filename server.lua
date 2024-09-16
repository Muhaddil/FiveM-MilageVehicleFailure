ESX = exports['es_extended']:getSharedObject()

local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')
local resourceName = 'Muhaddil/FiveM-MilageVehicleFailure'
local githubApiUrl = 'https://api.github.com/repos/' .. resourceName .. '/releases/latest'

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

if Config.AutoRunSQL then
    if not pcall(function()
      local fileName = "ESX.sql"
      local file = assert(io.open(GetResourcePath(GetCurrentResourceName()) .. "/" .. fileName, "rb"))
      local sql = file:read("*all")
      file:close()

      MySQL.query.await(sql)
    end) then
      print("^1[SQL ERROR] There was an error while automatically running the required SQL. Don't worry, you just need to run the SQL file. If you've already ran the SQL code previously, and this error is annoying you, set Config.AutoRunSQL = false^0")
    end
  end

if Config.AutoVersionChecker then
    PerformHttpRequest(githubApiUrl, function(statusCode, response, headers)
        if statusCode == 200 then
            local data = json.decode(response)

            if data and data.tag_name then
                local latestVersion = data.tag_name

                if latestVersion ~= currentVersion then
                    print('[FiveM-MilageVehicleFailure] A new version is available: ' .. latestVersion)
                    print('[FiveM-MilageVehicleFailure] Your version: ' .. currentVersion)
                    print('[FiveM-MilageVehicleFailure] Download the latest version here: ' .. data.html_url)
                else
                    print('[FiveM-MilageVehicleFailure] You are using the latest version: ' .. currentVersion)
                end
            else
                print('[FiveM-MilageVehicleFailure] Error: The JSON structure is not as expected.')
                print('[FiveM-MilageVehicleFailure] GitHub API Response: ' .. response)
            end
        else
            print('[FiveM-MilageVehicleFailure] Failed to check for latest version. Status code: ' ..
            statusCode)
        end
    end, 'GET')
end
