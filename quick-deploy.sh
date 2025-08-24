#!/bin/bash

# Quick ERPNext Deployment Script for Dokploy CLI
# Use this after initial setup to quickly deploy updates

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
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

# Configuration - Update these with your actual IDs after first deployment
PROJECT_ID="${DOKPLOY_PROJECT_ID:-}"
APPLICATION_ID="${DOKPLOY_APPLICATION_ID:-}"

# Function to check if IDs are configured
check_configuration() {
    if [[ -z "$PROJECT_ID" || -z "$APPLICATION_ID" ]]; then
        print_error "Project ID and Application ID are required"
        echo ""
        echo "You can set them as environment variables:"
        echo "  export DOKPLOY_PROJECT_ID=your-project-id"
        echo "  export DOKPLOY_APPLICATION_ID=your-application-id"
        echo ""
        echo "Or edit this script and update the configuration section"
        echo ""
        echo "To get your IDs, run:"
        echo "  dokploy project list"
        echo ""
        return 1
    fi
}

# Function to deploy
deploy() {
    print_info "Deploying ERPNext application..."
    print_info "Project ID: $PROJECT_ID"
    print_info "Application ID: $APPLICATION_ID"
    
    # Verify authentication
    if ! dokploy verify > /dev/null 2>&1; then
        print_error "Authentication failed. Please authenticate first:"
        echo "dokploy authenticate --url=https://your-dokploy-server.com --token=your-api-token"
        return 1
    fi
    
    # Deploy
    print_info "Starting deployment..."
    dokploy app deploy \
        --applicationId="$APPLICATION_ID" \
        --projectId="$PROJECT_ID" \
        --skipConfirm
    
    print_success "Deployment initiated!"
    print_info "Monitor progress in your Dokploy dashboard"
}

# Function to stop application
stop_app() {
    print_info "Stopping ERPNext application..."
    dokploy app stop \
        --applicationId="$APPLICATION_ID" \
        --projectId="$PROJECT_ID" \
        --skipConfirm
    
    print_success "Application stopped"
}

# Main function
main() {
    echo ""
    echo "⚡ Quick ERPNext Deployment"
    echo "=========================="
    echo ""
    
    if ! check_configuration; then
        exit 1
    fi
    
    case "${1:-deploy}" in
        "deploy")
            deploy
            ;;
        "stop")
            stop_app
            ;;
        "help"|"--help"|"-h")
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  deploy    Deploy the application (default)"
            echo "  stop      Stop the application"
            echo "  help      Show this help message"
            echo ""
            echo "Environment Variables:"
            echo "  DOKPLOY_PROJECT_ID      - Your Dokploy project ID"
            echo "  DOKPLOY_APPLICATION_ID  - Your Dokploy application ID"
            ;;
        *)
            print_error "Unknown command: $1"
            echo "Run '$0 help' for usage information"
            exit 1
            ;;
    esac
}

main "$@"
