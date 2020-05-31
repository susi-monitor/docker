<?php

/* Prepare the environment */
$settings = array(
    'BASEURL',
    'ADMIN_PASSWORD',
    'PAGE_TITLE',
    'NOTIFICATIONS_ENABLED',
    'TEAMS_WEBHOOK_URL',
    'UA_STRING',
    'PROXY_ENABLED',
    'PROXY_HOST',
    'PROXY_CREDENTIALS',
    'VERIFYHOST',
    'VERIFYPEER',
    'SHELL_EXEC_CURL'
);

foreach ($settings as $var) {
    $env = getenv($var);
    if (!isset($_ENV[$var]) && $env !== false) {
        $_ENV[$var] = $env;
    }
}

require_once ('susi-version.php');

/*
| -------------------------------------------------------------------
| SuSi Monitor configuration
| -------------------------------------------------------------------
| This file contains configuration parameters needed to customize
| your instance.
| -------------------------------------------------------------------
*/

/*
| -------------------------------------------------------------------
| Customization
| -------------------------------------------------------------------
*/

/* Base URL of your site - typically http://example.com/
This value HAS TO be set if you wish to use a domain name */
defined('BASEURL')  OR define('BASEURL', isset($_ENV['BASEURL']) ? $_ENV['BASEURL'] : '');

/* Administration panel access password */
defined('ADMIN_PASSWORD')  OR define('ADMIN_PASSWORD', isset($_ENV['ADMIN_PASSWORD']) ? $_ENV['ADMIN_PASSWORD'] : 'admin');

/* Customized title */
define('PAGE_TITLE', isset($_ENV['PAGE_TITLE']) ? $_ENV['PAGE_TITLE'] : 'SuSi Monitor');

/*
| -------------------------------------------------------------------
| Notifications
| -------------------------------------------------------------------
*/

/* Will not show option to enable notifications for target if set to false */
defined('NOTIFICATIONS_ENABLED') OR define('NOTIFICATIONS_ENABLED', isset($_ENV['NOTIFICATIONS_ENABLED']) ? $_ENV['NOTIFICATIONS_ENABLED'] : false);

/* Webhook URL for Microsoft Teams
  Instruction on how to obtain that: https://docs.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook */
defined('TEAMS_WEBHOOK_URL')  OR define('TEAMS_WEBHOOK_URL', isset($_ENV['TEAMS_WEBHOOK_URL']) ? $_ENV['TEAMS_WEBHOOK_URL'] : '');

/*
| -------------------------------------------------------------------
| Connection and client parameters
| -------------------------------------------------------------------
*/

/* Custom User Agent string */
defined('UA_STRING')  OR define('UA_STRING', 'SuSi Monitor v'.RELEASE_VERSION);

/* Proxy settings */
defined('PROXY_ENABLED')  OR define('PROXY_ENABLED', isset($_ENV['PROXY_ENABLED']) ? $_ENV['PROXY_ENABLED'] : 0);
defined('PROXY_HOST')  OR define('PROXY_HOST', isset($_ENV['PROXY_HOST']) ? $_ENV['PROXY_HOST'] : 'localhost');
defined('PROXY_PORT')  OR define('PROXY_PORT', isset($_ENV['PROXY_PORT']) ? $_ENV['PROXY_PORT'] : 8080);
defined('PROXY_CREDENTIALS')  OR define('PROXY_CREDENTIALS', isset($_ENV['PROXY_CREDENTIALS']) ? $_ENV['PROXY_CREDENTIALS'] : '');

/* MITM protection - disabled by default - set "2" to enforce checks */
defined('VERIFYHOST')  OR define('VERIFYHOST', isset($_ENV['VERIFYHOST']) ? $_ENV['VERIFYHOST'] : 0);
defined('VERIFYPEER')  OR define('VERIFYPEER', isset($_ENV['VERIFYPEER']) ? $_ENV['VERIFYPEER'] : 0);

/* If set to true curl calls will be done using curl binary rather than libcurl */
defined('SHELL_EXEC_CURL')  OR define('SHELL_EXEC_CURL', isset($_ENV['SHELL_EXEC_CURL']) ? $_ENV['SHELL_EXEC_CURL'] : 0);