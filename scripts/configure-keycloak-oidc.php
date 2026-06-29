<?php

declare(strict_types=1);

chdir('/var/www/ilias');

if (!file_exists('ilias.ini.php')) {
    fwrite(STDERR, "ILIAS is not installed yet.\n");
    exit(1);
}

require_once 'vendor/composer/vendor/autoload.php';

$_SERVER['HTTP_HOST'] = $_SERVER['HTTP_HOST'] ?? 'localhost:28084';
$_SERVER['SERVER_NAME'] = $_SERVER['SERVER_NAME'] ?? 'localhost';
$_SERVER['SERVER_PORT'] = $_SERVER['SERVER_PORT'] ?? '28084';
$_SERVER['REQUEST_URI'] = $_SERVER['REQUEST_URI'] ?? '/ilias.php';
$_SERVER['SCRIPT_NAME'] = $_SERVER['SCRIPT_NAME'] ?? '/ilias.php';
$_SERVER['PHP_SELF'] = $_SERVER['PHP_SELF'] ?? '/ilias.php';
$_GET['client_id'] = $_GET['client_id'] ?? 'myilias';

ilInitialisation::initILIAS();

$issuer = getenv('KEYCLOAK_ISSUER') ?: 'http://1up-keycloak.localhost:28080/realms/university-dev';
$clientId = getenv('KEYCLOAK_CLIENT_ID') ?: 'ilias';
$clientSecret = getenv('KEYCLOAK_CLIENT_SECRET') ?: 'ilias-dev-secret';

$settings = ilOpenIdConnectSettings::getInstance();
$settings->setActive(true);
$settings->setProvider(rtrim($issuer, '/'));
$settings->setClientId($clientId);
$settings->setSecret($clientSecret);
$settings->setLoginElementType(ilOpenIdConnectSettings::LOGIN_ELEMENT_TYPE_TXT);
$settings->setLoginElementText('Unreal University Login');
$settings->setLoginPromptType(ilOpenIdConnectSettings::LOGIN_STANDARD);
$settings->setLogoutScope(ilOpenIdConnectSettings::LOGOUT_SCOPE_LOCAL);
$settings->useCustomSession(false);
$settings->setSessionDuration(60);
$settings->allowSync(true);
$settings->setUidField('preferred_username');
$settings->setAdditionalScopes(['profile', 'email']);
$settings->setValidateScopes(ilOpenIdConnectSettings::URL_VALIDATION_NONE);

$settings->setProfileMappingFieldValue('firstname', 'given_name');
$settings->setProfileMappingFieldUpdate('firstname', true);
$settings->setProfileMappingFieldValue('lastname', 'family_name');
$settings->setProfileMappingFieldUpdate('lastname', true);
$settings->setProfileMappingFieldValue('email', 'email');
$settings->setProfileMappingFieldUpdate('email', true);

$roleMappings = [];
foreach ([2 => 'admin', 3 => 'teacher', 4 => 'student', 5 => 'guest'] as $roleId => $keycloakRole) {
    $roleMappings[$roleId] = [
        'value' => 'university_role::' . $keycloakRole,
        'update' => true,
    ];
}

$settings->setRole(4);
$settings->setRoleMappings($roleMappings);
$settings->save();

echo "Configured ILIAS OpenID Connect for {$issuer}\n";
