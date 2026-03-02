<?php
// usage: php glpi_password.php db_host db_name db_user db_password glpi_user new_password

if ($argc !== 7) {
    echo "Usage: php {$argv[0]} db_host db_name db_user db_password glpi_user new_password\n";
    exit(1);
}

$db_host     = $argv[1];
$db_name     = $argv[2];
$db_user     = $argv[3];
$db_password = $argv[4];
$glpi_user   = $argv[5];
$new_pass    = $argv[6];

// Hash bcrypt compatible GLPI
$hash = password_hash($new_pass, PASSWORD_DEFAULT);

$mysqli = new mysqli($db_host, $db_user, $db_password, $db_name);
if ($mysqli->connect_error) {
    die("Connection failed: " . $mysqli->connect_error . "\n");
}
$mysqli->set_charset('utf8mb4');

// Génère le datetime MySQL correct
$datetime = date("Y-m-d H:i:s");

// Mise à jour du mot de passe + timestamp DATETIME
$sql = "
    UPDATE glpi_users
    SET password = ?, password_last_update = ?
    WHERE name = ?
";

$stmt = $mysqli->prepare($sql);
$stmt->bind_param("sss", $hash, $datetime, $glpi_user);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        echo "Password updated successfully for user '{$glpi_user}'\n";
    } else {
        echo "No user updated. Check username or authtype.\n";
    }
} else {
    echo "SQL error: " . $stmt->error . "\n";
}

$stmt->close();
$mysqli->close();
