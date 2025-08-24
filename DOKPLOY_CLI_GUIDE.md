# ERPNext Dokploy CLI Deployment Guide

This guide shows you how to deploy your **NextERP** fork using the Dokploy CLI for complete command-line control.

## 🛠️ Prerequisites

1. **Dokploy Server** - You need a running Dokploy instance
2. **API Token** - Generated from your Dokploy dashboard
3. **Git Repository** - Your NextERP fork at `https://github.com/AltFl0w/NextERP.git`

## 📦 Installation

The Dokploy CLI is already installed via npm:

```bash
# Verify installation
dokploy --help
```

## 🔐 Authentication

First, authenticate with your Dokploy server:

```bash
# Replace with your actual server URL and API token
dokploy authenticate \
  --url=https://your-dokploy-server.com \
  --token=your-api-token
```

**To get your API token:**
1. Go to your Dokploy dashboard
2. Navigate to **Settings** → **API Tokens**  
3. Create a new token
4. Copy the token for authentication

**Verify authentication:**
```bash
dokploy verify
```

## 🚀 Automated Deployment

### Option 1: Full Setup Script (Recommended for first-time)

Run the automated setup script:

```bash
./deploy-dokploy.sh
```

This script will:
- ✅ Check authentication
- ✅ Create/select project
- ✅ Create application
- ✅ Guide environment setup
- ✅ Deploy the application

### Option 2: Manual Step-by-Step

#### Step 1: Create Project

```bash
# List existing projects
dokploy project list

# Create new project (if needed)
dokploy project create \
  --name="erpnext-production" \
  --description="ERPNext deployment with NextERP fork"
```

#### Step 2: Create Application

```bash
# Create application (replace PROJECT_ID with actual ID)
dokploy app create \
  --projectId="your-project-id" \
  --name="erpnext-app" \
  --description="ERPNext ERP System with Custom NextERP Fork" \
  --appName="erpnext-app"
```

#### Step 3: Configure Environment Variables

Set these in your Dokploy dashboard or via API:

```bash
# Required environment variables
ERPNEXT_REPO_URL=https://github.com/AltFl0w/NextERP.git
ERPNEXT_BRANCH=version-15
DOMAIN=your-erpnext-domain.com
SITE_NAME=your-erpnext-domain.com
DB_PASSWORD=your_secure_db_password
ADMIN_PASSWORD=your_secure_admin_password

# Optional
FRAPPE_DEV=0
DB_NAME=erpnext
DB_USER=erpnext
```

#### Step 4: Deploy

```bash
# Deploy application (replace IDs with actual values)
dokploy app deploy \
  --applicationId="your-app-id" \
  --projectId="your-project-id"
```

## ⚡ Quick Deployments

After initial setup, use the quick deployment script for updates:

```bash
# Set your IDs as environment variables (one-time setup)
export DOKPLOY_PROJECT_ID="your-project-id"
export DOKPLOY_APPLICATION_ID="your-application-id"

# Quick deploy
./quick-deploy.sh

# Or stop the application
./quick-deploy.sh stop
```

## 🔄 Update Workflow

### When you update NextERP code:

1. **Push changes to your NextERP repository:**
   ```bash
   cd /path/to/NextERP
   git add .
   git commit -m "Add new features"
   git push origin main
   ```

2. **Trigger Dokploy deployment:**
   ```bash
   # Using quick deploy script
   ./quick-deploy.sh
   
   # Or manually
   dokploy app deploy --applicationId="your-app-id" --projectId="your-project-id"
   ```

### When you update deployment configuration:

1. **Update docker-compose.yml or other config files**
2. **Commit changes to deployment repository**
3. **Redeploy via Dokploy dashboard or CLI**

## 🎛️ Available Commands

### Project Management
```bash
# List all projects
dokploy project list

# Get project details
dokploy project info --projectId="project-id"

# Create new project
dokploy project create --name="project-name" --description="description"
```

### Application Management
```bash
# Create application
dokploy app create --projectId="project-id" --name="app-name"

# Deploy application
dokploy app deploy --applicationId="app-id" --projectId="project-id"

# Stop application
dokploy app stop --applicationId="app-id" --projectId="project-id"

# Delete application
dokploy app delete --applicationId="app-id" --projectId="project-id"
```

### Environment Variables
```bash
# Store environment variables locally
dokploy env pull --applicationId="app-id"

# Push local environment variables
dokploy env push --applicationId="app-id"
```

## 🐛 Troubleshooting

### Authentication Issues
```bash
# Check if authenticated
dokploy verify

# Re-authenticate if needed
dokploy authenticate --url=https://your-server.com --token=new-token
```

### Getting Project/App IDs
```bash
# List projects to get project ID
dokploy project list

# Get project info to see applications
dokploy project info --projectId="your-project-id"
```

### Deployment Failures
1. Check logs in Dokploy dashboard
2. Verify environment variables are set correctly
3. Ensure your NextERP repository is accessible
4. Check Docker build logs for errors

## 📋 Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `ERPNEXT_REPO_URL` | Your NextERP repository URL | `https://github.com/AltFl0w/NextERP.git` |
| `ERPNEXT_BRANCH` | Git branch to deploy | `version-15` |
| `DOMAIN` | Your ERPNext domain | `erp.yourcompany.com` |
| `SITE_NAME` | ERPNext site name (usually same as domain) | `erp.yourcompany.com` |
| `DB_PASSWORD` | PostgreSQL database password | `secure_password` |
| `ADMIN_PASSWORD` | ERPNext admin password | `admin_password` |
| `FRAPPE_DEV` | Development mode (0 for production) | `0` |
| `DB_NAME` | Database name | `erpnext` |
| `DB_USER` | Database user | `erpnext` |

## 🔒 Security Best Practices

1. **Use strong passwords** for `DB_PASSWORD` and `ADMIN_PASSWORD`
2. **Store API tokens securely** - don't commit them to Git
3. **Use environment variables** for sensitive data
4. **Enable SSL/TLS** through Dokploy's Traefik integration
5. **Regular backups** of your ERPNext data
6. **Monitor logs** for suspicious activity

## 🎯 Next Steps

After successful deployment:

1. **Configure DNS** - Point your domain to Dokploy server
2. **Setup SSL** - Dokploy handles this automatically with Traefik
3. **Access ERPNext** - Go to `https://your-domain.com`
4. **Configure ERPNext** - Complete initial setup wizard
5. **Setup backups** - Configure regular database backups
6. **Monitor** - Set up monitoring and alerts

## 📚 Additional Resources

- [Dokploy Documentation](https://dokploy.com/docs)
- [Dokploy CLI Reference](https://github.com/dokploy/dokploy-cli)
- [ERPNext Documentation](https://erpnext.org/docs)
- [Your NextERP Repository](https://github.com/AltFl0w/NextERP)

---

**Happy deploying with Dokploy CLI! 🚀**
