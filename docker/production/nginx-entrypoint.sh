#!/bin/bash
set -e

# Wait for ERPNext application to be ready
echo "Waiting for ERPNext application to be ready..."
timeout=300
counter=0

while ! curl -f http://erpnext:8000/api/method/ping 2>/dev/null; do
    if [ $counter -gt $timeout ]; then
        echo "ERPNext application failed to start within ${timeout} seconds"
        exit 1
    fi
    echo "ERPNext not ready yet, waiting..."
    sleep 5
    counter=$((counter + 5))
done

echo "ERPNext application is ready!"

# Start nginx
echo "Starting nginx..."
exec nginx -g "daemon off;"
