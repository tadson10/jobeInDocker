<?php
$user = $argv[1];
$pass = $argv[2];

$mysqli = new mysqli("localhost", "root");

// Check connection
if ($mysqli->connect_errno) {
  echo "Failed to connect to MySQL: " . $mysqli->connect_error;
  exit();
}

// Create database
$mysqli->query("CREATE DATABASE IF NOT EXISTS jobe");

// create user
$mysqli->query("CREATE USER IF NOT EXISTS '$user'@'localhost'IDENTIFIED BY '$pass'");
$mysqli->query("GRANT ALL PRIVILEGES ON jobe.* TO 'jobe'@'localhost'");

$mysqli->query("use jobe");

// CREATE "keys" table for API keys
$mysqli->query("CREATE TABLE IF NOT EXISTS `keys` ( 
       `id` INT(11) NOT NULL AUTO_INCREMENT,
       `user_id` INT(11) NOT NULL,
       `key` VARCHAR(40) NOT NULL,
       `level` INT(2) NOT NULL,
       `ignore_limits` TINYINT(1) NOT NULL DEFAULT '0',
       `is_private_key` TINYINT(1)  NOT NULL DEFAULT '0',
       `ip_addresses` TEXT NULL DEFAULT NULL,
       `date_created` INT(11) NOT NULL,
       PRIMARY KEY (`id`)
   ) ENGINE=InnoDB DEFAULT CHARSET=utf8");

// INSERT sample api key for testing
$count = $mysqli->query("SELECT COUNT(1) AS NUM FROM jobe.keys WHERE keys.key = 'dcc9a835-9750-4725-af5b-2c839908f71'");

if ($count->fetch_assoc()["NUM"] == 0) {
  $sql = "INSERT INTO jobe.keys (`user_id`, `key`, `level`, `date_created`) VALUES (123456, 'dcc9a835-9750-4725-af5b-2c839908f71', 1, UNIX_TIMESTAMP())";
  $insert = $mysqli->query($sql);

  if ($insert === TRUE) {
    echo "Sample API key inserted";
  } else {
    echo "Error: " . $sql . "<br>" . $mysqli->error . ` \n`;
  }
}

// CREATE "logs" table
$mysqli->query("CREATE TABLE IF NOT EXISTS `logs` (
       `id` INT(11) NOT NULL AUTO_INCREMENT,
       `uri` VARCHAR(255) NOT NULL,
       `method` VARCHAR(6) NOT NULL,
       `params` MEDIUMTEXT DEFAULT NULL,
       `api_key` VARCHAR(40) NOT NULL,
       `ip_address` VARCHAR(45) NOT NULL,
       `time` INT(11) NOT NULL,
       `rtime` FLOAT DEFAULT NULL,
       `authorized` VARCHAR(1) NOT NULL,
       `response_code` smallint(3) DEFAULT '0',
       PRIMARY KEY (`id`)
   ) ENGINE=InnoDB DEFAULT CHARSET=utf8");

$mysqli->close();
