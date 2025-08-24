#!/bin/bash
set -e

# Wait for database to be ready
echo "Waiting for database to be ready..."
until pg_isready -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}"; do
  echo "Database not ready, waiting..."
  sleep 2
done

echo "Database is ready!"

# Navigate to bench directory
cd /home/frappe/frappe-bench

# Initialize site if it doesn't exist
if [ ! -d "sites/${SITE_NAME:-localhost}" ]; then
  echo "Creating new site: ${SITE_NAME:-localhost}"
  ./env/bin/python -m frappe --create-site "${SITE_NAME:-localhost}" \
    --db-type postgres \
    --db-host "${DB_HOST}" \
    --db-port "${DB_PORT}" \
    --db-name "${DB_NAME}" \
    --db-user "${DB_USER}" \
    --db-password "${DB_PASSWORD}" \
    --admin-password "${ADMIN_PASSWORD:-admin}" \
    --install-app erpnext
fi

# Set site as current
echo "${SITE_NAME:-localhost}" > sites/currentsite.txt

# Start worker based on queue type
QUEUE_TYPE=${1:-default}

echo "Starting worker for queue: ${QUEUE_TYPE}"
exec ./env/bin/python -m frappe.utils.bench worker --queue "${QUEUE_TYPE}" --site "${SITE_NAME:-localhost}"
