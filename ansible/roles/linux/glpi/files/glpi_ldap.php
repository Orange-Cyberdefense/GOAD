<?php

// Usage : php glpi_ldap_add.php <db_host> <db_name> <db_user> <db_pass> <ldap_name> <ldap_host> <ldap_basedn> <ldap_rootdn> <ldap_port> <ldap_filter> <ldap_password>

if ($argc !== 12) {
    echo "Usage: php {$argv[0]} <db_host> <db_name> <db_user> <db_pass> <ldap_name> <ldap_host> <ldap_basedn> <ldap_rootdn> <ldap_port> <ldap_filter> <ldap_password>\n";
    exit(1);
}

// --- Assignation des arguments ---
$db_host        = $argv[1];
$db_name        = $argv[2];
$db_user        = $argv[3];
$db_password    = $argv[4];

$ldap_name      = $argv[5];
$ldap_host      = $argv[6];
$ldap_basedn    = $argv[7];
$ldap_rootdn    = $argv[8];
$ldap_port      = (int)$argv[9];
$ldap_filter    = $argv[10];
$ldap_password  = $argv[11];

// Champs LDAP GLPI
$ldap_login     = "samaccountname";
$ldap_email     = "mail";
$ldap_realname  = "sn";
$ldap_firstname = "givenname";
$ldap_phone     = "telephonenumber";
$ldap_is_default= 1;
$ldap_is_active = 1;

// --- Fonction d'encryptage GLPI ---
function encrypt_string(string $string, string $key): string
{
    $nonce = random_bytes(SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_NPUBBYTES);

    $encrypted = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
        $string,
        $nonce,
        $nonce,
        $key
    );

    return base64_encode($nonce . $encrypted);
}

// --- Lecture de la clé GLPI ---
$key = file_get_contents("/var/www/html/glpi/config/glpicrypt.key");
if (!$key) {
    die("Cannot read GLPI encryption key\n");
}

$encrypted_pass = encrypt_string($ldap_password, $key);

// --- Connexion DB ---
$conn = new mysqli($db_host, $db_user, $db_password, $db_name);
if ($conn->connect_error) {
    die("Database connection error: " . $conn->connect_error . "\n");
}

// --- Vérifier si l'entrée LDAP existe déjà ---
$check = $conn->prepare("SELECT id FROM glpi_authldaps WHERE name = ?");
$check->bind_param("s", $ldap_name);
$check->execute();
$check->store_result();

if ($check->num_rows > 0) {
    // --- UPDATE ---
    $check->bind_result($existing_id);
    $check->fetch();
    $check->close();

    $sql = "
        UPDATE glpi_authldaps
        SET host=?, basedn=?, rootdn=?, port=?, `condition`=?, login_field=?, email1_field=?, 
            realname_field=?, firstname_field=?, phone_field=?, is_default=?, is_active=?, rootdn_passwd=?
        WHERE id=?
    ";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param(
        "sssissssssissi",
        $ldap_host,
        $ldap_basedn,
        $ldap_rootdn,
        $ldap_port,
        $ldap_filter,
        $ldap_login,
        $ldap_email,
        $ldap_realname,
        $ldap_firstname,
        $ldap_phone,
        $ldap_is_default,
        $ldap_is_active,
        $encrypted_pass,
        $existing_id
    );

    if ($stmt->execute()) {
        echo "LDAP configuration UPDATED successfully (id=$existing_id).\n";
    } else {
        echo "SQL UPDATE error: " . $stmt->error . "\n";
    }

    $stmt->close();

} else {
    // --- INSERT ---
    $check->close();

    $sql = "
        INSERT INTO glpi_authldaps
            (name, host, basedn, rootdn, port, `condition`, login_field, email1_field,
             realname_field, firstname_field, phone_field, is_default, is_active, rootdn_passwd)
        VALUES (
            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
        )
    ";

    $stmt = $conn->prepare($sql);

    $stmt->bind_param(
        "ssssissssssiss",
        $ldap_name,
        $ldap_host,
        $ldap_basedn,
        $ldap_rootdn,
        $ldap_port,
        $ldap_filter,
        $ldap_login,
        $ldap_email,
        $ldap_realname,
        $ldap_firstname,
        $ldap_phone,
        $ldap_is_default,
        $ldap_is_active,
        $encrypted_pass
    );

    if ($stmt->execute()) {
        echo "LDAP configuration INSERTED successfully.\n";
    } else {
        echo "SQL INSERT error: " . $stmt->error . "\n";
    }

    $stmt->close();
}

$conn->close();
