Config = {}

-- Debugging mode
Config.DebugMode = true
Config.ShowNotifications = true

-- Optimal configuration for debugging
-- Config.CheckInterval = 1000
-- Config.BaseBreakdownChance = 0.1
-- Config.MaxBreakdownChance = 1.0

Config.CheckInterval = 10000            -- Cooldown in milliseconds
Config.BaseBreakdownChance = 0.01       --Base failure probability per 1000 km
Config.MaxBreakdownChance = 0.5         -- Maximum probability of failure
Config.BreakdownCooldown = 10800000     -- Cooldown in milliseconds (e.g. 10800000 ms = 3 hours)
Config.SpeedToDamageRatio = 1.0         -- Does nothing | Useless
Config.preventVehicleFlip = true        -- Disable flipping overturned cars
Config.damageMultiplier = 0.5           -- Damage multiplier applied to the engine in each crash
Config.CheckIntervalEngineDamage = 2000 -- Cooldown in milliseconds

-- Setting to use external mileage system
Config.UseExternalMileageSystem = true

-- Types of breakdowns
Config.BreakdownTypes = {
    {
        name = "MotorFailure",
        chance = 0.2,
        duration = 30000,
        action = function(vehicle)
            SetVehicleEngineOn(vehicle, false, true, true)
            SetVehicleEngineHealth(vehicle, -4000)
            -- TriggerEvent('realistic-vehicle:engineFailureFlag', vehicle, true)
            if Config.ShowNotifications then
                ESX.ShowNotification("¡El motor de tu vehículo se ha calentado y ha roto la culata!")
            end
            -- Citizen.SetTimeout(Config.BreakdownTypes[1].duration, function()
            --     SetVehicleEngineHealth(vehicle, 1000.0)
            --     SetVehicleEngineOn(vehicle, true, true, true)
            --     if Config.ShowNotifications then
            --         ESX.ShowNotification("El motor de tu vehículo se ha enfriado.")
            --     end
            --     TriggerEvent('realistic-vehicle:engineFailureFlag', vehicle, false)
            -- end)
        end
    },
    {
        name = "TyreBurst",
        chance = 0.7,
        action = function(vehicle)
            if GetVehicleTyresCanBurst(vehicle) == false then return end
            local numWheels = GetVehicleNumberOfWheels(vehicle)
            local affectedTire
            if numWheels == 2 then
                affectedTire = (math.random(2) - 1) * 4
            elseif numWheels == 4 then
                affectedTire = (math.random(4) - 1)
                if affectedTire > 1 then affectedTire = affectedTire + 2 end
            elseif numWheels == 6 then
                affectedTire = (math.random(6) - 1)
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
        chance = 0.4,
        duration = 20000,
        action = function(vehicle)
            SetVehicleEnginePowerMultiplier(vehicle, -50.0)
            TriggerEvent('realistic-vehicle:powerLossFlag', vehicle, true)
            if Config.ShowNotifications then
                ESX.ShowNotification("¡Tu vehículo ha perdido potencia!")
            end
            Citizen.SetTimeout(Config.BreakdownTypes[3].duration, function()
                SetVehicleEnginePowerMultiplier(vehicle, 0.0)
                TriggerEvent('realistic-vehicle:powerLossFlag', vehicle, false)
                if Config.ShowNotifications then
                    ESX.ShowNotification("La potencia de tu vehículo ha sido restaurada.")
                end
            end)
        end
    },
    {
        name = "PetrolLoss",
        chance = 1.6,
        duration = 25000,
        action = function(vehicle)
            -- SetVehicleFuelLevel(vehicle, currentFuelLevel - 10.0)
            SetVehicleEngineOn(vehicle, false, false, false)
            TriggerEvent('realistic-vehicle:petrolLossFlag', vehicle, true)
            if Config.ShowNotifications then
                ESX.ShowNotification("¡Tu vehículo tiene una fuga de gasolina!")
            end
            Citizen.SetTimeout(Config.BreakdownTypes[4].duration, function()
                local currentFuelLevel = GetVehicleFuelLevel(vehicle)
                SetVehicleFuelLevel(vehicle, currentFuelLevel)
                SetVehicleEngineOn(vehicle, true, true, true)
                TriggerEvent('realistic-vehicle:petrolLossFlag', vehicle, false)
                if Config.ShowNotifications then
                    ESX.ShowNotification("La fuga de gasolina ha sido sellada.")
                end
            end)
        end
    },
    {
        name = "TransmissionFailure",
        chance = 0.3,
        duration = 25000,
        action = function(vehicle)
            SetVehicleEngineOn(vehicle, false, true, true)
            SetVehicleEngineHealth(vehicle, -500)
            TriggerEvent('realistic-vehicle:transmissionFailureFlag', vehicle, true)
            if Config.ShowNotifications then
                ESX.ShowNotification("¡La transmisión de tu vehículo está fallando!")
            end
            Citizen.SetTimeout(Config.BreakdownTypes[5].duration, function()
                SetVehicleEngineHealth(vehicle, 1000.0)
                SetVehicleEngineOn(vehicle, true, true, true)
                TriggerEvent('realistic-vehicle:transmissionFailureFlag', vehicle, false)
                if Config.ShowNotifications then
                    ESX.ShowNotification("La transmisión de tu vehículo ha sido reparada.")
                end
            end)
        end
    },
    {
        name = "BatteryDrain",
        chance = 0.3,
        duration = 60000,
        action = function(vehicle)
            TriggerEvent('realistic-vehicle:batteryDrainFlag', vehicle, true)
            SetVehicleEngineOn(vehicle, false, true, true)
            if Config.ShowNotifications then
                ESX.ShowNotification("¡La batería de tu vehículo está vacía!")
            end
            Citizen.SetTimeout(Config.BreakdownTypes[6].duration, function()
                TriggerEvent('realistic-vehicle:batteryDrainFlag', vehicle, false)
                SetVehicleEngineOn(vehicle, true, true, true)
                if Config.ShowNotifications then
                    ESX.ShowNotification("La batería de tu vehículo se ha recargado.")
                end
            end)
        end
    },
    {
        name = "RadiatorLeak",
        chance = 0.3,
        duration = 30000,
        action = function(vehicle)
            local initialTemperature = GetVehicleEngineTemperature(vehicle)
            SetVehicleEngineTemperature(vehicle, GetVehicleEngineTemperature(vehicle) + 50.0)
            TriggerEvent('realistic-vehicle:radiatorLeakFlag', vehicle, true)
            if Config.ShowNotifications then
                ESX.ShowNotification("¡El radiador de tu vehículo tiene una fuga!")
            end
            Citizen.SetTimeout(Config.BreakdownTypes[7].duration, function()
                SetVehicleEngineTemperature(vehicle, initialTemperature)
                TriggerEvent('realistic-vehicle:radiatorLeakFlag', vehicle, false)
                if Config.ShowNotifications then
                    ESX.ShowNotification("La fuga del radiador se ha sellado.")
                end
            end)
        end
    },
    {
        name = "BrakeFailure",
        chance = 0.3,
        duration = 20000,
        action = function(vehicle)
            SetVehicleBrake(vehicle, true)
            SetVehicleHandbrake(vehicle, true)
            TriggerEvent('realistic-vehicle:brakeFailureFlag', vehicle, true)
            if Config.ShowNotifications then
                ESX.ShowNotification("¡Los frenos de tu vehículo están fallando!")
            end
            Citizen.SetTimeout(Config.BreakdownTypes[8].duration, function()
                SetVehicleBrake(vehicle, false)
                SetVehicleHandbrake(vehicle, false)
                TriggerEvent('realistic-vehicle:brakeFailureFlag', vehicle, false)
                if Config.ShowNotifications then
                    ESX.ShowNotification("Los frenos de tu vehículo han sido reparados.")
                end
            end)
        end
    },
    {
        name = "SuspensionDamage",
        chance = 0.4,
        duration = 30000,
        action = function(vehicle)
            SetVehicleSuspensionHeight(vehicle, 0.05)
            TriggerEvent('realistic-vehicle:suspensionDamageFlag', vehicle, true)
            if Config.ShowNotifications then
                ESX.ShowNotification("¡La suspensión de tu vehículo está dañada!")
            end
            Citizen.SetTimeout(Config.BreakdownTypes[9].duration, function()
                SetVehicleSuspensionHeight(vehicle, 0.0)
                TriggerEvent('realistic-vehicle:suspensionDamageFlag', vehicle, false)
                if Config.ShowNotifications then
                    ESX.ShowNotification("La suspensión de tu vehículo ha sido reparada.")
                end
            end)
        end
    },
    {
        name = "AlternatorFailure",
        chance = 0.2,
        duration = 30000,
        action = function(vehicle)
            SetVehicleEngineOn(vehicle, false, true, false)
            SetVehicleLights(vehicle, 1)
            TriggerEvent('realistic-vehicle:alternatorFailureFlag', vehicle, true)
            if Config.ShowNotifications then
                ESX.ShowNotification("¡El alternador de tu vehículo está fallando!")
            end
            Citizen.SetTimeout(Config.BreakdownTypes[10].duration, function()
                TriggerEvent('realistic-vehicle:alternatorFailureFlag', vehicle, false)
                if Config.ShowNotifications then
                    ESX.ShowNotification("El alternador de tu vehículo ha sido reparado.")
                end
                SetVehicleEngineOn(vehicle, true, true, true)
                SetVehicleLights(vehicle, 0)
            end)
        end
    },
    {
        name = "TransmissionFluidLeak",
        chance = 0.3,
        duration = 25000,
        action = function(vehicle)
            TriggerEvent('realistic-vehicle:transmissionFluidLeakFlag', vehicle, true)
            if Config.ShowNotifications then
                ESX.ShowNotification("¡Hay una fuga de fluido de transmisión!")
            end
            SetVehicleEnginePowerMultiplier(vehicle, -50.0)
            Citizen.SetTimeout(Config.BreakdownTypes[11].duration, function()
                TriggerEvent('realistic-vehicle:transmissionFluidLeakFlag', vehicle, false)
                if Config.ShowNotifications then
                    ESX.ShowNotification("La fuga de fluido de transmisión se ha reparado.")
                end
                SetVehicleEnginePowerMultiplier(vehicle, 0.0)
            end)
        end
    },
    {
        name = "ClutchFailure",
        chance = 0.3,
        duration = 20000,
        action = function(vehicle)
            SetVehicleClutch(vehicle, 0.2)
            TriggerEvent('realistic-vehicle:clutchFailureFlag', vehicle, true)
            if Config.ShowNotifications then
                ESX.ShowNotification("¡El embrague de tu vehículo está fallando!")
            end
            Citizen.SetTimeout(Config.BreakdownTypes[12].duration, function()
                SetVehicleClutch(vehicle, 1.0)
                TriggerEvent('realistic-vehicle:clutchFailureFlag', vehicle, false)
                if Config.ShowNotifications then
                    ESX.ShowNotification("El embrague de tu vehículo ha sido reparado.")
                end
            end)
        end
    },
    {
        name = "FuelFilterClogged",
        chance = 0.4,
        duration = 20000,
        action = function(vehicle)
            print(GetVehicleFuelLevel(vehicle))
            SetVehicleFuelLevel(vehicle, 9.77)
            TriggerEvent('realistic-vehicle:fuelFilterCloggedFlag', vehicle, true)
            if Config.ShowNotifications then
                ESX.ShowNotification("¡El filtro de combustible está obstruido!")
            end
            Citizen.SetTimeout(Config.BreakdownTypes[13].duration, function()
                SetVehicleFuelLevel(vehicle, GetVehicleFuelLevel(vehicle) + 40.0)
                TriggerEvent('realistic-vehicle:fuelFilterCloggedFlag', vehicle, false)
                if Config.ShowNotifications then
                    ESX.ShowNotification("El filtro de combustible ha sido limpiado.")
                end
            end)
        end
    },
}

Config.ExcludedVehicles = {
    "ADMINCAR",
}

Config.ExcludedPrefixes = {
    "LSPD",
    "LSSD",
    "AMB",
}
