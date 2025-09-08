#!/bin/bash

# Stop and remove container (ignore errors if container doesn't exist)
docker stop netflix 2>/dev/null || true
docker rm netflix 2>/dev/null || true

# Clean up any dangling images (ignore errors)
docker image prune -f 2>/dev/null || true

echo "Stop script completed successfully"