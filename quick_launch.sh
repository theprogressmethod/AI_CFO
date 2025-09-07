#!/bin/bash

# Quick launch script - Run this!
cd /Users/thomasmulhern/projects/AI_CFO

echo "🚀 AI CFO Quick Launch"
echo "====================="
echo ""

# Install and build
echo "📦 Installing dependencies..."
npm install --silent

echo "🔨 Building project..."
npm run build --silent

# Initialize git
if [ ! -d .git ]; then
    git init
    git add .
    git commit -m "Initial commit" > /dev/null 2>&1
fi

echo ""
echo "✅ Project ready!"
echo ""
echo "📋 COPY THESE COMMANDS:"
echo ""
echo "# 1. Start local server:"
echo "npm run dev"
echo ""
echo "# 2. After creating GitHub repo, push code:"
echo "git remote add origin https://github.com/YOUR_USERNAME/ai-cfo-financial-processor.git"
echo "git push -u origin main"
echo ""
echo "🌐 BROWSER TABS OPENED:"
echo "1. GitHub - Create new repository"
echo "2. Render - Deploy static site" 
echo "3. n8n Cloud - Import workflow"
echo "4. Launch Instructions"
echo ""
echo "Follow the instructions in your browser!"
