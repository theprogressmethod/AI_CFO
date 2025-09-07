#!/bin/bash

echo "🔧 Fixing npm installation issue..."
cd /Users/thomasmulhern/projects/AI_CFO

# Clean install
echo "Cleaning previous installation attempts..."
rm -rf node_modules package-lock.json

echo "Installing dependencies..."
npm install

echo ""
echo "✅ Installation complete! Now you can run:"
echo "  npm run build"
echo "  npm run dev"
