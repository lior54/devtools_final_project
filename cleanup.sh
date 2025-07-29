#!/bin/bash

echo "Stopping and removing containers, networks, volumes, and images..."

docker compose down --rmi all --volumes --remove-orphans

echo "Docker Compose project cleaned up successfully!"

