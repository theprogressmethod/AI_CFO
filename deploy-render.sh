#!/bin/bash

echo "🚀 AI CFO - Render Deployment Script"
echo "====================================="
echo ""

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "❌ .env file not found!"
    exit 1
fi

# Check if Render API key is set
if [ -z "$RENDER_API_KEY" ]; then
    echo "❌ RENDER_API_KEY not found in .env file!"
    exit 1
fi

# Install dependencies if needed
if [ ! -d node_modules ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Build the project
echo "🔨 Building project..."
npm run build

if [ $? -ne 0 ]; then
    echo "❌ Build failed. Please fix errors and try again."
    exit 1
fi

echo ""
echo "✅ Build successful!"
echo ""

# Initialize git if not already initialized
if [ ! -d .git ]; then
    echo "📝 Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit"
fi

# Create or update the repository on GitHub (we'll use a simple approach)
echo "📤 Preparing for Render deployment..."
echo ""
echo "To deploy to Render:"
echo ""
echo "1. Push your code to GitHub:"
echo "   git remote add origin <your-github-repo-url>"
echo "   git push -u origin main"
echo ""
echo "2. Go to https://dashboard.render.com"
echo "3. Click 'New +' → 'Static Site'"
echo "4. Connect your GitHub repository"
echo "5. Use these settings:"
echo "   - Name: ai-cfo"
echo "   - Build Command: npm install && npm run build"
echo "   - Publish Directory: build"
echo ""
echo "6. Add environment variable:"
echo "   VITE_N8N_WEBHOOK_URL = $VITE_N8N_WEBHOOK_URL"
echo ""
echo "Or use the render.yaml file for automatic configuration"
