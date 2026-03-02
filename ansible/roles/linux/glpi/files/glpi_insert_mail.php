<?php
// usage: php glpi_password.php db_host db_name db_user db_password

if ($argc !== 7) {
    echo "Usage: php {$argv[0]} db_host db_name db_user db_password user email\n";
    exit(1);
}

$db_host     = $argv[1];
$db_name     = $argv[2];
$db_user     = $argv[3];
$db_password = $argv[4];
$user        = $argv[5];
$email       = $argv[6];

$mysqli = new mysqli($db_host, $db_user, $db_password, $db_name);
if ($mysqli->connect_error) {
    die("Connection failed: " . $mysqli->connect_error . "\n");
}
$mysqli->set_charset('utf8mb4');

// Mise à jour du mot de passe + timestamp DATETIME
$sql = "
    INSERT INTO glpi_useremails (users_id, email, is_default)
    VALUES (
        (SELECT id FROM glpi_users WHERE name = ?),
        ?,
        1
    ) 
    ON DUPLICATE KEY UPDATE email = VALUES(email);
";

$stmt = $mysqli->prepare($sql);
$stmt->bind_param("ss", $user, $email);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        echo "Email setup successfully'\n";
    } else {
        echo "No user updated.\n";
    }
} else {
    echo "SQL error: " . $stmt->error . "\n";
}

$stmt->close();
$mysqli->close();
