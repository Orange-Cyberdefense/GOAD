<?php
if ($argc !== 7) {
    echo "Usage: php {$argv[0]} db_host db_name db_user db_password config value\n";
    exit(1);
}

$db_host     = $argv[1];
$db_name     = $argv[2];
$db_user     = $argv[3];
$db_password = $argv[4];
$config      = $argv[5];
$value       = $argv[6];

$mysqli = new mysqli($db_host, $db_user, $db_password, $db_name);
if ($mysqli->connect_error) {
    die("Connection failed: " . $mysqli->connect_error . "\n");
}
$mysqli->set_charset('utf8mb4');

// Génère le datetime MySQL correct
$datetime = date("Y-m-d H:i:s");

// Mise à jour de la configuration
$sql = "
    UPDATE glpi_configs
    SET value = ?
    WHERE name = ?
";

$stmt = $mysqli->prepare($sql);
$stmt->bind_param("ss", $value, $config);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        echo "Configuration updated successfully for config '{$config}'\n";
    } else {
        echo "No configuration udpated.\n";
    }
} else {
    echo "SQL error: " . $stmt->error . "\n";
}

$stmt->close();
$mysqli->close();
