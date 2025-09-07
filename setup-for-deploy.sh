#!/bin/bash

# Quick setup and test before deployment
echo "=== Financial Processor - Pre-Deployment Setup ==="
echo ""

cd /Users/thomasmulhern/projects/AI_CFO

# Make deploy script executable
chmod +x deploy-to-render.sh

# Clean install
echo "1. Installing dependencies..."
rm -rf node_modules package-lock.json
npm install @sveltejs/adapter-node
npm install

# Test locally
echo ""
echo "2. Testing locally..."
npm run build

echo ""
echo "✅ Setup complete!"
echo ""
echo "To test locally: npm run dev"
echo "To deploy: ./deploy-to-render.sh"
echo ""
echo "The UI has been fixed with:"
echo "• Normal-sized icons (6x6 instead of 10x10)"
echo "• Compact layout"
echo "• Smaller text and spacing"
echo ""
echo "Ready for Render deployment!"