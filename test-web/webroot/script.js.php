<?php

header('Content-Type: application/javascript');
header('cache-control: private, no-cache, no-store, must-revalidate');
header('expires: 0');

$domain = $_SERVER['HTTP_HOST'];
$code =
<<<EOT
    (() => {
        document.querySelector(
            'x-indicator[x-type="external_script"][x-domain="$domain"]'
        )?.setAttribute('data-js-active', '');
    })();
EOT;

print($code);