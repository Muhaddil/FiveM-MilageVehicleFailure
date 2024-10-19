Config = {}

-- Debugging mode
Config.DebugMode = true
Config.ShowNotifications = true

-- Optimal configuration for debugging
-- Config.CheckInterval = 1000
-- Config.BaseBreakdownChance = 0.1
-- Config.MaxBreakdownChance = 1.0

Config.CheckInterval = 10000            -- Cooldown in milliseconds
Config.KilometerMultiplier = 1.0        -- Multiplier for vehicle mileage accumulation. Set to 1.0 for normal rate, higher values will increase mileage faster, and lower values will decrease mileage accumulation.
Config.BaseBreakdownChance = 0.01       --Base failure probability per 1000 km
Config.MaxBreakdownChance = 0.5         -- Maximum probability of failure
Config.BreakdownCooldown = 10800000     -- Cooldown in milliseconds (e.g. 10800000 ms = 3 hours)
Config.SpeedToDamageRatio = 1.0         -- Does nothing | Useless
Config.preventVehicleFlip = true        -- Disable flipping overturned cars
Config.damageMultiplier = 5             -- Damage multiplier applied to the engine in each crash
Config.CheckIntervalEngineDamage = 2000 -- Cooldown in milliseconds
Config.AutoRunSQL = true
Config.AutoVersionChecker = true
Config.FrameWork = "esx"                -- Only compatible with esx or qb (for the moment)
Config.UseOXNotifications = true

-- Setting to use external mileage system (config your own external system if you have one in server.lua line 34)
Config.UseExternalMileageSystem = false

-- Config for the vehicle physics in harsh terrains
Config.EnableCarPhysics = true
Config.MaxSpeed = 40            -- In KM/hours
Config.CarPhysicsTimeout = 2500 -- In milliseconds
Config.CarSinking = false       -- Works but it's as little bit buggy, not a great implementation
Config.reductionFactor = 0.1    -- How fast the vehicles brake on sand/grass
Config.TractionBonus = 0.2      -- Additional traction boost for emergency vehicles, improving grip on rough terrains like sand or grass
Config.BrakeTemperaturaGain = 35 -- How much heat is applied to the brakes every 1.5 seconds
Config.MaxBrakeTemp = 500 -- The max temperatura the brakes can handle before giving out
Config.CoolingRate = 1 -- How fast the brakes cool down

-- Types of breakdowns
Config.BreakdownTypes = {
    {
        name = "MotorFailure",
        chance = 0.2,
        duration = 30000,
        action = function(vehicle)
            -- local currentHealth = GetVehicleEngineHealth(vehicle)
            SetVehicleEngineOn(vehicle, false, true, true)
            SetVehicleEngineHealth(vehicle, -4000)
            -- TriggerEvent('realistic-vehicle:engineFailureFlag', vehicle, true)
            if Config.ShowNotifications then
                TriggerEvent('SendNotification', '', "¡El motor de tu vehículo se ha calentado y ha roto la culata!",
                    5000, "error")
            end
            -- Citizen.SetTimeout(Config.BreakdownTypes[1].duration, function()
            --     SetVehicleEngineHealth(vehicle, currentHealth)
            --     SetVehicleEngineOn(vehicle, true, true, true)
            --     if Config.ShowNotifications then
            --     TriggerEvent('SendNotification', '', "El motor de tu vehículo se ha enfriado.", 5000, "success")

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
                TriggerEvent('SendNotification', '', "¡Uno de los neumáticos de tu vehículo ha reventado!", 5000, "error")
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
                TriggerEvent('SendNotification', '', "¡Tu vehículo ha perdido potencia!", 5000, "error")
            end
            Citizen.SetTimeout(Config.BreakdownTypes[3].duration, function()
                SetVehicleEnginePowerMultiplier(vehicle, 0.0)
                TriggerEvent('realistic-vehicle:powerLossFlag', vehicle, false)
                if Config.ShowNotifications then
                    TriggerEvent('SendNotification', '', "La potencia de tu vehículo ha sido restaurada.", 5000,
                        "success")
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
                TriggerEvent('SendNotification', '', "¡Tu vehículo tiene una fuga de gasolina!", 5000, "error")
            end
            Citizen.SetTimeout(Config.BreakdownTypes[4].duration, function()
                local currentFuelLevel = GetVehicleFuelLevel(vehicle)
                SetVehicleFuelLevel(vehicle, currentFuelLevel)
                SetVehicleEngineOn(vehicle, true, true, true)
                TriggerEvent('realistic-vehicle:petrolLossFlag', vehicle, false)
                if Config.ShowNotifications then
                    TriggerEvent('SendNotification', '', "La fuga de gasolina ha sido sellada.", 5000, "success")
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
                TriggerEvent('SendNotification', '', "¡La transmisión de tu vehículo está fallando!", 5000, "error")
            end
            Citizen.SetTimeout(Config.BreakdownTypes[5].duration, function()
                SetVehicleEngineHealth(vehicle, 1000.0)
                SetVehicleEngineOn(vehicle, true, true, true)
                TriggerEvent('realistic-vehicle:transmissionFailureFlag', vehicle, false)
                if Config.ShowNotifications then
                    TriggerEvent('SendNotification', '', "La transmisión de tu vehículo ha sido reparada.", 5000,
                        "success")
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
                TriggerEvent('SendNotification', '', "¡La batería de tu vehículo está vacía!", 5000, "error")
            end
            Citizen.SetTimeout(Config.BreakdownTypes[6].duration, function()
                TriggerEvent('realistic-vehicle:batteryDrainFlag', vehicle, false)
                SetVehicleEngineOn(vehicle, true, true, true)
                if Config.ShowNotifications then
                    TriggerEvent('SendNotification', '', "La batería de tu vehículo se ha recargado.", 5000, "success")
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
                TriggerEvent('SendNotification', '', "¡El radiador de tu vehículo tiene una fuga!", 5000, "error")
            end
            Citizen.SetTimeout(Config.BreakdownTypes[7].duration, function()
                SetVehicleEngineTemperature(vehicle, initialTemperature)
                TriggerEvent('realistic-vehicle:radiatorLeakFlag', vehicle, false)
                if Config.ShowNotifications then
                    TriggerEvent('SendNotification', '', "La fuga del radiador se ha sellado.", 5000, "success")
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
                TriggerEvent('SendNotification', '', "¡Los frenos de tu vehículo están fallando!", 5000, "error")
            end
            Citizen.SetTimeout(Config.BreakdownTypes[8].duration, function()
                SetVehicleBrake(vehicle, false)
                SetVehicleHandbrake(vehicle, false)
                TriggerEvent('realistic-vehicle:brakeFailureFlag', vehicle, false)
                if Config.ShowNotifications then
                    TriggerEvent('SendNotification', '', "Los frenos de tu vehículo han sido reparados.", 5000, "success")
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
                TriggerEvent('SendNotification', '', "¡La suspensión de tu vehículo está dañada!", 5000, "error")
            end
            Citizen.SetTimeout(Config.BreakdownTypes[9].duration, function()
                SetVehicleSuspensionHeight(vehicle, 0.0)
                TriggerEvent('realistic-vehicle:suspensionDamageFlag', vehicle, false)
                if Config.ShowNotifications then
                    TriggerEvent('SendNotification', '', "La suspensión de tu vehículo ha sido reparada.", 5000,
                        "success")
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
                TriggerEvent('SendNotification', '', "¡El alternador de tu vehículo está fallando!", 5000, "error")
            end
            Citizen.SetTimeout(Config.BreakdownTypes[10].duration, function()
                TriggerEvent('realistic-vehicle:alternatorFailureFlag', vehicle, false)
                if Config.ShowNotifications then
                    TriggerEvent('SendNotification', '', "El alternador de tu vehículo ha sido reparado.", 5000,
                        "success")
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
                TriggerEvent('SendNotification', '', "¡Hay una fuga de fluido de transmisión!", 5000, "error")
            end
            SetVehicleEnginePowerMultiplier(vehicle, -50.0)
            Citizen.SetTimeout(Config.BreakdownTypes[11].duration, function()
                TriggerEvent('realistic-vehicle:transmissionFluidLeakFlag', vehicle, false)
                if Config.ShowNotifications then
                    TriggerEvent('SendNotification', '', "La fuga de fluido de transmisión se ha reparado.", 5000,
                        "success")
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
                TriggerEvent('SendNotification', '', "¡El embrague de tu vehículo está fallando!", 5000, "error")
            end
            Citizen.SetTimeout(Config.BreakdownTypes[12].duration, function()
                SetVehicleClutch(vehicle, 1.0)
                TriggerEvent('realistic-vehicle:clutchFailureFlag', vehicle, false)
                if Config.ShowNotifications then
                    TriggerEvent('SendNotification', '', "El embrague de tu vehículo ha sido reparado.", 5000, "success")
                end
            end)
        end
    },
    {
        name = "FuelFilterClogged",
        chance = 0.4,
        duration = 20000,
        action = function(vehicle)
            DebugPrint(GetVehicleFuelLevel(vehicle))
            SetVehicleFuelLevel(vehicle, 9.77)
            TriggerEvent('realistic-vehicle:fuelFilterCloggedFlag', vehicle, true)
            if Config.ShowNotifications then
                TriggerEvent('SendNotification', '', "¡El filtro de combustible está obstruido!", 5000, "error")
            end
            Citizen.SetTimeout(Config.BreakdownTypes[13].duration, function()
                SetVehicleFuelLevel(vehicle, GetVehicleFuelLevel(vehicle) + 40.0)
                TriggerEvent('realistic-vehicle:fuelFilterCloggedFlag', vehicle, false)
                if Config.ShowNotifications then
                    TriggerEvent('SendNotification', '', "El filtro de combustible ha sido limpiado.", 5000, "success")
                end
            end)
        end
    },
    {
        name = "HoodLatchFailure",
        chance = 0.5,
        duration = 20000,
        action = function(vehicle)
            SetVehicleDoorOpen(vehicle, 4, false, false)
            --For Other Scripts Incompatibility
            -- TriggerEvent('realistic-vehicle:hoodLatchFailureFlag', vehicle, true)

            if Config.ShowNotifications then
                TriggerEvent('SendNotification', '', "¡El capó de tu vehículo se ha abierto debido a un fallo en los seguros!", 5000, "error")
            end

            -- To set if the hood closes on its own when a timeout finishes
            -- Citizen.SetTimeout(Config.BreakdownTypes[14].duration, function()
            --     SetVehicleDoorShut(vehicle, 4, false)
            --     TriggerEvent('realistic-vehicle:hoodLatchFailureFlag', vehicle, false)
            --     if Config.ShowNotifications then
            --     TriggerEvent('SendNotification', '', "El capó de tu vehículo ha sido cerrado", 5000, "success")
            --     end
            -- end)
        end
    },
    {
        name = "DoorFallOffFailure",
        chance = 0.2,
        duration = 0,
        action = function(vehicle)
            local doorIndex = math.random(0, 5)

            if DoesVehicleHaveDoor(vehicle, doorIndex) then
                SetVehicleDoorBroken(vehicle, doorIndex, false)
            else
                DebugPrint('¡Esa puerta no existe!')
            end

            if Config.ShowNotifications then
                TriggerEvent('SendNotification', '', "¡Una de las puertas de tu vehículo se ha soltado y se ha caído!", 5000, "error")
            end
        end
    },

}

-- This vehicles will be excluded from the mileage probability of breakdowns

Config.ExcludedVehicles = {
    "ADMINCAR",
}

Config.ExcludedPrefixes = {
    "LSPD",
    "LSSD",
    "AMB",
}
