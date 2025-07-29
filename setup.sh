#!/bin/bash
echo "Building and starting Docker Compose project..."
docker compose up --build -d

echo "Waiting for Joomla to be healthy..."
until [ "$(docker inspect --format='{{.State.Health.Status}}' joomla_container)" = "healthy" ]; do
  echo "Waiting for Joomla..."
  sleep 3
done
echo "Joomla is healthy."

echo "Containers are healthy. Setup complete! Joomla should be running at http://localhost:8080"
echo "To see logs: docker compose logs -f"

