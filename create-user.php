<?php
define('_JEXEC', 1);
define('JPATH_BASE', __DIR__ . '/var/www/html');
require_once JPATH_BASE . '/includes/defines.php';
require_once JPATH_BASE . '/includes/framework.php';

$app = JFactory::getApplication('site');
$user = new JUser;

$data = array(
    "name" => "Auto User",
    "username" => "autouser",
    "password" => "securepass123",
    "password2" => "securepass123",
    "email" => "auto@example.com",
    "groups" => array("8") // Super Administrator
);

if (!$user->bind($data)) {
    echo "❌ Bind error: " . $user->getError();
    exit(1);
}
if (!$user->save()) {
    echo "❌ Save error: " . $user->getError();
    exit(1);
}
echo "✅ Joomla user created successfully!\n";

