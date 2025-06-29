CREATE TABLE IF NOT EXISTS vehicle_kilometers (
    plate VARCHAR(8) NOT NULL PRIMARY KEY,
    kilometers DOUBLE NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS vehicle_maintenance (
    plate VARCHAR(20) PRIMARY KEY,
    last_maintenance_km INT NOT NULL DEFAULT 0
);