#!/bin/bash

echo "🔧 Fixing n8n Binary Data Error"
echo "================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}The error 'stream.on is not a function' is a known n8n issue.${NC}"
echo -e "${GREEN}Solution: Use the simplified workflow that avoids this problem.${NC}"
echo ""

echo "Steps to fix:"
echo "============="
echo ""
echo "1. Stop and restart n8n:"
docker-compose -f docker-compose.dev.yml down
docker-compose -f docker-compose.dev.yml up -d

echo ""
echo -e "${YELLOW}Waiting for n8n to start...${NC}"
sleep 10

echo ""
echo "2. Open n8n: http://localhost:5678"
echo ""
echo "3. Delete any existing workflow"
echo ""
echo "4. Import the SIMPLE workflow:"
echo -e "${GREEN}   n8n-workflow-simple.json${NC}"
echo ""
echo "5. The workflow uses built-in Spreadsheet nodes (no custom code for binary)"
echo ""
echo "6. Activate the workflow (toggle in top right)"
echo ""
echo "7. Test with your Excel files at: http://localhost:5173"
echo ""

# Test if services are running
echo "Service Status:"
echo "==============="
if curl -s -o /dev/null -w "%{http_code}" http://localhost:5173 | grep -q "200\|304"; then
    echo -e "${GREEN}✅ Web app: http://localhost:5173${NC}"
else
    echo -e "${YELLOW}⚠️  Web app not ready yet${NC}"
fi

if curl -s -o /dev/null -w "%{http_code}" http://localhost:5678 | grep -q "200\|302"; then
    echo -e "${GREEN}✅ n8n: http://localhost:5678${NC}"
else
    echo -e "${YELLOW}⚠️  n8n not ready yet${NC}"
fi

echo ""
echo -e "${BLUE}The simple workflow avoids the binary data issue by using:${NC}"
echo "• Built-in Spreadsheet File node (no custom binary handling)"
echo "• Simple JavaScript transformation"
echo "• Direct Excel output"
echo ""
echo -e "${GREEN}This version is more stable and doesn't require complex parsing!${NC}"
