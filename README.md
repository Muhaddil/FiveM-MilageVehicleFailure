# FiveM Vehicle Breakdown Script

## Overview

The FiveM Vehicle Breakdown Script adds a dynamic vehicle breakdown system to your FiveM server. This script introduces random vehicle malfunctions based on the number of kilometers driven. The malfunctions include engine failures, tire bursts, and power loss. It also features a debug mode for easier testing and adjustment.

## Features

- **Engine Failure**: Completely disables the vehicle's engine and turns it off.
- **Tire Burst**: Randomly causes one of the vehicle's tires to burst.
- **Power Loss**: Reduces the engine power of the vehicle significantly.

## Requirements

- ESX Framework for FiveM.
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
