#!/bin/bash

echo "🚀 AI CFO - Complete Launch System"
echo "==================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check Docker availability
check_docker() {
    if command -v docker &> /dev/null && docker info &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Main menu
echo -e "${CYAN}Choose your deployment method:${NC}"
echo ""
echo -e "${BLUE}1)${NC} 🐳 Docker Deployment (Recommended)"
echo -e "${BLUE}2)${NC} 📦 Traditional npm Deployment"
echo -e "${BLUE}3)${NC} ☁️  Deploy to Render"
echo -e "${BLUE}4)${NC} 📚 View Documentation"
echo ""
read -p "Enter choice [1-4]: " main_choice

case $main_choice in
    1)
        # Docker Deployment
        echo ""
        echo -e "${BLUE}🐳 Docker Deployment${NC}"
        echo "===================="
        
        if ! check_docker; then
            echo -e "${RED}❌ Docker is not installed or not running${NC}"
            echo ""
            echo "Please install Docker Desktop from:"
            echo -e "${CYAN}https://www.docker.com/products/docker-desktop${NC}"
            echo ""
            echo "After installing, start Docker Desktop and run this script again."
            exit 1
        fi
        
        echo -e "${GREEN}✅ Docker detected${NC}"
        echo ""
        echo "Select mode:"
        echo "a) Production (port 3000)"
        echo "b) Development (port 5173, hot reload)"
        read -p "Choice [a/b]: " docker_mode
        
        if [ "$docker_mode" = "a" ]; then
            echo -e "${YELLOW}Building production containers...${NC}"
            docker-compose build
            docker-compose up -d
            echo ""
            echo -e "${GREEN}✅ Production deployment complete!${NC}"
            echo -e "   Web App: ${CYAN}http://localhost:3000${NC}"
            echo -e "   n8n:     ${CYAN}http://localhost:5678${NC}"
        else
            echo -e "${YELLOW}Building development containers...${NC}"
            docker-compose -f docker-compose.dev.yml build
            docker-compose -f docker-compose.dev.yml up -d
            echo ""
            echo -e "${GREEN}✅ Development deployment complete!${NC}"
            echo -e "   Web App: ${CYAN}http://localhost:5173${NC} (hot reload enabled)"
            echo -e "   n8n:     ${CYAN}http://localhost:5678${NC}"
        fi
        
        echo ""
        echo -e "${MAGENTA}Next steps:${NC}"
        echo "1. Import workflow at http://localhost:5678"
        echo "2. Upload: n8n-financial-workflow.json"
        echo "3. Add your OpenAI API key"
        echo "4. Activate the workflow"
        echo ""
        echo -e "${YELLOW}Useful commands:${NC}"
        echo "  docker-compose logs -f        # View logs"
        echo "  docker-compose down           # Stop services"
        echo "  docker-compose restart        # Restart services"
        ;;
        
    2)
        # Traditional npm deployment
        echo ""
        echo -e "${BLUE}📦 Traditional npm Deployment${NC}"
        echo "=============================="
        
        # Check Node.js
        if ! command -v node &> /dev/null; then
            echo -e "${RED}❌ Node.js is not installed${NC}"
            echo "Please install Node.js from: https://nodejs.org"
            exit 1
        fi
        
        echo -e "${GREEN}✅ Node.js detected: $(node -v)${NC}"
        echo ""
        
        # Install dependencies
        echo -e "${YELLOW}Installing dependencies...${NC}"
        npm install
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ Failed to install dependencies${NC}"
            exit 1
        fi
        
        # Build project
        echo -e "${YELLOW}Building project...${NC}"
        npm run build
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ Build failed${NC}"
            exit 1
        fi
        
        echo ""
        echo -e "${GREEN}✅ Build successful!${NC}"
        echo ""
        echo -e "${YELLOW}Starting development server...${NC}"
        npm run dev
        ;;
        
    3)
        # Deploy to Render
        echo ""
        echo -e "${BLUE}☁️  Render Deployment${NC}"
        echo "===================="
        echo ""
        
        # Check git
        if [ ! -d .git ]; then
            echo -e "${YELLOW}Initializing git repository...${NC}"
            git init
            git add .
            git commit -m "Initial commit"
        fi
        
        echo -e "${MAGENTA}📋 Steps to deploy to Render:${NC}"
        echo ""
        echo "1. Create GitHub repository:"
        echo -e "   ${CYAN}https://github.com/new${NC}"
        echo "   Name: ai-cfo-financial-processor"
        echo ""
        echo "2. Push code to GitHub:"
        echo -e "${GREEN}"
        echo "   git remote add origin https://github.com/YOUR_USERNAME/ai-cfo-financial-processor.git"
        echo "   git push -u origin main"
        echo -e "${NC}"
        echo ""
        echo "3. Deploy on Render:"
        echo -e "   ${CYAN}https://dashboard.render.com/new/web${NC}"
        echo "   - Choose: Docker"
        echo "   - Connect your GitHub repo"
        echo "   - Use render-docker.yaml for config"
        echo ""
        echo "4. Your app will be available at:"
        echo -e "   ${CYAN}https://ai-cfo-docker.onrender.com${NC}"
        echo ""
        
        # Open browser tabs
        if command -v open &> /dev/null; then
            echo -e "${YELLOW}Opening browser tabs...${NC}"
            open https://github.com/new
            open https://dashboard.render.com/new/web
        fi
        ;;
        
    4)
        # View documentation
        echo ""
        echo -e "${BLUE}📚 Documentation${NC}"
        echo "================"
        echo ""
        cat README.md | head -50
        echo ""
        echo -e "${YELLOW}Full documentation in README.md${NC}"
        echo ""
        echo "Quick links:"
        echo -e "  Dashboard: ${CYAN}file://$PWD/launch-dashboard.html${NC}"
        echo -e "  README:    ${CYAN}file://$PWD/README.md${NC}"
        
        if command -v open &> /dev/null; then
            open file://$PWD/launch-dashboard.html
        fi
        ;;
        
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}🎉 Setup complete!${NC}"
echo ""
echo "For help, check the README.md or run:"
echo "  sh docker-manager.sh    # Docker management menu"
echo "  sh docker-start.sh      # Quick Docker start"
