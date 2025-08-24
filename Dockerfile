# Multi-stage build for ERPNext from Git source
FROM node:18-bullseye-slim as assets

# Install system dependencies for building assets
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /home/frappe/frappe-bench

# Clone Frappe framework (required for ERPNext)
RUN git clone https://github.com/frappe/frappe --branch version-15 --depth 1 apps/frappe

# Clone ERPNext from official repository (temporarily until NextERP fork is ready)
# Will use your fork once it's properly set up
RUN git clone https://github.com/frappe/erpnext --branch version-15 --depth 1 apps/erpnext

# Create sites directory and apps.txt file (required for Frappe build)
RUN mkdir -p sites
RUN echo "frappe" > sites/apps.txt
RUN echo "erpnext" >> sites/apps.txt

# Install Node dependencies and build assets
RUN cd apps/frappe && yarn install --frozen-lockfile
RUN cd apps/erpnext && yarn install --frozen-lockfile
RUN cd apps/frappe && yarn build

# Production stage
FROM python:3.11-slim-bullseye as production

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    mariadb-client \
    postgresql-client \
    wait-for-it \
    wkhtmltopdf \
    && rm -rf /var/lib/apt/lists/*

# Create frappe user
RUN groupadd -g 1000 frappe \
    && useradd -u 1000 -g 1000 -m -s /bin/bash frappe

# Set working directory
WORKDIR /home/frappe/frappe-bench

# Copy built assets from previous stage
COPY --from=assets --chown=frappe:frappe /home/frappe/frappe-bench/apps ./apps

# Ensure frappe user owns the entire directory
RUN chown -R frappe:frappe /home/frappe/frappe-bench

# Install Python dependencies
USER frappe
RUN python -m venv env
RUN ./env/bin/pip install --upgrade pip setuptools wheel

# Install Frappe
RUN ./env/bin/pip install -e ./apps/frappe

# Install ERPNext
RUN ./env/bin/pip install -e ./apps/erpnext

# Create sites directory
RUN mkdir -p sites/assets

# Copy configuration files
COPY --chown=frappe:frappe docker/production/common_site_config.json sites/common_site_config.json
COPY --chown=frappe:frappe docker/production/erpnext-entrypoint.sh /usr/local/bin/erpnext-entrypoint.sh
COPY --chown=frappe:frappe docker/production/nginx-entrypoint.sh /usr/local/bin/nginx-entrypoint.sh
COPY --chown=frappe:frappe docker/production/worker-entrypoint.sh /usr/local/bin/worker-entrypoint.sh

# Make scripts executable
USER root
RUN chmod +x /usr/local/bin/erpnext-entrypoint.sh /usr/local/bin/nginx-entrypoint.sh /usr/local/bin/worker-entrypoint.sh

# Install nginx
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*
COPY docker/production/nginx.conf /etc/nginx/nginx.conf

USER frappe

# Set environment variables
ENV FRAPPE_PY=erpnext \
    FRAPPE_PY_VERSION=0.0.1 \
    FRAPPE_DEV=0

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000 || exit 1

# Default command
CMD ["./env/bin/gunicorn", "--chdir=.", "--bind=0.0.0.0:8000", "--threads=4", "--timeout=120", "frappe.app:application", "--preload"]
