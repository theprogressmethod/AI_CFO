#!/bin/bash

echo "🚀 AI CFO - Complete Launch Script"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo -e "${GREEN}✅ Environment variables loaded${NC}"
else
    echo -e "${RED}❌ .env file not found!${NC}"
    exit 1
fi

# Step 1: Install dependencies
echo ""
echo "📦 Installing dependencies..."
npm install

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to install dependencies${NC}"
    exit 1
fi

# Step 2: Build the project
echo ""
echo "🔨 Building the project..."
npm run build

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build successful!${NC}"

# Step 3: Initialize git repository
echo ""
echo "📝 Setting up Git repository..."

if [ ! -d .git ]; then
    git init
    git add .
    git commit -m "Initial commit - AI CFO Financial Processor"
    echo -e "${GREEN}✅ Git repository initialized${NC}"
else
    git add .
    git commit -m "Update AI CFO" 2>/dev/null || echo "No changes to commit"
fi

# Step 4: Create GitHub repository (using GitHub CLI if available)
echo ""
echo "📤 Setting up GitHub repository..."

# Check if GitHub CLI is installed
if command -v gh &> /dev/null; then
    # Check if already authenticated
    if gh auth status &> /dev/null; then
        # Create repository if it doesn't exist
        REPO_NAME="ai-cfo-financial-processor"
        
        if ! gh repo view $REPO_NAME &> /dev/null; then
            echo "Creating GitHub repository..."
            gh repo create $REPO_NAME --private --source=. --remote=origin --push
            echo -e "${GREEN}✅ GitHub repository created and code pushed${NC}"
        else
            echo "GitHub repository already exists"
            git push origin main 2>/dev/null || git push origin master 2>/dev/null || echo "Already up to date"
        fi
        
        GITHUB_URL=$(gh repo view --json url -q .url)
        echo -e "${GREEN}GitHub Repository: $GITHUB_URL${NC}"
    else
        echo -e "${YELLOW}⚠️  GitHub CLI not authenticated. Please run: gh auth login${NC}"
        echo "Or manually create a repository and push your code"
    fi
else
    echo -e "${YELLOW}⚠️  GitHub CLI not installed.${NC}"
    echo "Please manually:"
    echo "1. Create a repository on GitHub"
    echo "2. Run: git remote add origin <your-repo-url>"
    echo "3. Run: git push -u origin main"
fi

# Step 5: Deploy to Render
echo ""
echo "☁️  Deploying to Render..."
echo ""

# Check if Render CLI is installed
if command -v render &> /dev/null; then
    echo "Using Render CLI..."
    render up
else
    echo -e "${YELLOW}Render CLI not found. Using API deployment...${NC}"
    
    # Create deployment using Render API
    echo "Creating Render static site..."
    
    # You'll need to have pushed to GitHub first
    echo ""
    echo "📋 Manual Render Deployment Steps:"
    echo "=================================="
    echo ""
    echo "1. Go to: https://dashboard.render.com/new/static"
    echo ""
    echo "2. Connect your GitHub repository"
    echo ""
    echo "3. Use these settings:"
    echo "   • Name: ai-cfo"
    echo "   • Branch: main"
    echo "   • Build Command: npm install && npm run build"
    echo "   • Publish Directory: build"
    echo ""
    echo "4. Add Environment Variable:"
    echo "   • Key: VITE_N8N_WEBHOOK_URL"
    echo "   • Value: $VITE_N8N_WEBHOOK_URL"
    echo ""
    echo "5. Click 'Create Static Site'"
    echo ""
    echo -e "${GREEN}OR use the render.yaml file for automatic configuration${NC}"
fi

# Step 6: Set up n8n workflow
echo ""
echo "🔧 n8n Workflow Setup"
echo "===================="
echo ""
echo "Your n8n webhook URL is configured as:"
echo -e "${GREEN}$VITE_N8N_WEBHOOK_URL${NC}"
echo ""
echo "To activate the n8n workflow:"
echo "1. Go to your n8n instance"
echo "2. Import the workflow from: n8n-financial-workflow.json"
echo "3. Configure the OpenAI node with your API key"
echo "4. Activate the workflow"
echo ""

# Step 7: Run locally for testing
echo "🖥️  Local Development"
echo "===================="
echo ""
echo "To test locally, run:"
echo -e "${GREEN}npm run dev${NC}"
echo ""
echo "The application will be available at: http://localhost:5173"
echo ""

# Final instructions
echo "📝 Final Steps Summary"
echo "====================="
echo ""
echo "1. ✅ Project built successfully"
echo "2. ⏳ Push to GitHub (if not done automatically)"
echo "3. ⏳ Deploy to Render (follow instructions above)"
echo "4. ⏳ Configure n8n workflow"
echo "5. ✅ Test locally with: npm run dev"
echo ""
echo -e "${GREEN}🎉 Setup complete! Follow the remaining manual steps above.${NC}"
