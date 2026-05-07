CREATE TABLE IF NOT EXISTS `police_armory_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job` varchar(50) NOT NULL DEFAULT 'police',
  `grade` int(11) NOT NULL DEFAULT 0,
  `name` varchar(50) NOT NULL,
  `label` varchar(50) NOT NULL,
  `price` int(11) NOT NULL DEFAULT 0,
  `description` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `police_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `department` varchar(50) DEFAULT NULL,
  `type` enum('deposit','withdraw') DEFAULT 'deposit',
  `amount` int(11) DEFAULT 0,
  `description` text DEFAULT NULL,
  `source` varchar(50) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
