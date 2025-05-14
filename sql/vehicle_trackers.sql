CREATE TABLE IF NOT EXISTS `vehicle_trackers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `serialNumber` varchar(20) NOT NULL,
  `vehiclePlate` varchar(8) NOT NULL,
  `startedAt` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `serialNumber` (`serialNumber`),
  UNIQUE KEY `vehiclePlate` (`vehiclePlate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
