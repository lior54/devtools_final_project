#!/bin/sh
echo "🔧 Running Joomla user creation script..."
php /create-user.php || echo "⚠️ User creation script failed or user may already exist."

echo "🚀 Starting Apache..."
exec apache2-foreground

