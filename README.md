# ERPNext Deployment with GitHub + Dokploy

This repository provides a complete setup for deploying ERPNext using your own forked repository with Dokploy's Git integration. This approach allows you to:

- ✅ Make custom modifications to ERPNext
- ✅ Push updates directly to your fork
- ✅ Auto-deploy changes via Dokploy
- ✅ Stay synced with upstream ERPNext updates
- ✅ Run production-ready deployments with PostgreSQL + Redis

## 🚀 Quick Start

### 1. Fork ERPNext Repository

1. Go to [https://github.com/frappe/erpnext](https://github.com/frappe/erpnext)
2. Click **"Fork"** in the top-right corner
3. Fork to your GitHub account/organization

### 2. Clone This Deployment Repository

```bash
# Clone this deployment configuration
git clone <your-deployment-repo-url>
cd erpnext-dokploy-deployment

# Copy environment template
cp .env.example .env
```

### 3. Configure Environment Variables

Edit `.env` file with your settings:

```bash
# Update these values in .env
ERPNEXT_REPO_URL=https://github.com/AltFl0w/NextERP.git
ERPNEXT_BRANCH=version-15
DOMAIN=your-erpnext-domain.com
SITE_NAME=your-erpnext-domain.com
DB_PASSWORD=your_secure_db_password_here
ADMIN_PASSWORD=your_secure_admin_password_here
```

### 4. Deploy with Dokploy

1. **Add Repository to Dokploy**:
   - Connect your deployment repository (this one) to Dokploy
   - Set up auto-deployment on `main` branch pushes

2. **Environment Variables**:
   - Add all `.env` variables to Dokploy's environment configuration
   - Make sure `DB_PASSWORD` and `ADMIN_PASSWORD` are secure

3. **Deploy**:
   - Push changes to trigger deployment
   - Dokploy will build from your forked ERPNext repo and deploy all services

## 📁 Repository Structure

```
├── Dockerfile                          # Multi-stage build for ERPNext
├── docker-compose.yml                  # Complete service stack
├── .env.example                        # Environment variables template
├── docker/production/
│   ├── common_site_config.json        # ERPNext site configuration
│   ├── worker-entrypoint.sh           # Worker process startup script
│   ├── nginx.conf                     # Nginx reverse proxy config
│   └── nginx-entrypoint.sh            # Nginx startup script
└── README.md                          # This documentation
```

## 🔧 Services Included

| Service | Description | Port/Access |
|---------|-------------|-------------|
| **erpnext** | Main ERPNext application | `:8000` |
| **queue-default** | Background job worker (default) | Internal |
| **queue-short** | Background job worker (short tasks) | Internal |
| **queue-long** | Background job worker (long tasks) | Internal |
| **scheduler** | Cron job scheduler | Internal |
| **websocket** | Real-time WebSocket server | `:9000` |
| **db** | PostgreSQL 15 database | `:5432` |
| **redis-cache** | Redis for caching | `:6379` |
| **redis-queue** | Redis for job queues | `:6379` |
| **redis-socketio** | Redis for WebSocket sessions | `:6379` |
| **nginx** | Reverse proxy & static files | `:8080` |

## 🛠️ Development Workflow

### Making Custom Changes

1. **Clone your forked ERPNext repository**:
   ```bash
   git clone https://github.com/AltFl0w/NextERP.git
   cd NextERP
   ```

2. **Make your customizations**:
   ```bash
   # Create a new branch for your feature
   git checkout -b custom-feature
   
   # Make your changes
   # Edit files, add custom apps, modify existing functionality
   
   # Commit changes
   git add .
   git commit -m "Add custom feature"
   
   # Push to your fork
   git push origin custom-feature
   ```

3. **Deploy your changes**:
   ```bash
   # Merge to main branch (or your deployment branch)
   git checkout main
   git merge custom-feature
   git push origin main
   
   # Update deployment repo to trigger rebuild
   cd ../erpnext-dokploy-deployment
   git commit --allow-empty -m "Trigger deployment with latest ERPNext changes"
   git push origin main
   ```

### Staying Updated with Upstream

Keep your fork synchronized with the official ERPNext repository:

```bash
cd erpnext

# Add upstream remote (one-time setup)
git remote add upstream https://github.com/frappe/erpnext.git

# Fetch latest changes from upstream
git fetch upstream

# Merge upstream changes into your main branch
git checkout main
git merge upstream/version-15

# Push updated main branch to your fork
git push origin main

# Trigger deployment
cd ../erpnext-dokploy-deployment
git commit --allow-empty -m "Update ERPNext to latest upstream version"
git push origin main
```

## 🌍 Environment Management

### Production Setup

For production deployments:

```bash
# Production environment variables
FRAPPE_DEV=0
DOMAIN=erpnext.yourcompany.com
SITE_NAME=erpnext.yourcompany.com

# Strong passwords
DB_PASSWORD=your_very_secure_db_password_here
ADMIN_PASSWORD=your_very_secure_admin_password_here

# Backup configuration (optional)
BACKUP_ENCRYPTION_KEY=your_backup_encryption_key_here
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
S3_BUCKET_NAME=your-backup-bucket
```

### Development/Staging Setup

For development or staging:

```bash
# Development environment
FRAPPE_DEV=1
DOMAIN=staging.erpnext.yourcompany.com
SITE_NAME=staging.erpnext.yourcompany.com
ERPNEXT_BRANCH=develop  # or your feature branch
```

## 🔍 Monitoring & Troubleshooting

### Check Service Status

```bash
# View all service logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f erpnext
docker-compose logs -f db
docker-compose logs -f queue-default

# Check service health
docker-compose ps
```

### Common Issues

**Database Connection Issues**:
```bash
# Check database connectivity
docker-compose exec erpnext pg_isready -h db -U erpnext

# Reset database (CAUTION: This deletes all data)
docker-compose down -v
docker-compose up -d
```

**Build Issues**:
```bash
# Force rebuild without cache
docker-compose build --no-cache erpnext

# Clean up build artifacts
docker system prune -a
```

**Site Access Issues**:
```bash
# Recreate site
docker-compose exec erpnext bench new-site your-site-name \
  --admin-password your-password \
  --install-app erpnext
```

## 🚢 Deployment Strategies

### Branch-Based Deployments

Set up multiple environments with different branches:

1. **Production**: `main` branch → `production.erpnext.com`
2. **Staging**: `develop` branch → `staging.erpnext.com`
3. **Feature Testing**: `feature/*` branches → `feature-name.erpnext.com`

### Dokploy Configuration Examples

#### Production Environment
```yaml
# dokploy.production.yml
environment:
  - ERPNEXT_BRANCH=main
  - DOMAIN=erpnext.yourcompany.com
  - FRAPPE_DEV=0
```

#### Staging Environment
```yaml
# dokploy.staging.yml
environment:
  - ERPNEXT_BRANCH=develop
  - DOMAIN=staging.erpnext.yourcompany.com
  - FRAPPE_DEV=1
```

## 🔒 Security Considerations

### Production Security Checklist

- [ ] Use strong passwords for `DB_PASSWORD` and `ADMIN_PASSWORD`
- [ ] Enable SSL/TLS with valid certificates (handled by Dokploy/Traefik)
- [ ] Configure firewall rules (database should not be publicly accessible)
- [ ] Set up regular automated backups
- [ ] Monitor logs for suspicious activity
- [ ] Keep ERPNext updated with security patches
- [ ] Use secrets management for sensitive environment variables

### Backup Strategy

```bash
# Manual backup
docker-compose exec erpnext bench --site your-site-name backup

# Automated backup script (add to cron)
#!/bin/bash
docker-compose exec erpnext bench --site your-site-name backup --with-files
# Upload to S3 or your preferred backup storage
```

## 📚 Additional Resources

- [ERPNext Documentation](https://erpnext.org/docs)
- [Frappe Framework Documentation](https://frappeframework.com/docs)
- [Dokploy Documentation](https://dokploy.com/docs)
- [Docker Compose Reference](https://docs.docker.com/compose/)

## 🆘 Support

If you encounter issues:

1. Check the [troubleshooting section](#-monitoring--troubleshooting)
2. Review service logs for error messages
3. Consult ERPNext community forums
4. Check GitHub issues in the ERPNext repository

---

**Happy deploying! 🎉**
