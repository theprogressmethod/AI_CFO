#!/bin/bash

echo "🚀 AI CFO - Complete Automated Launch"
echo "====================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Change to project directory
cd /Users/thomasmulhern/projects/AI_CFO

# Step 1: Install dependencies
echo -e "${BLUE}📦 Installing dependencies...${NC}"
npm install

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to install dependencies${NC}"
    echo "Please run: npm install"
    exit 1
fi

echo -e "${GREEN}✅ Dependencies installed${NC}"

# Step 2: Build the project
echo ""
echo -e "${BLUE}🔨 Building the project...${NC}"
npm run build

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build successful!${NC}"

# Step 3: Start local dev server
echo ""
echo -e "${BLUE}🖥️  Starting local development server...${NC}"
echo -e "${GREEN}Local app will be available at: http://localhost:5173${NC}"
echo ""

# Run dev server in background
npm run dev &
DEV_PID=$!

echo -e "${GREEN}✅ Local server started (PID: $DEV_PID)${NC}"

# Step 4: Open browser
echo ""
echo -e "${BLUE}🌐 Opening browser...${NC}"
open http://localhost:5173

# Step 5: Display next steps
echo ""
echo "======================================"
echo -e "${GREEN}✅ LOCAL SETUP COMPLETE!${NC}"
echo "======================================"
echo ""
echo -e "${YELLOW}📋 REMAINING MANUAL STEPS:${NC}"
echo ""
echo "1️⃣  ${BLUE}Create GitHub Repository:${NC}"
echo "   a. Go to: https://github.com/new"
echo "   b. Repository name: ai-cfo-financial-processor"
echo "   c. Set to Private"
echo "   d. Don't initialize with README"
echo "   e. Create repository"
echo ""
echo "2️⃣  ${BLUE}Push Code to GitHub:${NC}"
echo "   Run these commands:"
echo -e "${GREEN}"
echo "   cd /Users/thomasmulhern/projects/AI_CFO"
echo "   git init"
echo "   git add ."
echo "   git commit -m 'Initial commit'"
echo "   git branch -M main"
echo "   git remote add origin https://github.com/YOUR_USERNAME/ai-cfo-financial-processor.git"
echo "   git push -u origin main"
echo -e "${NC}"
echo ""
echo "3️⃣  ${BLUE}Deploy to Render:${NC}"
echo "   a. Go to: https://dashboard.render.com/new/static"
echo "   b. Connect GitHub repository: ai-cfo-financial-processor"
echo "   c. Settings will auto-configure from render.yaml"
echo "   d. Click 'Create Static Site'"
echo "   e. Wait for deployment (3-5 minutes)"
echo ""
echo "4️⃣  ${BLUE}Set up n8n Workflow:${NC}"
echo "   a. Go to: https://app.n8n.cloud"
echo "   b. Create new workflow"
echo "   c. Import from: /Users/thomasmulhern/projects/AI_CFO/n8n-financial-workflow.json"
echo "   d. Add OpenAI API key to 'AI Transform Data' node"
echo "   e. Activate the workflow"
echo "   f. Copy the webhook URL and update if different"
echo ""
echo "======================================"
echo -e "${GREEN}📍 CURRENT STATUS:${NC}"
echo "======================================"
echo "✅ Project built and ready"
echo "✅ Local server running at: http://localhost:5173"
echo "✅ Environment configured"
echo "⏳ Waiting for GitHub repository creation"
echo "⏳ Waiting for Render deployment"
echo "⏳ Waiting for n8n workflow activation"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop the local server${NC}"
echo ""

# Keep the script running
wait $DEV_PID
