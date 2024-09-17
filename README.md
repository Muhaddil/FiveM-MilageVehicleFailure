# FiveM Vehicle Breakdown Script

## Overview

![FiveM-MilageVehicleFailure](https://i.ibb.co/hHvxfx8/Five-M-Milage-Vehicle-Failure.png)

The FiveM Vehicle Breakdown Script adds a dynamic vehicle breakdown system to your FiveM server. This script introduces random vehicle malfunctions based on the number of kilometers driven. The malfunctions include engine failures, tire bursts, power loss and more! It also features a debug mode for easier testing and adjustment.

## Features

- **Motor Failure**: Completely disables the vehicle's engine by turning it off and reducing engine health to zero. (This is disabled by default) After 30 seconds, the engine cools down and returns to normal.
  
- **Tire Burst**: Randomly causes one of the vehicle's tires to burst, if the tires can burst. The player is notified when a tire has burst.

- **Power Loss**: Significantly reduces the engine power of the vehicle for 20 seconds. After that, the power is restored to its normal level.

- **Petrol Loss**: Causes a fuel leak in the vehicle, reducing the fuel level and potentially turning off the engine if it runs too low. The player is notified of the gasoline loss.

- **Transmission Failure**: Temporarily disables the transmission by turning off the engine and reducing engine health. After 25 seconds, the transmission is repaired, and the engine is turned back on.

- **Battery Drain**: Drains the vehicle's battery completely, turning off the engine. After 60 seconds, the battery recharges and the engine restarts. A flag can be activated or deactivated for this failure.

- **Radiator Leak**: Increases the engine temperature by 50 degrees due to a radiator leak. After 30 seconds, the leak is sealed, and the temperature returns to normal.

- **Brake Failure**: Activates the vehicle's brakes and handbrake, simulating brake failure. The vehicle becomes immobile until the brakes are repaired after 20 seconds.

- **Suspension Damage**: Lowers the suspension height of the vehicle due to damage. After 30 seconds, the suspension is repaired, and the height returns to normal.

- **Alternator Failure**: Reduces the battery health due to alternator malfunction. After 30 seconds, the alternator is repaired, and battery health improves.

- **Transmission Fluid Leak**: Causes a leak in the transmission fluid, reducing its health. After 25 seconds, the leak is repaired, and transmission health is restored.

- **Clutch Failure**: Temporarily lowers the clutch's efficiency, affecting gear shifting. After 20 seconds, the clutch is repaired.

- **Fuel Filter Clogged**: Decreases the vehicle's fuel level by 50 units due to a clogged fuel filter. After 20 seconds, the filter is cleaned, and fuel level is restored.

- **Door Fall Off Failure**: Randomly causes one of the vehicle's doors to fall off. The player is notified when a door falls off. 

## Requirements

- ESX Framework for FiveM.
- OR QBCore Framework for FiveM.
- A SQL database to store vehicle kilometer data.

## Installation

1. **Download the Script**

   Clone the repository to your FiveM server or download the files manually.

   ```bash
   git clone https://github.com/muhaddil/FiveM-MilageVehicleFailure.git
    ```

2. **Place the Files**

   Move the script files into your server’s resources directory.

4. **Add the Script to server.cfg**

   Ensure the script is started in your server.cfg by adding the following line:
    ```
    ensure FiveM-MilageVehicleFailure
    ```

5. **Set up the DataBase**

   Ensure that your database includes the necessary table. Use the following SQL to create the vehicle_kilometers table:
    ```sql
    CREATE TABLE IF NOT EXISTS vehicle_kilometers (
    plate VARCHAR(8) NOT NULL PRIMARY KEY,
    kilometers DOUBLE NOT NULL DEFAULT 0
    );
   ```

6. **Enjoy!**

   The script now must work, edit the config.lua file to meet you requirements!
