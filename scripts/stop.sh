#!/bin/bash

# Stop and remove container (ignore errors if container doesn't exist)
docker stop netflix 2>/dev/null || echo "Container netflix not running"
docker rm netflix 2>/dev/null || echo "Container netflix not found"

# Clean up any dangling images
docker image prune -f 2>/dev/null || true

echo "Stop script completed successfully"
exit 0