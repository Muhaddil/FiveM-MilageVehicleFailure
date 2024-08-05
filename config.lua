Config = {}

-- Debugging mode
Config.DebugMode = true
Config.ShowNotifications = true

-- Optimal configuration for debugging
-- Config.CheckInterval = 1000 
-- Config.BaseBreakdownChance = 0.1 
-- Config.MaxBreakdownChance = 1.0

Config.CheckInterval = 10000 
Config.BaseBreakdownChance = 0.01 --Base failure probability per 1000 km
Config.MaxBreakdownChance = 0.5 -- Maximum probability of failure
Config.BreakdownCooldown = 10800000  -- Cooldown in milliseconds (e.g. 10800000 ms = 3 hours)

-- Types of breakdowns
Config.BreakdownTypes = {
    {
        name = "MotorFailure",
        chance = 0.2,
        duration = 30000,
        action = function(vehicle)
            SetVehicleEngineOn(vehicle, false, true, true)
            SetVehicleEngineHealth(vehicle, 00.0) 
            if Config.ShowNotifications then
            ESX.ShowNotification("¡El motor de tu vehículo se ha calentado!")
            end
            Citizen.Wait(Config.BreakdownTypes[1].duration)
            Citizen.SetTimeout(Config.BreakdownTypes[1].duration, function()
                SetVehicleEngineHealth(vehicle, 1000.0) 
                SetVehicleEngineOn(vehicle, true, true, true)
                if Config.ShowNotifications then
                ESX.ShowNotification("El motor de tu vehículo se ha enfriado.")
                end
            end)
        end
    },
    {
        name = "TyreBurst",
        chance = 0.2,
        action = function(vehicle)
            if GetVehicleTyresCanBurst(vehicle) == false then return end
            local numWheels = GetVehicleNumberOfWheels(vehicle)
            local affectedTire
            if numWheels == 2 then
                affectedTire = (math.random(2)-1)*4
            elseif numWheels == 4 then
                affectedTire = (math.random(4)-1)
                if affectedTire > 1 then affectedTire = affectedTire + 2 end
            elseif numWheels == 6 then
                affectedTire = (math.random(6)-1)
            else
                affectedTire = 0
            end
            SetVehicleTyreBurst(vehicle, affectedTire, true, 1000.0)
            if Config.ShowNotifications then
            ESX.ShowNotification("¡Uno de los neumáticos de tu vehículo ha reventado!")
            end
        end
    },
    {
        name = "PowerLoss",
        chance = 0.2,
        duration = 20000,
        action = function(vehicle)
            SetVehicleEnginePowerMultiplier(vehicle, -50.0)
            if Config.ShowNotifications then
            ESX.ShowNotification("¡Tu vehículo ha perdido potencia!")
            end
            Citizen.SetTimeout(Config.BreakdownTypes[3].duration, function()
                SetVehicleEnginePowerMultiplier(vehicle, 0.0) 
                if Config.ShowNotifications then
                ESX.ShowNotification("La potencia de tu vehículo ha sido restaurada.")
                end
            end)
        end
    },
}
