-- phpMyAdmin SQL Dump
-- version 4.0.4.2
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jan 04, 2018 at 06:52 AM
-- Server version: 5.6.13
-- PHP Version: 5.4.17

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `councilqueue`
--
CREATE DATABASE IF NOT EXISTS `councilqueue` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;
USE `councilqueue`;

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_new_person`(
	IN `in_type` ENUM('Citizen','Anonymous'),
	IN `firstName` VARCHAR(50),
	IN `lastName` VARCHAR(50),
	IN `organization` VARCHAR(50),
	IN `service` ENUM('Council Tax','Benefits','Rent'),
	OUT `err` TINYINT UNSIGNED,
	OUT `errs` VARCHAR(50)






)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
add_new_person: BEGIN

IF NULLIF(`in_type`, '') IS NULL THEN
	SET `err` = 100, `errs` = "No type specified.";
	LEAVE add_new_person;
END IF;

IF `in_type` = 'Citizen' THEN
	IF NULLIF(`lastName`, '') IS NULL OR NULLIF(`firstName`, '') IS NULL THEN
		SET `err` = 101, `errs` = "No first name or last name given.";
		LEAVE add_new_person;
	END IF;
END IF;

IF NULLIF(`service`, '') IS NULL THEN
	SET `err` = 102, `errs` = "No service specified.";
	LEAVE add_new_person;
END IF;
	
INSERT INTO `queue`
(`firstName`,
`lastName`,
`organization`,
`type`,
`service`,
`queuedDate`
)
VALUES
(`firstName`,
`lastName`,
`organization`,
`in_type`,
IFNULL(`service`, NULL),
CURRENT_TIMESTAMP
);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_queue_entries`(
	IN `p_type` ENUM('Citizen','Anonymous'),
	OUT `p_output` TEXT
)
    READS SQL DATA
    SQL SECURITY INVOKER
BEGIN

DECLARE t_queue_rows INT UNSIGNED DEFAULT 0;
DECLARE counter INT UNSIGNED DEFAULT 0;
#These should not be NULL as that ruins CONCAT 
DECLARE v_temp TEXT DEFAULT '';
DECLARE `v_firstName`	varchar(50) DEFAULT '';
DECLARE `v_lastName`	varchar(50) DEFAULT '';
DECLARE `v_organization`	varchar(50) DEFAULT '';
DECLARE `v_type`	enum('Citizen', 'Anonymous') DEFAULT '';
DECLARE `v_service`	enum('Council Tax', 'Benefits', 'Rent') DEFAULT '';
DECLARE `v_queuedDate`	datetime;

/*Declaring two cursors and using only one is a necessary evil here, and 
still a bit neater that using a temporary table with two conditional SELECT INTO-s; I tried.*/
DECLARE queue_entries1 CURSOR FOR
	SELECT `firstName`, `lastName`, `organization`, `queue`.`type`, `service`, `queuedDate`
	FROM `queue`
	WHERE DATE(`queuedDate`) = CURDATE();
	
DECLARE queue_entries2 CURSOR FOR
	SELECT `firstName`, `lastName`, `organization`, `queue`.`type`, `service`, `queuedDate`
	FROM `queue` 
	WHERE DATE(`queuedDate`) = CURDATE() AND `queue`.`type` = `p_type`;

IF `p_type` = '' THEN 
	SET `p_type` = NULL; #some explicit safety measure to be on the safe side.
END IF;

IF `p_type` IS NULL THEN
	OPEN queue_entries1;
	SET t_queue_rows = FOUND_ROWS();
	IF(t_queue_rows > 0) THEN
	#--loop from here
	 queue_loop: WHILE counter < t_queue_rows DO
	 
	FETCH queue_entries1 INTO  `v_firstName`, `v_lastName`, `v_organization`, `v_type`, `v_service`, `v_queuedDate`;
		
	   SET v_temp = CONCAT(v_temp, 
		'{"firstName":"', `v_firstName`,
		'","lastName":"', `v_lastName`,
		'","organization":"', `v_organization`,
		'","type":"', `v_type`,
		'","service":"', `v_service`,
		'","queuedDate":"', `v_queuedDate`,'"}'
		);
	   
	   SET counter = counter + 1;
	   
	   IF counter < t_queue_rows THEN
		 SET v_temp = CONCAT(v_temp, ",");
	   END IF;
	 
	 END WHILE queue_loop;
	#--to here
	END IF;
	   
ELSE

OPEN queue_entries2;
SET t_queue_rows = FOUND_ROWS();
IF(t_queue_rows > 0) THEN
#--loop from here
 queue_loop: WHILE counter < t_queue_rows DO
 
FETCH queue_entries2 INTO  `v_firstName`, `v_lastName`, `v_organization`, `v_type`, `v_service`, `v_queuedDate`;
 	
	   SET v_temp = CONCAT(v_temp, 
		'{"firstName":"', `v_firstName`,
		'","lastName":"', `v_lastName`,
		'","organization":"', `v_organization`,
		'","type":"', `v_type`,
		'","service":"', `v_service`,
		'","queuedDate":"', `v_queuedDate`,'"}'
		);
   
   SET counter = counter + 1;
   
   IF counter < t_queue_rows THEN
     SET v_temp = CONCAT(v_temp, ",");
   END IF;
 
 END WHILE queue_loop;
#--to here
END IF;

END IF;

SET v_temp = CONCAT("[", v_temp, "]");

SET `p_output` = v_temp;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `queue`
--

CREATE TABLE IF NOT EXISTS `queue` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `firstName` varchar(50) DEFAULT NULL,
  `lastName` varchar(50) DEFAULT NULL,
  `organization` varchar(50) DEFAULT NULL,
  `type` enum('Citizen','Anonymous') DEFAULT NULL,
  `service` enum('Council Tax','Benefits','Rent') DEFAULT NULL,
  `queuedDate` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=83 ;

--
-- Dumping data for table `queue`
--

INSERT INTO `queue` (`id`, `firstName`, `lastName`, `organization`, `type`, `service`, `queuedDate`) VALUES
(1, 'Doctor', 'Who', NULL, 'Citizen', '', '2017-05-01 00:00:00'),
(2, 'Arya', 'Stark', 'Winterfell', 'Citizen', 'Council Tax', '2017-05-01 00:00:00'),
(3, NULL, NULL, NULL, 'Anonymous', 'Council Tax', '2017-11-27 22:28:06'),
(4, 'John', 'Snow', 'Winterfell', 'Citizen', 'Rent', '2017-11-27 22:28:06'),
(5, 'John', 'Smith', NULL, 'Citizen', 'Rent', '2017-11-27 22:28:06'),
(6, 'Steve', 'Harris', 'Iron Maiden', 'Citizen', '', '2017-11-27 22:28:06'),
(7, 'John', 'Petrucci', 'Dream Theater', 'Citizen', 'Council Tax', '2017-11-27 22:28:06'),
(8, 'Steve', 'Vai', NULL, 'Citizen', 'Council Tax', '2017-11-27 22:28:06'),
(9, NULL, NULL, NULL, 'Anonymous', 'Rent', '2017-11-27 22:28:06'),
(26, 'Jack', 'Sparrow', '', 'Citizen', 'Council Tax', '2017-11-28 20:28:04'),
(28, 'Joe', 'Mclane', 'Yippi', 'Citizen', 'Benefits', '2017-11-28 20:38:33'),
(29, 'Balazs', 'Dukat', '', 'Citizen', 'Rent', '2017-11-28 20:45:40'),
(30, 'Balazs', 'Dukat', '', 'Citizen', 'Rent', '2017-11-28 20:45:51'),
(31, 'Joe', 'Mclane', 'Yippi', 'Citizen', 'Benefits', '2017-11-28 21:03:00'),
(32, 'Balazs', 'Dukat', '', 'Citizen', 'Rent', '2017-11-28 21:03:12'),
(33, 'Balazs', 'Dukat', '', 'Citizen', 'Council Tax', '2017-11-28 21:42:41'),
(34, 'Balazs', 'Dukat', '', 'Citizen', 'Council Tax', '2017-11-28 23:29:54'),
(35, 'Balazs', 'Dukat', '', 'Citizen', 'Council Tax', '2017-11-29 00:28:10'),
(36, 'Balazs', 'Dukat', '', 'Citizen', 'Benefits', '2017-11-29 00:28:18'),
(37, 'Balazs', 'Dukat', '', 'Anonymous', 'Benefits', '2017-11-29 00:28:53'),
(38, 'Jack', 'Sparrow', 'Pirates', 'Citizen', 'Benefits', '2017-11-29 00:29:16'),
(39, 'Jack', 'Sparrow', 'Pirates', 'Citizen', 'Benefits', '2017-11-29 03:02:09'),
(40, 'Jack', 'Sparrow', 'Pirates', 'Citizen', 'Benefits', '2017-11-29 03:10:22'),
(41, 'A', 'B', '', 'Citizen', 'Council Tax', '2017-11-29 03:55:45'),
(75, 'test', 'testest', '', 'Citizen', 'Council Tax', '2017-11-29 05:33:10'),
(76, 'test', 'testest', '', 'Citizen', 'Rent', '2017-11-29 05:33:25'),
(77, 'test', 'testest', '', 'Citizen', 'Benefits', '2017-11-29 05:34:10'),
(78, 'test', 'testest', '', 'Citizen', 'Benefits', '2017-11-29 05:34:15'),
(80, 'Balazs', 'Dukat', '', 'Citizen', 'Council Tax', '2018-01-03 16:28:06'),
(81, 'Balazs', 'Dukat', '', 'Citizen', 'Council Tax', '2018-01-03 16:32:22'),
(82, 'T', 'R', 'TR Ltd.', 'Anonymous', 'Council Tax', '2018-01-03 16:52:05');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
