#!/bin/bash

echo "🚀 AI CFO Deployment Script"
echo "=========================="
echo ""

# Check if n8n is running
echo "📋 Pre-deployment checklist:"
echo ""

# Check for .env file
if [ ! -f .env ]; then
    echo "❌ .env file not found. Creating from .env.example..."
    cp .env.example .env
    echo "   Please edit .env and add your n8n webhook URL"
    echo ""
fi

# Install dependencies if needed
if [ ! -d node_modules ]; then
    echo "📦 Installing dependencies..."
    npm install
    echo ""
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

# Deploy to Vercel
echo "☁️  Deploying to Vercel..."
echo ""

vercel --prod

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Deployment successful!"
    echo ""
    echo "📝 Next steps:"
    echo "1. Make sure your n8n workflow is active"
    echo "2. Update VITE_N8N_WEBHOOK_URL in Vercel dashboard if needed"
    echo "3. Test the application with sample financial statements"
else
    echo ""
    echo "❌ Deployment failed. Please check the error messages above."
fi
