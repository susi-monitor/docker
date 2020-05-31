<?php

$settings = array(
    'BASEURL',
    'CRON_ENABLED'
);

foreach ($settings as $var) {
    $env = getenv($var);
    if (!isset($_ENV[$var]) && $env !== false) {
        $_ENV[$var] = $env;
    }
}

$cronEnabled = isset($_ENV['CRON_ENABLED']) ? $_ENV['CRON_ENABLED'] : false;
$baseUrl = rtrim(isset($_ENV['BASEURL']) ? $_ENV['BASEURL'] : false, '/');

if ($cronEnabled == true) {
    echo "[CRON] Checking status of targets - status: ".shell_exec('curl -s '.$baseUrl.'/data/update');
}