#!/bin/bash

if ! command -v mysqldump >/dev/null 2>&1; then
    echo "mysqldump is not installed, use sudo apt update && sudo apt install MySQL-client-core-8.0"
    exit 1
fi

echo "Backing up database"
docker exec joomla_mysql sh -c 'exec mysqldump --all-databases -uroot -pmy-secret-pw' | gzip > my-joomla.backup.sql.gz
echo "Backup complete, backup file: my-joomla.backup.sql.gz"

