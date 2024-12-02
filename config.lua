Config = {}

-- Debugging mode
Config.DebugMode = true
Config.ShowNotifications = true

-- Optimal configuration for debugging
-- Config.CheckInterval = 1000
-- Config.BaseBreakdownChance = 0.1
-- Config.MaxBreakdownChance = 1.0

Config.CheckInterval = 10000            -- Cooldown in milliseconds
Config.KMNUIInterval = 1000             -- Cooldown in milliseconds
Config.KilometerMultiplier = 5.0        -- Multiplier for vehicle mileage accumulation. Set to 1.0 for normal rate, higher values will increase mileage faster, and lower values will decrease mileage accumulation.
Config.BaseBreakdownChance = 0.01       -- Base failure probability per 1000 km
Config.MaxBreakdownChance = 0.5         -- Maximum probability of failure
Config.BreakdownCooldown = 10800000     -- Cooldown in milliseconds (e.g. 10800000 ms = 3 hours)
Config.preventVehicleFlip = true        -- Disable flipping overturned cars
Config.AutoRunSQL = true                -- If the script should run the SQL file automatically
Config.AutoVersionChecker = true        -- If the script should search for the latest version and warn you in the console if founds one
Config.FrameWork = "esx"                -- Only compatible with esx or qb (for the moment)
Config.UseOXNotifications = true        -- If the script uses the ox_libs notifications or framework ones
Config.damageMultiplier = 5             -- Damage multiplier (general) applied to the engine in each crash
Config.ApplyDamageAll = true            -- If the ApplyEngineDamage function applies the damage to the engine only or to engine/petroltank (if Config.ApplyDamagePetrol true)/body.
Config.ApplyDamagePetrol = false        -- If the ApplyEngineDamage function applies the damage to petroltank, it can cause lots of fires.
Config.CheckIntervalEngineDamage = 2000 -- Cooldown in milliseconds
Config.ClassDamageMultipliers = {       -- Damage multiplier (specific for each vehicle class) applied to the engine in each crash
    [0]  = { damageMultiplier = 4.5 },  -- Compacts
    [1]  = { damageMultiplier = 5.0 },  -- Sedans
    [2]  = { damageMultiplier = 5.5 },  -- SUVs
    [3]  = { damageMultiplier = 4.8 },  -- Coupes
    [4]  = { damageMultiplier = 5.5 },  -- Muscle
    [5]  = { damageMultiplier = 5.3 },  -- Sports Classics
    [6]  = { damageMultiplier = 6.0 },  -- Sports
    [7]  = { damageMultiplier = 6.5 },  -- Super
    [8]  = { damageMultiplier = 3.0 },  -- Motorcycles
    [9]  = { damageMultiplier = 5.2 },  -- Off-road
    [10] = { damageMultiplier = 7.0 },  -- Industrial
    [11] = { damageMultiplier = 5.5 },  -- Utility
    [12] = { damageMultiplier = 5.0 },  -- Vans
    [13] = { damageMultiplier = 2.5 },  -- Cycles
    [14] = { damageMultiplier = 4.0 },  -- Boats
    [15] = { damageMultiplier = 8.0 },  -- Helicopters
    [16] = { damageMultiplier = 9.0 },  -- Planes
    [17] = { damageMultiplier = 5.0 },  -- Service
    [18] = { damageMultiplier = 5.0 },  -- Emergency
    [19] = { damageMultiplier = 6.0 },  -- Military
    [20] = { damageMultiplier = 7.5 },  -- Commercial
    [21] = { damageMultiplier = 10.0 }, -- Trains
    [22] = { damageMultiplier = 5.5 },  -- Open Wheel
}

-- Setting to use mileages systems (config your own external system if you have one in server.lua line 34)
Config.MileageSystem = 'default' -- default / jg-vehiclemileage / other
Config.KMDisplayPosition = 'top-center' -- Available positions for the NUI: 'bottom-right', 'bottom-left', 'top-right', 'top-left', 'bottom-center', 'top-center'

-- Config for the vehicle physics in harsh terrains
Config.EnableCarPhysics = true
Config.MaxSpeed = 40            -- In KM/hours
Config.CarPhysicsTimeout = 2500 -- In milliseconds
Config.CarSinking = false       -- Works but it's as little bit buggy, not a great implementation
Config.reductionFactor = 0.1    -- How fast the vehicles brake on sand/grass
Config.TractionBonus = 0.2      -- Additional traction boost for emergency vehicles, improving grip on rough terrains like sand or grass
Config.PlayWarningSound = true  -- If play warning sound when the brakes overheats
Config.brakeReductionFactor = 1.0  -- Standard factor for brake reduction; lower values result in more significant reduction based on temperature.
Config.ClassConfigs = {
    [0]  = { BrakeTemperaturaGain = 15, MaxBrakeTemp = 550, CoolingRate = 1.1 },  -- Compacts
    [1]  = { BrakeTemperaturaGain = 20, MaxBrakeTemp = 600, CoolingRate = 1.0 },  -- Sedans
    [2]  = { BrakeTemperaturaGain = 25, MaxBrakeTemp = 650, CoolingRate = 1.05 }, -- SUVs
    [3]  = { BrakeTemperaturaGain = 30, MaxBrakeTemp = 700, CoolingRate = 1.0 },  -- Coupes
    [4]  = { BrakeTemperaturaGain = 35, MaxBrakeTemp = 800, CoolingRate = 0.8 },  -- Muscle
    [5]  = { BrakeTemperaturaGain = 40, MaxBrakeTemp = 900, CoolingRate = 0.7 },  -- Sports Classics
    [6]  = { BrakeTemperaturaGain = 45, MaxBrakeTemp = 950, CoolingRate = 1.3 },  -- Sports
    [7]  = { BrakeTemperaturaGain = 50, MaxBrakeTemp = 1000, CoolingRate = 1.6 }, -- Super
    [8]  = { BrakeTemperaturaGain = 10, MaxBrakeTemp = 500, CoolingRate = 1.5 },  -- Motorcycles
    [9]  = { BrakeTemperaturaGain = 50, MaxBrakeTemp = 1100, CoolingRate = 0.4 }, -- Off-road
    [10] = { BrakeTemperaturaGain = 55, MaxBrakeTemp = 1200, CoolingRate = 0.3 }, -- Industrial
    [11] = { BrakeTemperaturaGain = 35, MaxBrakeTemp = 800, CoolingRate = 1.0 },  -- Utility
    [12] = { BrakeTemperaturaGain = 30, MaxBrakeTemp = 750, CoolingRate = 1.2 },  -- Vans
    [13] = { BrakeTemperaturaGain = 5, MaxBrakeTemp = 450, CoolingRate = 2.5 },   -- Cycles
    [14] = { BrakeTemperaturaGain = 20, MaxBrakeTemp = 550, CoolingRate = 1.8 },  -- Boats
    [15] = { BrakeTemperaturaGain = 60, MaxBrakeTemp = 1300, CoolingRate = 0.4 }, -- Helicopters
    [16] = { BrakeTemperaturaGain = 65, MaxBrakeTemp = 1400, CoolingRate = 0.3 }, -- Planes
    [17] = { BrakeTemperaturaGain = 20, MaxBrakeTemp = 600, CoolingRate = 1.6 },  -- Service
    [18] = { BrakeTemperaturaGain = 20, MaxBrakeTemp = 650, CoolingRate = 1.5 },  -- Emergency
    [19] = { BrakeTemperaturaGain = 25, MaxBrakeTemp = 700, CoolingRate = 1.5 },  -- Military
    [20] = { BrakeTemperaturaGain = 70, MaxBrakeTemp = 1500, CoolingRate = 0.2 }, -- Commercial
    [21] = { BrakeTemperaturaGain = 80, MaxBrakeTemp = 1600, CoolingRate = 0.1 }, -- Trains
    [22] = { BrakeTemperaturaGain = 50, MaxBrakeTemp = 900, CoolingRate = 0.6 },  -- Open Wheel
}

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
        chance = 0.6,
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
                TriggerEvent('SendNotification', '',
                    "¡El capó de tu vehículo se ha abierto debido a un fallo en los seguros!", 5000, "error")
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
            local doorCount = GetNumberOfVehicleDoors(vehicle)

            if doorCount > 0 then
                local doorIndex = math.random(0, doorCount - 1)

                if DoesVehicleHaveDoor(vehicle, doorIndex) then
                    SetVehicleDoorBroken(vehicle, doorIndex, false)
                    if Config.ShowNotifications then
                        TriggerEvent('SendNotification', '',
                            "¡Una de las puertas de tu vehículo se ha soltado y se ha caído!",
                            5000, "error")
                    end
                else
                    DebugPrint('¡Esa puerta no existe!')
                end
            else
                DebugPrint('¡Este vehículo no tiene puertas para soltarse!')
            end
        end
    },
    {
        name = "EngineFire",
        chance = 0.2,
        action = function(vehicle)
            SetVehicleEngineOn(vehicle, false, true, true)
            local vehicleEntity = NetworkGetEntityFromNetworkId(NetworkGetNetworkIdFromEntity(vehicle))
            StartEntityFire(vehicleEntity)
            if Config.ShowNotifications then
                TriggerEvent('SendNotification', '', "¡El motor de tu vehículo ha prendido fuego, corre!", 5000, "error")
            end
            SetVehicleEngineHealth(vehicle, -4000)
            Wait(15000)
            NetworkExplodeVehicle(vehicle, true, false)
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
