#!/bin/bash

echo "🧪 Testing AI CFO Setup"
echo "======================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test Docker
echo "1. Testing Docker..."
if docker info > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker is running${NC}"
else
    echo -e "${RED}❌ Docker is not running${NC}"
    exit 1
fi

# Test services
echo ""
echo "2. Testing services..."

# Test web app
if curl -s -o /dev/null -w "%{http_code}" http://localhost:5173 | grep -q "200\|304"; then
    echo -e "${GREEN}✅ Web app is running at http://localhost:5173${NC}"
else
    echo -e "${YELLOW}⚠️  Web app not responding - starting it...${NC}"
    docker-compose -f docker-compose.dev.yml up -d
    sleep 5
fi

# Test n8n
if curl -s -o /dev/null -w "%{http_code}" http://localhost:5678 | grep -q "200\|302"; then
    echo -e "${GREEN}✅ n8n is running at http://localhost:5678${NC}"
else
    echo -e "${YELLOW}⚠️  n8n not responding - check Docker logs${NC}"
fi

# Test webhook endpoint
echo ""
echo "3. Testing webhook endpoint..."
WEBHOOK_URL="http://localhost:5678/webhook/process-financials"

# Create a test request
TEST_RESPONSE=$(curl -s -X POST $WEBHOOK_URL \
  -H "Content-Type: application/json" \
  -d '{"test": true}' \
  -w "\n%{http_code}" 2>/dev/null | tail -n 1)

if [ "$TEST_RESPONSE" = "404" ]; then
    echo -e "${YELLOW}⚠️  Webhook not found - workflow might not be activated${NC}"
    echo "   Please import and activate the workflow in n8n"
elif [ "$TEST_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ Webhook is responding${NC}"
else
    echo -e "${RED}❌ Webhook returned: $TEST_RESPONSE${NC}"
fi

echo ""
echo "4. Checking logs for errors..."
docker-compose -f docker-compose.dev.yml logs --tail=10 2>&1 | grep -i error > /dev/null
if [ $? -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Found errors in logs. Run this to view:${NC}"
    echo "   docker-compose -f docker-compose.dev.yml logs -f"
else
    echo -e "${GREEN}✅ No recent errors in logs${NC}"
fi

echo ""
echo "================================"
echo -e "${GREEN}Test Summary:${NC}"
echo "================================"
echo "Web App: http://localhost:5173"
echo "n8n:     http://localhost:5678"
echo ""
echo "Next steps:"
echo "1. Import workflow: n8n-workflow-no-ai.json (simpler, no API key needed)"
echo "   OR"
echo "   n8n-workflow-ai-fixed.json (with AI, needs OpenAI key)"
echo "2. Activate the workflow"
echo "3. Test with your Excel files"
echo ""
echo -e "${YELLOW}Tip: Start with the no-AI version to test the system!${NC}"
