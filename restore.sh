#!/bin/bash

if ! command -v mysqladmin >/dev/null 2>&1; then
    echo "mysqladmin is not installed, use sudo apt update && sudo apt install MySQL-client-core-8.0"
    exit 1
fi

echo "Copying backup file from git"
git show origin/main:my-joomla.backup.sql.gz > my-joomla.backup.sql.gz
echo "Restoring Joomla database from backup..."
gunzip < ./my-joomla.backup.sql.gz | docker exec -i joomla_mysql sh -c "exec mysql -h 127.0.0.1 -uroot -pmy-secret-pw --force my-db"

echo "Restarting joomla..."
docker restart joomla_container

echo "Waiting for Joomla to be healthy..."
until [ "$(docker inspect --format='{{.State.Health.Status}}' joomla_container)" = "healthy" ]; do
  sleep 3
done
echo "Restore done"
