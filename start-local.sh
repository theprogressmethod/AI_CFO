#!/bin/bash

echo "🚀 AI CFO - Local n8n Setup"
echo "============================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${YELLOW}Your n8n cloud workspace is offline.${NC}"
echo -e "${GREEN}No problem! We'll use local n8n (included in Docker).${NC}"
echo ""

# Check Docker
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running!"
    echo "Please start Docker Desktop first"
    exit 1
fi

echo -e "${BLUE}Starting local services with n8n...${NC}"
echo ""

# Start services
docker-compose -f docker-compose.dev.yml up -d --build

echo ""
echo -e "${GREEN}✅ Services started successfully!${NC}"
echo ""
echo "=================================="
echo -e "${CYAN}🌐 Access Points:${NC}"
echo "=================================="
echo ""
echo -e "Web App:    ${GREEN}http://localhost:5173${NC}"
echo -e "n8n Local:  ${GREEN}http://localhost:5678${NC}"
echo ""
echo "=================================="
echo -e "${CYAN}📋 Setup n8n Workflow:${NC}"
echo "=================================="
echo ""
echo "1. Open n8n: http://localhost:5678"
echo "2. Click 'New Workflow'"
echo "3. Click ⋮ menu → Import from File"
echo "4. Select: n8n-financial-workflow.json"
echo "5. Find 'AI Transform Data' node"
echo "6. Double-click it"
echo "7. Add your OpenAI API key"
echo "8. Click 'Save'"
echo "9. Toggle workflow to 'Active'"
echo ""
echo "=================================="
echo -e "${CYAN}✨ Test Your Setup:${NC}"
echo "=================================="
echo ""
echo "1. Go to: http://localhost:5173"
echo "2. Upload your Excel files"
echo "3. Click 'Process Financial Statements'"
echo "4. Download the results!"
echo ""
echo -e "${YELLOW}Commands:${NC}"
echo "  View logs:  docker-compose -f docker-compose.dev.yml logs -f"
echo "  Stop:       docker-compose -f docker-compose.dev.yml down"
echo "  Restart:    docker-compose -f docker-compose.dev.yml restart"
echo ""
echo -e "${GREEN}🎉 Your local setup is ready!${NC}"
