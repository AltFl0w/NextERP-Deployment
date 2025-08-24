#!/bin/bash

# ERPNext Dokploy CLI Deployment Script
# This script automates the deployment of your NextERP fork via Dokploy CLI

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ERPNEXT_REPO_URL="https://github.com/AltFl0w/NextERP.git"
PROJECT_NAME="erpnext-production"
APP_NAME="erpnext-app"
APP_DESCRIPTION="ERPNext ERP System with Custom NextERP Fork"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if authentication is valid
check_authentication() {
    print_status "Checking Dokploy authentication..."
    
    if dokploy verify; then
        print_success "Authentication verified successfully"
        return 0
    else
        print_error "Authentication failed. Please run authentication first."
        echo ""
        echo "To authenticate, run:"
        echo "dokploy authenticate --url=https://your-dokploy-server.com --token=your-api-token"
        echo ""
        echo "You can get your API token from your Dokploy dashboard under Settings > API Tokens"
        return 1
    fi
}

# Function to create or get project
setup_project() {
    print_status "Setting up project: $PROJECT_NAME"
    
    # List existing projects to see if our project already exists
    print_status "Checking for existing projects..."
    dokploy project list
    
    echo ""
    read -p "Does the project '$PROJECT_NAME' already exist? (y/n): " project_exists
    
    if [[ $project_exists != "y" && $project_exists != "Y" ]]; then
        print_status "Creating new project: $PROJECT_NAME"
        dokploy project create --name="$PROJECT_NAME" --description="ERPNext deployment with NextERP fork"
        print_success "Project created successfully"
    else
        print_status "Using existing project: $PROJECT_NAME"
    fi
    
    # Get project ID
    print_status "Getting project information..."
    dokploy project list
    echo ""
    read -p "Please enter the Project ID for '$PROJECT_NAME': " PROJECT_ID
}

# Function to create application
setup_application() {
    print_status "Setting up application: $APP_NAME"
    
    if [[ -z "$PROJECT_ID" ]]; then
        print_error "Project ID is required. Please run setup_project first."
        return 1
    fi
    
    print_status "Creating application in project $PROJECT_ID"
    dokploy app create \
        --projectId="$PROJECT_ID" \
        --name="$APP_NAME" \
        --description="$APP_DESCRIPTION" \
        --appName="$APP_NAME"
    
    print_success "Application created successfully"
    
    # Get application ID
    echo ""
    read -p "Please enter the Application ID that was just created: " APPLICATION_ID
}

# Function to configure environment variables
setup_environment() {
    print_status "Setting up environment variables..."
    
    if [[ ! -f ".env" ]]; then
        print_warning "No .env file found. Creating from template..."
        if [[ -f ".env.example" ]]; then
            cp .env.example .env
            print_warning "Please edit .env file with your configuration before continuing"
            read -p "Press enter after you've configured your .env file..."
        else
            print_error "No .env.example file found. Please create .env manually."
            return 1
        fi
    fi
    
    print_status "Environment variables should be configured in Dokploy dashboard:"
    echo ""
    echo "Required environment variables:"
    echo "- ERPNEXT_REPO_URL=$ERPNEXT_REPO_URL"
    echo "- ERPNEXT_BRANCH=version-15"
    echo "- DOMAIN=your-domain.com"
    echo "- SITE_NAME=your-domain.com"
    echo "- DB_PASSWORD=secure_password"
    echo "- ADMIN_PASSWORD=secure_admin_password"
    echo ""
    print_warning "Please configure these in your Dokploy dashboard before deploying"
    read -p "Press enter when environment variables are configured..."
}

# Function to deploy application
deploy_application() {
    print_status "Deploying application..."
    
    if [[ -z "$APPLICATION_ID" || -z "$PROJECT_ID" ]]; then
        print_error "Application ID and Project ID are required for deployment"
        return 1
    fi
    
    print_status "Starting deployment of application $APPLICATION_ID in project $PROJECT_ID"
    dokploy app deploy \
        --applicationId="$APPLICATION_ID" \
        --projectId="$PROJECT_ID" \
        --skipConfirm
    
    print_success "Deployment initiated successfully!"
    print_status "You can monitor the deployment progress in your Dokploy dashboard"
}

# Function to show deployment status
show_status() {
    echo ""
    echo "=================================================="
    echo "         ERPNext Dokploy Deployment Summary"
    echo "=================================================="
    echo "Repository: $ERPNEXT_REPO_URL"
    echo "Project: $PROJECT_NAME (ID: ${PROJECT_ID:-'Not set'})"
    echo "Application: $APP_NAME (ID: ${APPLICATION_ID:-'Not set'})"
    echo "=================================================="
    echo ""
}

# Main deployment function
main() {
    echo ""
    echo "🚀 ERPNext Dokploy CLI Deployment"
    echo "=================================="
    echo ""
    
    # Check authentication
    if ! check_authentication; then
        exit 1
    fi
    
    # Setup project
    setup_project
    
    # Setup application
    setup_application
    
    # Setup environment
    setup_environment
    
    # Show current status
    show_status
    
    # Ask for deployment confirmation
    echo ""
    read -p "Do you want to deploy the application now? (y/n): " deploy_now
    
    if [[ $deploy_now == "y" || $deploy_now == "Y" ]]; then
        deploy_application
    else
        print_status "Deployment skipped. You can deploy later with:"
        echo "dokploy app deploy --applicationId=$APPLICATION_ID --projectId=$PROJECT_ID"
    fi
    
    print_success "Setup completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Configure your domain DNS to point to your Dokploy server"
    echo "2. Monitor deployment in Dokploy dashboard"
    echo "3. Access your ERPNext instance at https://your-domain.com"
}

# Check if script is being run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
