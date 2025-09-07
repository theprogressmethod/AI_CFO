#!/bin/bash

echo "🐳 AI CFO Docker Manager"
echo "========================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to display menu
show_menu() {
    echo "Choose an option:"
    echo "1) 🚀 Start Production (port 3000)"
    echo "2) 🔧 Start Development (port 5173)"
    echo "3) 🏗️  Build Docker Images"
    echo "4) 📊 View Logs"
    echo "5) 🛑 Stop All Containers"
    echo "6) 🧹 Clean Everything"
    echo "7) 📦 Deploy to Render (via Docker)"
    echo "8) 🔄 Restart Services"
    echo "9) ❌ Exit"
    echo ""
}

# Function to check Docker installation
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker is not installed!${NC}"
        echo "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Docker is not running!${NC}"
        echo "Please start Docker Desktop"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Docker is ready${NC}"
}

# Function to load environment variables
load_env() {
    if [ -f .env ]; then
        export $(cat .env | grep -v '^#' | xargs)
        echo -e "${GREEN}✅ Environment variables loaded${NC}"
    else
        echo -e "${YELLOW}⚠️  .env file not found, using defaults${NC}"
        export VITE_N8N_WEBHOOK_URL="http://localhost:5678/webhook/process-financials"
    fi
}

# Start production
start_production() {
    echo -e "${BLUE}Starting production environment...${NC}"
    docker-compose up -d
    echo -e "${GREEN}✅ Production running at: http://localhost:3000${NC}"
    echo -e "${GREEN}✅ n8n running at: http://localhost:5678${NC}"
}

# Start development
start_development() {
    echo -e "${BLUE}Starting development environment...${NC}"
    docker-compose -f docker-compose.dev.yml up -d
    echo -e "${GREEN}✅ Development running at: http://localhost:5173${NC}"
    echo -e "${GREEN}✅ n8n running at: http://localhost:5678${NC}"
}

# Build images
build_images() {
    echo -e "${BLUE}Building Docker images...${NC}"
    docker-compose build --no-cache
    docker-compose -f docker-compose.dev.yml build --no-cache
    echo -e "${GREEN}✅ Images built successfully${NC}"
}

# View logs
view_logs() {
    echo "Select service to view logs:"
    echo "1) Web Application"
    echo "2) n8n"
    echo "3) All Services"
    read -p "Choice: " log_choice
    
    case $log_choice in
        1)
            docker-compose logs -f ai-cfo-web || docker-compose logs -f ai-cfo-dev
            ;;
        2)
            docker-compose logs -f n8n
            ;;
        3)
            docker-compose logs -f
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
}

# Stop all containers
stop_all() {
    echo -e "${YELLOW}Stopping all containers...${NC}"
    docker-compose down
    docker-compose -f docker-compose.dev.yml down
    echo -e "${GREEN}✅ All containers stopped${NC}"
}

# Clean everything
clean_all() {
    echo -e "${RED}⚠️  This will remove all containers, images, and volumes!${NC}"
    read -p "Are you sure? (y/N): " confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        docker-compose down -v --rmi all
        docker-compose -f docker-compose.dev.yml down -v --rmi all
        docker system prune -af
        echo -e "${GREEN}✅ Cleanup complete${NC}"
    else
        echo "Cleanup cancelled"
    fi
}

# Deploy to Render
deploy_render() {
    echo -e "${BLUE}Preparing for Render deployment...${NC}"
    
    # Build production image
    docker build -t ai-cfo:latest .
    
    echo ""
    echo -e "${YELLOW}📋 To deploy to Render with Docker:${NC}"
    echo ""
    echo "1. Push your code to GitHub"
    echo "2. In Render Dashboard, create a new Web Service"
    echo "3. Choose 'Docker' as the environment"
    echo "4. Render will use your Dockerfile automatically"
    echo ""
    echo "Your Dockerfile is optimized for Render deployment!"
}

# Restart services
restart_services() {
    echo -e "${YELLOW}Restarting services...${NC}"
    docker-compose restart || docker-compose -f docker-compose.dev.yml restart
    echo -e "${GREEN}✅ Services restarted${NC}"
}

# Main script
check_docker
load_env

while true; do
    show_menu
    read -p "Enter choice [1-9]: " choice
    
    case $choice in
        1)
            start_production
            ;;
        2)
            start_development
            ;;
        3)
            build_images
            ;;
        4)
            view_logs
            ;;
        5)
            stop_all
            ;;
        6)
            clean_all
            ;;
        7)
            deploy_render
            ;;
        8)
            restart_services
            ;;
        9)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice, please try again${NC}"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
    clear
done
